function ret_= main_tst( tstId, options )
%
% Get thesis supervised at Vislab

% 23.4.2018 (1st ver), 30.5.2018 (moved fns to txt2xls.m), J. Gaspar
% 1.11.2018 (tstId 7), J. Gaspar

if nargin<1
    tstId= 2; % nice default
    %tstId= 7; % a do it all test
end
if nargin<2
    options= [];
end

ret= [];

switch tstId
    case -1
        % fetch remote data
        dname= mkdname('../data/');
        main_tst_get_data( dname, struct('downloadFlag',1) );
        ret= struct('dname', dname);

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
        ret= main_tst(-1);
        conv_html2txt( ret.dname )
        parse_all_txt( ret.dname )
        

    otherwise
        error('inv tstId')
end

if nargout>0
    ret_= ret;
end

return; % end of main function


function dname= mkdname( basePath )
if nargin<1,
    basePath= '';
end
[y,m,d,~,~,~]= datevec(now); n=1;
while 1,
    str= sprintf('%02d%02d%02dt%d', ...
        rem(y,100), m, d, n);
    dname= [basePath str];
    if ~exist(dname,'dir'),
        break;
    else
        n= n+1;
    end
end


function fname2= htm2txt_fname( fname )
fname2= strrep(fname, '.htm', '.txt');


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
    fname= [pwd '/' dname '/' d(i).name]; % full path needed
    fname= strrep(fname, '/','\');
    disp( fname );
    % use MSWord to do the conversion
    word_utils('openFile', fname);
    word_utils('saveAsTxt', htm2txt_fname( fname ) );
end

word_utils('closeWord')

return


function parse_all_txt( dname )

p= [dname '/*.txt'];
d= dir( p );
if length(d)<1
    fprintf(1, 'Warn: no files found from:\n\t%s\n', p);
    return
end

ret= main_tst_get_data( dname );
% ret= struct('baseURL', bfname, 'courseList', fname, ...
%     'urlList1', urlList1, 'urlList2', urlList2, ...
%     'ofnames', ofnames);

options= [];
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
