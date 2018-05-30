function z_complete_process( bfname )
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

ini_file = [bfname '.txt'];             % all theses
xls_file = [bfname '_vislab.xls'];      % Vislab only
mat_file = [bfname '_vislab.mat'];      % extra info saved
htm_file = [bfname '_vislab_html.txt']; % html output

txt2xls(  2, struct('fname', ini_file, 'ofname_xls', xls_file) );
xls2mat(  xls_file, mat_file );
mat2html( mat_file, htm_file );
