function [dname, ret]= main_tst_get_data( dname, options )
%
% dname: str : base output directory
% ofnames: list of str : list of URLs to get (or got) data

% 2018/05 (v0), 2018/11 (ret), JG
% 2020/01 (mk dname), JG

if nargin<1
    dname= '../data';
end
if nargin<2
    options= [];
end

if isempty(dname)
    [dname, dnamePrev]= mkdname('../data/');
end
if isfield( options, 'getDnamePrev' ) && options.getDnamePrev
    % a way to see if download was done already today
    dname= dnamePrev;
    ret= [];
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
bfname= [bfname1 'dissertacoes#'];
fname= {'ma', 'meaer', 'meambi', 'mebiol', 'mebiom', 'mec', 'meec', ...
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
        urlwrite( url, ofname );
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
