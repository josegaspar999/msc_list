function mat2html(mat_file, htm_file, options)
% MAT2HTML  Convert information about MSc theses from MAT to HTML.
%
% May2018 Giovanni Saponaro, 4Jun18 (more options) J. Gaspar

if nargin<3
    options= [];
end
if isfield(options, 'just_header_or_footer')
    print_header_or_eof( options.just_header_or_footer, ...
        htm_file, options );
    return
end

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

% -- print the desired string (1 line) from all the cells of each line of the cell array
%
fid= 1;
if ~isempty(htm_file)
    fid= fopen( htm_file, 'wt' );
end

% write header (allow standallone file)
%
print_header_or_eof( 'header', fid, options );

% write data
%
cellfun(@(t,a,y,u) fprintf(fid,fmt,t,a,y,u), m.Author, m.Title, m.Year, m.url);

% end file
%
print_header_or_eof( 'eof', fid, options );

if fid~=1
    fclose(fid);
end


function print_header_or_eof( headerOrEOF, fid, options )
if ~isfield(options, 'add_header_and_eof')
    return
end

if strcmp(headerOrEOF, 'header')
    fprintf(fid, '<html><body>\n');
    if isfield(options, 'title')
        fprintf(fid, '<h1 align="center"><i>%s</i></h1>\n', options.title);
    end
    if isfield(options, 'title2')
        fprintf(fid, '<h2 align="center"><i>%s</i></h2>\n', options.title2);
    end
    fprintf(fid, '<ul>\n');
end

if strcmp(headerOrEOF, 'eof')
    fprintf(fid, '</ul>\n');
    fprintf(fid, '</body></html>\n');
end
