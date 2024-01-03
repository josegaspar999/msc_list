function z_complete_process( bfname, options )
%
% Launch the pipeline to convert information about MSc theses from
% XLS+Fenix url to HTML.
%
% Input:
% bfname :  str : TXT filename to start with
%
% Outputs a set of three files: .XLS, .MAT, .HTML

% May2018, Pedro Vicente, Giovanni Saponaro, J. Gaspar

if nargin<1
    bfname= '../data/180508_v1/z_meec.txt';
end
if length(bfname)>4 && strcmpi( bfname(end-3:end), '.txt')
    % remove .txt extension
    bfname= bfname(1:end-4);
end

if nargin<2
    options= [];
end

% -- make all filenames from a base name

% in0_file = [bfname '.htm'];             % all theses
ini_file = [bfname '.txt'];             % all theses
xls_file = [bfname '_vislab.xls'];      % Vislab only
mat_file = [bfname '_vislab.mat'];      % extra info saved
htm_file = [bfname '_vislab_html.txt']; % html output without header

if isfield(options, 'add_header_and_eof')
    htm_file = [bfname '_vislab_zlist.html']; % html output
end
    
% -- find the set of theses

options.fname= ini_file;
options.ofname_xls= xls_file;
txt2xls(  2, options );
if ~exist( xls_file, 'file' )
    fprintf(1, '** file "%s" not made (empty data found)\n', xls_file);
    return
end

% -- complete the information with extra info from fenix

% matFileMade= xls2mat(  in0_file, xls_file, mat_file, options );
matFileMade= xls2mat(  xls_file, mat_file, options );
if ~matFileMade
    fprintf(1, '** file "%s" not made (empty data found)\n', mat_file);
    return
end

% -- convert to HTML in order to publish

mat2html( mat_file, htm_file, options );
