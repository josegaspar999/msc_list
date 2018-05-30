function ofnames= main_tst_get_data( dname, fnamePrefix )
%
% dname: str : base output directory

if nargin<1
    dname= '../data';
end
if nargin<2
    fnamePrefix= 'z_';
end

% remote data to download
bfname= 'https://fenix.tecnico.ulisboa.pt/cursos/%s/dissertacoes#';
fname= {'ma', 'meaer', 'meambi', 'mebiol', 'mebiom', 'mec', 'meec', ...
    'meft', 'mem', 'memec', 'meq'};

% create output folder if it does not exist
create_base_dir( dname )

% get remote files to the output folder
ofnames= {};
for i=1:length(fname)
    url= sprintf(bfname, fname{i});
    ofname= [dname '/'  fnamePrefix fname{i} '.htm'];
    urlwrite( url, ofname );
    ofnames{end+1}= ofname;
end


function create_base_dir( dname )
if ~exist(dname, 'dir')
    str= input(['-- Create output folder "' dname '" (y/N)? '], 's');
    if strcmpi(str, 'y')
        mkdir( dname );
    end
end
