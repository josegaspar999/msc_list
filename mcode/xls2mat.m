function xls2mat(xls_file, mat_file)
% XLS2MAT  Convert information about MSc theses from XLS to MAT.
%
% Pedro Vicente, Giovanni Saponaro

%% read Excel
t = readtable(xls_file);

url = 'https://fenix.tecnico.ulisboa.pt/cursos/meec/dissertacoes#';
html = urlread(url);
html2 = regexprep(html,' +',' '); % Remove space
html2 = regexprep(html2,'&#39;','''');
html2 = regexprep(html2,'&quot','"');

meecprefix = 'https://fenix.tecnico.ulisboa.pt/cursos/meec/';
t = readtable(xls_file);

%% convert from table to struct
s = table2struct(t, 'ToScalar',true);
w=width(t);
miss = [];
for i=1: height(t)
    title(i) = table2cell(t(i,3)); 
    k = strfind(html2,title(i));
    if(isempty(k))
        miss = [miss i];
        continue
    end
    tempstr = html2(k-50:k);
    tmpiniturl = strfind(tempstr,'<');
    tmpendurl = strfind(tempstr,'>');
    initurl = tmpiniturl(end);
    tmpendurl = tmpendurl(end);
    
    url = strcat(meecprefix,tempstr(initurl+9:tmpendurl-2)); % remove <a href=" and ">
    t(i,w+1) = cell2table({url});
end

t.Properties.VariableNames([6]) = {'url'};

%% convert from table to struct
s = table2struct(t, 'ToScalar',true);

%% create scalar structure variable, initialize fields like in struct
[msc.Year] = s.Year;
[msc.State] = s.State;
[msc.Title] = s.Title;
[msc.Author] = s.Author;
[msc.Supervisors] = s.Supervisors;
[msc.url] = s.url;

%% save msc variable to MAT-file
save(mat_file, '-struct', 'msc');