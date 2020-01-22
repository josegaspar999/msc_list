function ret_= main_tst( tstId, options )
%
% Get thesis supervised at Vislab

% Some tests:
% main_tst( -1 )    % fetch remote data
% main_tst( 7 )     % do it all test

% 23.4.2018 (1st ver), 30.5.2018 (moved fns to txt2xls.m), J. Gaspar
% 1.11.2018 (tstId 7), J. Gaspar

if nargin<1
    %tstId= 2; % nice default
    tstId= 7; % a do it all test
end
if nargin<2
    options= [];
end

ret= [];

switch tstId
    case -1
        % fetch remote data
        options.downloadFlag= 1;
        dname= main_tst_get_data( '', options );
        ret= dname;

    case {0, 1, 2, 3}
        % preliminary tests
        % 0 -> find supervisor Id in the TXT file
        % 1 -> find all possible states of thesis
        % 2,3 -> create XLS file from TXT info (2=display, 3=save)
        txt2xls( tstId );

    case 4
        % first complete test txt->xls->mat->html
        bfname= '../data/180420_v0/online_DEEC_180420.txt';
        z_complete_process( bfname, options )

    case 5
        % browse all MSc
        %error('under construction')
        % fetch remote data to a new folder "dname", just call
        % >> main_tst(-1)
        
        % convert downloaded files to text files (by hand...)
        conv_html2txt( '../data/181029t1' )

    case 6
        % list txt files in "dname"
        % run "z_complete_process" for all text files
        parse_all_txt( '../data/181029t1' )
        
    case 7
        % try it all
        dname= main_tst_get_data( '', struct('getDnamePrev',1) );
        if isempty( dname )
            % need to download and conv to tst
            dname= main_tst( -1 );
            conv_html2txt( dname )
            %parse_all_txt( dname, options )
        end
        parse_all_txt( dname, options )
        html_mk_single_file( dname, options )
        

    otherwise
        error('inv tstId')
end

if nargout>0
    ret_= ret;
end

return; % end of main function


% ---------------------------------------------------------------------
function conv_html2txt( dname )

p= [dname '/*.htm*'];
d= dir( p );
if length(d)<1
    fprintf(1, 'Warn: no files found from:\n\t%s\n', p);
    return
end

word_utils('startWord')
% word_utils('openFile','');

for i=1:length(d)
    
    % define IO filenames
    fname= [pwd '/' dname '/' d(i).name]; % full path needed
    fname= strrep(fname, '/','\');
    fname2= strrep(fname, '.htm', '.txt');
    fprintf(1, '-- convert from HTML: %s\n', fname);
    fprintf(1, '              to TXT: %s\n', fname2);

    % use MSWord to do the conversion
    word_utils('openFile', fname);
    word_utils('saveAsTxt', fname2 );
end

word_utils('closeWord')

return


% ---------------------------------------------------------------------
function parse_all_txt( dname, options )
% call "z_complete_process.m" for a set of input files *.txt
% to make a set *_vislab_html.txt to (later) cat as a single html file

if nargin<2
    options= [];
end

p= [dname '/*.txt'];
d= dir( p );
if length(d)<1
    fprintf(1, 'Warn: no files found from:\n\t%s\n', p);
    return
end

[~, ret]= main_tst_get_data( dname );
% ret= struct('baseURL', bfname, 'courseList', fname, ...
%     'urlList1', urlList1, 'urlList2', urlList2, ...
%     'ofnames', ofnames);

urlList= {ret.urlList1};

%for i=7
for i=1:length(d)
    if ~isempty( strfind( d(i).name, '_html.txt' ) )
        % exclude files already processed
        continue
    end
    
    id= match_textfname_to_list( d(i).name, ret );
    if id<1
        % file not created by main_tst.m
        warning( ['no match found for: ' d(i).name] )
        continue
    end

    fname= [dname '/' d(i).name]; % relative path
    fname= strrep(fname, '\','/');
    disp(fname)

    options.xlsMinLines= 1;
    options.urlMain= urlList{id};
    disp( options.urlMain )
    options.degree_name= upper(ret(id).courseList);

    z_complete_process( fname, options )
end

return


function id= match_textfname_to_list( textfname, ret )
% ret= struct('baseURL', bfname, 'courseList', fname, ...
%     'urlList1', urlList1, 'urlList2', urlList2, ...
%     'ofnames', ofnames);

% textfname convert to htm filename
htmfname= strrep( textfname, '.txt', '.htm' );

% find the matching
ofnames= {ret.ofnames};

id= 0; % error indicator
for i= 1:length( ofnames )
    fname= ofnames{i};
    if ~isempty( strfind( fname, htmfname ) )
        id= i;
        break
    end
end

return


% ---------------------------------------------------------------------
function html_mk_single_file( dname, options )
% concatenate a set of files *_vislab_html.txt to a single html file
% sort thesis by their dates (last to first)

[y,m,d,~,~,~]= datevec(now);
if isfield(options, 'stdout_global_html') && options.stdout_global_html
    fid= 1;
else
    fname= sprintf('vislab_supervised_msc_%02d%02d%02d.htm', rem(y,100),m,d);
    if isfield(options, 'GH_ext')
        fname= strrep( fname, '.htm', options.GH_ext );
    end
    fname= [dname filesep fname];
    fid= fopen( fname, 'wt' );
end

titleStr=  'MSc Thesis Supervised by Vislab Researchers';
if isfield( options, 'GH_titleStr' )
    titleStr=  options.GH_titleStr;
end
titleStr2= sprintf('Updated %02d.%02d.%02d', d,m,y );
if isfield( options, 'GH_titleStr2' )
    titleStr2=  options.GH_titleStr2;
end

add_header_or_footer( 'header', fid, titleStr, titleStr2 );

d= dir([dname filesep '*_html.txt']);
% d(:).name

% for i=1:length(d)
%     fname= [dname filesep d(i).name];
%     y= text_read( fname );
%     text_write( fid, y );
% end
y= cat_and_sort_by_years( dname, d );
text_write( fid, y );

add_header_or_footer( 'eof', fid, '', '' );

if fid~=1
    fclose(fid);
end

return; % end of main function


function add_header_or_footer( headerOrEOF, fid, titleStr, titleStr2 )
options= struct('add_header_and_eof',1, ...
    'just_header_or_footer', headerOrEOF );
options.title= titleStr;
options.title2= titleStr2;
mat2html([], fid, options)


function y= cat_and_sort_by_years( dname, d )
%
% Sort lines by finding strings as 2019/2020 .. 2006/2007

% dname : str
% d     : ret from dir

% concatenate all files into y
y= {};
for i=1:length(d)
    fname= [dname filesep d(i).name];
    x= text_read( fname );
    y= text_cat( y, x );
end

% sort lines of y by finding years
tosave= ones(1,length(y));
[yr,~,~,~,~,~]= datevec(now);
neword= [];
for i= yr:-1:2007
    str= sprintf('%d/%d', i-1, i);
    jRange= find(tosave);
    for j= jRange
        % if y{j} contains str, then take it to the found list
        if ~isempty( strfind( y{j}, str ) )
            tosave(j)= 0;
            neword(end+1)= j;
        end
    end
end

% check if some lines were not found
jRange= find(tosave);
if ~isempty(jRange)
    warning('one or more lines have no year/nextyear information')
end
neword= [neword jRange];

% finaly reorder y
y= y(neword);
