function y= text_read(filename)

fid = fopen(filename);
if fid<1
    error(['Opening file: ' filename])
end

y = {};
tline = fgetl(fid);
while ischar(tline)
    y{end+1}= tline;
    tline = fgetl(fid);
end
fclose(fid);
