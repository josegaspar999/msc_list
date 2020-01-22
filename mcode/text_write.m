function text_write(filename, varargin)
%
% Write list of strings (text lines) to a file
%
% filename: string
% varargin: list1, list2, ..., listN : where lists result from text_read
%
% Usage:
% text_write(filename, list1, list2, ..., listN)
%
% Use stdout:
% text_write( 1, ...)

% Feb 2019, J. Gaspar

% see the arguments and open output file (if needed)
if isnumeric(filename)
    fid= filename;
else
    fid = fopen(filename, 'wt');
    if fid<1
        error(['Opening file: ' filename])
    end
end

% write lists to the file
for j=1:length(varargin)
    y= varargin{j};
    for i=1:length(y)
        fprintf(fid, '%s\n', y{i});
    end
end

% close the output file (if needed)
if ~isnumeric(filename)
    fclose(fid);
end
