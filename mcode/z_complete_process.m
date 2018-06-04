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

% -- complete the information with extra info from fenix

xls2mat(  xls_file, mat_file );

% -- convert to HTML in order to publish

mat2html( mat_file, htm_file, options );
