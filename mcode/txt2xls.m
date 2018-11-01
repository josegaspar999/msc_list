function txt2xls( cmdId, options )
%
% Get thesis supervised at Vislab

% 23.4.2018 (1st ver) J. Gaspar

if nargin<1
    cmdId= 2; %3; %2; %1; %0;
end
if nargin<2
    options= [];
end

fname= '../data/180420_v0/online_DEEC_180420.txt';
if isfield(options, 'fname'), fname= options.fname; end

%options= struct('lines_ini','2017/2018', 'lines_end','* MEEC');
if ~isfield(options, 'lines_ini')
    options.lines_ini= '2017/2018';
end
if ~isfield(options, 'lines_end')
    options.lines_end= '* MEEC';
end

switch cmdId
    case 0
        % find supervisor Id in the TXT file
        lst= get_supervisor_list( options );
        for i=1:length(lst)
            str= ['!grep "' lst{i} '" ' fname];
            eval(str)
        end
        
    case 1
        % find all possible states of thesis
        mk_list_of_states( fname, options )

    case {2, 3}
        % create XLS file from TXT info
        if cmdId == 3
            options.ofname_xls= strrep( fname, '.txt', '_vislab.xls' );
        end
        mk_list_of_thesis( fname, options )

    otherwise
        error('inv tstId')
end

return; % end of main function


% ------------------------------------------------------------------------
function lst= get_supervisor_list( options )
lst= {'(ist12760)', '(ist13761)', '(ist11994)', '(ist13495)', '(ist31838)'};
if isfield(options,'supervisorsList')
    lst= {};
    [lst{end+1}, remain]= strtok( options.supervisorsList, ',' );
    while ~isempty(remain)
        [lst{end+1}, remain]= strtok( remain, ',' );
    end
end


% ------------------------------------------------------------------------
function mk_list_of_states( fname, options )
% try to get all possible status by getting capitalized word
%  at the end of a line starting with "* "

y= text_read(fname);
iRange= range_of_lines( y, options );
nTitles= 0; % after runing the code online_DEEC_180420.txt => 2234 titles
lstStates= {}; % start empty

for i= iRange
    str= y{i};
    if ~isempty( strfind( str, '* ' ) )
        nTitles= nTitles+1;
        str2= get_state_string( str );
        lstStates= list_states( lstStates, str2 );

        fprintf( 1, '%d %s %s\n', nTitles, str2, str );
    end
end

fprintf(1, '--- List of states:\n');
for i=1:length( lstStates )
    fprintf( 1, '%s\n', lstStates{i} );
end

return


function lstStates= list_states( lstStates, str2 )
% from online_DEEC_180420.txt one gets lstStates:
% DRAFT
% APPROVED
% CONFIRMED
% EVALUATED
% SUBMITTED

foundFlag= 0;
for i=1:length(lstStates)
    if strcmp( str2, lstStates{i} )
        foundFlag= 1;
        break
    end
end
if foundFlag
    return
else
    lstStates{end+1}= str2;
end


function str2= get_state_string( str )
% from last chr to 1st, find capital end with capital
ind1= -1;
ind2= -1;
for i= length(str):-1:1
    % only capital chrs
    if ind2<0 && ('A'<=str(i) && str(i)<='Z')
        ind2= i;
    end
    if ind2>0 && ind1<0 && (str(i)<'A' || 'Z'<str(i))
        ind1= i+1;
        break;
    end
end
str2= str(ind1:ind2);
return


function validLine= check_ini_end( validLine, str, options )
% options= struct('lines_ini','2017/2018', 'lines_end','* MEEC')
if ~isempty( strfind( str, options.lines_ini ) )
    validLine= 1;
elseif ~isempty( strfind( str, options.lines_end ) )
    validLine= 0;
else
    % do nothing, keep validLine flag value
end


function iRange= range_of_lines( y, options )
ind1= 1;
ind2= length(y);
for i= 1:length(y)
    str= y{i};
    if ~isempty( strfind( str, options.lines_ini ) )
        ind1= i;
    end
    if ~isempty( strfind( str, options.lines_end ) )
        ind2= i;
    end
end
iRange= ind1+1:ind2-1;
return


% ------------------------------------------------------------------------
function mk_list_of_thesis( fname, options )
% given a list of identifiers of supervisors, try to get all thesis
%   parse lines starting with (or containing?) "Coordenação:"
%   Output tab separated file named *.xls, 4cols, author, thesis, state,
%   supervisors

y= text_read(fname);
iRange= range_of_lines( y, options );
nCoord= 0;
lstStates= {}; % start empty

lst= get_supervisor_list( options );
lstXLS= {'Year', 'State', 'Title', 'Author', 'Supervisors'};
currYear= options.lines_ini;
prevYear= prev_year_calc( currYear );

for i= iRange

    % one line of text is the current data
    str= y{i};

    % update year of the thesis
    if ~isempty( strfind( str, prevYear ) )
        currYear= prevYear;
        prevYear= prev_year_calc( currYear );
    end
    
    % select thesis based on the supervisors
    if ~isempty( strfind( str, 'Coordenação: ' ) ) && has_one_str( str, lst )

        % exclude DRAFT
        stateStr= get_state_string( y{i-2} );
        if strcmp( stateStr, 'DRAFT' )
            continue;
        end
        nCoord= nCoord+1;

        % output
        if ~isfield( options, 'ofname_xls' )
            % visual output
            fprintf( 1, '%d, %s, %s\n%s\n%s\n\n', nCoord, currYear, y{i-2}, y{i-1}, str );
        else
            % prepare output to XLS file
            % save: Year, State, Title, Author, Supervisors
            lstXLS{end+1,1}= currYear;
            lstXLS{end,2}= stateStr;
            lstXLS{end,3}= delete_substrings( y{i-2}, {'* ', [' ' stateStr ' ']} );
            lstXLS{end,4}= delete_substrings( y{i-1}, 'Author: ' );
            lstXLS{end,5}= delete_substrings( str   , 'Coordenação: ' );
        end
    end
end

% save data to the file
if isfield( options, 'ofname_xls' )

    if isfield(options, 'xlsMinLines') && size(lstXLS,1) < options.xlsMinLines+1;
        warning( 'Not enough lines found. NOT writing XLS.' )
        return
    end
    
    if exist( options.ofname_xls, 'file' )
        str= ['Output file "' options.ofname_xls '" exists.'];
        ButtonName = questdlg( [str 'Overwrite it?'] , ...
            'Overwrite file', ...
            'Yes', 'Abort', 'Abort');
        if strcmp( ButtonName, 'Abort' )
            error( [str ' User selected abort.'] );
        end
    end
    
    xlswrite( options.ofname_xls, lstXLS );
    fprintf(1, '-- written file: %s\n', options.ofname_xls );
end

return


function foundFlag= has_one_str( str, lst )
foundFlag= 0;
for i=1:length(lst)
    % if a member of lst is found in str
    if ~isempty( strfind( str, lst{i} ) )
        foundFlag= 1;
        break;
    end
end
return


function prevYear= prev_year_calc( currYear )
% currYear= '2017/2018' -> prevYear= '2016/2017'
dd= sscanf( currYear, '%d/%d' );
prevYear= sprintf( '%d/%d', dd-1 );


function tStr= delete_substrings( tStr, rmStr )

% single string
if ~iscell( rmStr )
    tStr= delete_substrings( tStr, { rmStr } );
    return
end

% multiple strings
for i= 1:length(rmStr)
    tStr= strrep( tStr, rmStr{i}, '' );
end
