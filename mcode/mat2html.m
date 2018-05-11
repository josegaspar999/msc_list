function mat2html(mat_file, htm_file)
% MAT2HTML  Convert information about MSc theses from MAT to HTML.
%
% Giovanni Saponaro

% load MAT-file containing information about MSc theses
m = load(mat_file);

% compute mask of invalid theses IDs (the ones with State != 'EVALUATED')
invalid = find(~strcmp(m.State, 'EVALUATED'));

% delete invalid theses. TODO: do it when saving the MAT-file
for t = invalid
    fprintf('thesis %d is not EVALUATED -> will delete it\n', t);
    % delete all fields of t'th entry from m
    m.Year(t) = [];
    m.State(t) = [];
    m.Title(t) = [];
    m.Author(t) = [];
    m.Supervisors(t) = [];
    m.url(t) = [];
end

% fields with constant value
degree_name = 'Electrical and Computer Engineering';
uni_name = 'IST';

% custom format for VisLab WordPress HTML
fmt = ['\t<li><i><b>', ... % square brackets [] to preserve whitespace
    '%s', ... % Author
    '</b></i>, ', ...
    '%s, ', ... % Title
    'MSc Thesis, ', degree_name, ', ', uni_name, ' - ', ...
    '%s. ', ... % Year
     '<a HREF="', ... % HREF capitals to prevent MATLAB to parse links
     '%s', ... % url of thesis information page
     '">More information</a>.</li>\n'];

% print the desired string from all the cells in the cell array
fid= 1;
if ~isempty(htm_file)
    fid= fopen( htm_file, 'wt' );
end
cellfun(@(t,a,y,u) fprintf(fid,fmt,t,a,y,u), m.Author, m.Title, m.Year, m.url);
if fid~=1
    fclose(fid);
end
