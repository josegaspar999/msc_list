function matFileMade= xls2mat(xls_file, mat_file, options)
% XLS2MAT  Convert information about MSc theses from XLS to MAT.
%
% 2018/05 (orig ver), Pedro Vicente, Giovanni Saponaro
% 2018/11 (ret flag & options), JG

if nargin<3
    options= [];
end

%% read Excel
t = readtable(xls_file);

meecprefix = mkDefault('https://fenix.tecnico.ulisboa.pt/cursos/meec/',options,'urlMain');
url = [meecprefix mkDefault( 'dissertacoes#', options, 'urlSuffix' )];

html = urlread(url);
html2 = regexprep(html,' +',' '); % Remove space
html2 = regexprep(html2,'&#39;','''');
html2 = regexprep(html2,'&quot','"');

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

if isempty(t)
    matFileMade= 0;
else
    t.Properties.VariableNames([6]) = {'url'};

    % convert from table to struct
    s = table2struct(t, 'ToScalar',true);
    
    % create scalar structure variable, initialize fields like in struct
    [msc.Year] = s.Year;
    [msc.State] = s.State;
    [msc.Title] = s.Title;
    [msc.Author] = s.Author;
    [msc.Supervisors] = s.Supervisors;
    [msc.url] = s.url;
    
    %% save msc variable to MAT-file
    save(mat_file, '-struct', 'msc');
    matFileMade= 1;
end


function ret = mkDefault( defValue, options, fieldName)
if isfield( options, fieldName )
    ret= getfield( options, fieldName );
else
    ret= defValue;
end
