% Launch the pipeline to convert information about MSc theses from
% XLS+Fénix url to HTML.
%
% Pedro Vicente, Giovanni Saponaro

bfname= '../data/online_DEEC_180420';

ini_file = [bfname '.txt'];             % all theses
xls_file = [bfname '_vislab.xls'];      % Vislab only
mat_file = [bfname '_vislab.mat'];      % extra info saved
htm_file = [bfname '_vislab_html.txt']; % html output

tst( 2, struct('fname', ini_file, 'ofname_xls', xls_file) );
xls2mat(  xls_file, mat_file );
mat2html( mat_file, htm_file );
