function [dname, ret]= main_tst_get_data( dname, options )
%
% Download IST MSc thesis titles, authors and supervisors data
%
% By default, returns a folder name to get/use data based on today's date.
% By default returns a novel folder name.
% Return list of addresses to download data.
% By default does not download data.
%
% dname: str : base output directory
% ofnames: list of str : list of URLs to get (or got) data

% Usage examples:
% dname= main_tst_get_data( '', struct('getDnamePrev',1) );
% options.downloadFlag= 1; dname= main_tst_get_data( '', options );
% [~, ret]= main_tst_get_data( dname );
% ret= struct('baseURL', bfname, 'courseList', fname, ...
%     'urlList1', urlList1, 'urlList2', urlList2, ...
%     'ofnames', ofnames);

% 2018/05 (v0), 2018/11 (ret), JG
% 2020/01 (mk & return dname), JG
% 2023/12 (alternative usages), JG

if nargin<2
    options= [];
end
if nargin>=1 && isnumeric(dname)
    main_tst_get_data_alternative_usages( dname, options );
    return
end
if nargin<1 || isempty(dname)
    %dname= '../data';
    [dname, dnamePrev]= mkdname('../data/');
end

if isfield( options, 'getDnamePrev' ) && options.getDnamePrev
    % a way to see if download was done already today
    ret= [];
    if options.getDnamePrev==2 && isempty(dnamePrev)
        % do nothing
        return
    end
    dname= dnamePrev;
    return
end

fnamePrefix= 'z_';
if isfield(options, 'fnamePrefix')
    fnamePrefix= options.fnamePrefix;
end
downloadFlag= 0;
if isfield(options, 'downloadFlag')
    downloadFlag= options.downloadFlag;
end

% remote data to download
bfname1= 'https://fenix.tecnico.ulisboa.pt/cursos/%s/';
%bfname= [bfname1 'dissertacoes#'];
bfname= [bfname1 'dissertacoes'];
fname= {'ma', 'meaer', 'meaer21', 'meambi', 'mebiol', 'mebiom', 'mec', 'meec', 'meec21', ...
    'meft', 'mem', 'memec', 'meq', 'meic-a'};

% create output folder if it does not exist
create_base_dir( dname )

% get remote files to the output folder
urlList1= {};
urlList2= {};
ofnames= {};
for i=1:length(fname)
    
    % define URLs and downloaded filenames
    urlList1{end+1}= sprintf(bfname1, fname{i});

    url= sprintf(bfname, fname{i});
    urlList2{end+1}= url;

    ofname= [dname '/'  fnamePrefix fname{i} '.htm'];
    ofnames{end+1}= ofname;
    
    % do the download
    if downloadFlag
        try
            %urlwrite( url, ofname );
            websave( ofname, url );
        catch
            fprintf(1, '** failed:\n%s\n   to:\n%s\n', ...
                url, ofname );
        end
    end
end

% return information for further (eventual) usage
ret= struct('baseURL', bfname, 'courseList', fname, ...
    'urlList1', urlList1, 'urlList2', urlList2, ...
    'ofnames', ofnames);

return; % end of main function


function create_base_dir( dname )
if ~exist(dname, 'dir')
    str= ['-- Create output folder "' dname '" (y/N)? '];
    if 0
        str= input(str, 's');
        if strcmpi(str, 'y')
            mkdir( dname );
        end
    else
        str= questdlg(str, 'create folder', 'Yes', 'No', 'No');
        if strcmp( str, 'Yes' )
            mkdir( dname );
        end
    end
end


function [dname, dnamePrev]= mkdname( basePath )
if nargin<1,
    basePath= '';
end
if nargin<2
    options= [];
end

dnamePrev= '';
[y,m,d,~,~,~]= datevec(now); n=1;
while 1,
    str= sprintf('%02d%02d%02dt%d', ...
        rem(y,100), m, d, n);
    dname= [basePath str];
    if ~exist(dname,'dir'),
        break;
    else
        dnamePrev= dname;
        n= n+1;
    end
end


function main_tst_get_data_alternative_usages( dname, options )
% code comes here if dname isnumeric
% example: main_tst_get_data(-1)

% error('under construction');

dname= main_tst_get_data('', struct('getDnamePrev',2));
if ~exist(dname, 'dir')
    error('folder not found "%s", please mk the folder and download the data', dname);
end

% given the dname, check max date in files
% see "function str= find_max_year_nextyear( fname )" in "txt2xls.m"

d= dir([dname '/*.txt']);
for i= 1:length(d)
    if length(find(d(i).name=='_')) > 1
        % accept just one "_", e.g. z_meec21.txt and not z_meec21_vislab_html.txt
        continue
    end
    fname= [dname '/' d(i).name];
    str= find_max_year_nextyear( fname );
    fprintf(1, '%s \t%s\n', str, fname);
end

return


function str= find_max_year_nextyear( fname )
% there is not data older than 2006/2007

tlines= text_read( fname );

[y,~,~,~,~,~]= datevec(now);
y= y+1; % consider also the next year, i.e. year after datevec(now)
for i= y:-1:2007
    str= sprintf('%d/%d', i-1, i);
    for j= 1:length(tlines)
        if ~isempty( strfind( tlines{j}, str ) )
            % found string, just return, "str" is defined
            return
        end
    end
end

warning('Not found string year/nextyear in file "%s"', fname);
