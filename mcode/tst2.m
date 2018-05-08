function tst2

bfname= 'https://fenix.tecnico.ulisboa.pt/cursos/%s/dissertacoes#';
fname= {'ma', 'meaer', 'meambi', 'mebiol', 'mebiom', 'mec', 'meec', 'meft', 'mem', 'memec', 'meq'}

for i=1:length(fname)
    url= sprintf(bfname, fname{i});
    ofname= ['z_' fname{i} '.htm'];
    urlwrite( url, ofname )
end
