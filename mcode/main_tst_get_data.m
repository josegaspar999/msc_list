function ret= main_tst_get_data( dname, options )
%
% dname: str : base output directory
% ofnames: list of str : list of URLs to get (or got) data

% 2018/05 (v0), 2018/11 (ret), JG

if nargin<1
    dname= '../data';
end
if nargin<2
    options= [];
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
    'meft', 'mem', 'memec', 'meq'};

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
    str= input(['-- Create output folder "' dname '" (y/N)? '], 's');
    if strcmpi(str, 'y')
        mkdir( dname );
    end
end
