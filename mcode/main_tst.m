function main_tst( tstId, options )
%
% Get thesis supervised at Vislab

% 23.4.2018 (1st ver), 30.5.2018 (moved fns to txt2xls.m), J. Gaspar

if nargin<1
    tstId= 2;
end
if nargin<2
    options= [];
end

switch tstId
    case -1
        % fetch remote data
        dname= mkdname('../data/');
        main_tst_get_data( dname );

    case {0, 1, 2, 3}
        % preliminary tests
        % 0 -> find supervisor Id in the TXT file
        % 1 -> find all possible states of thesis
        % 2,3 -> create XLS file from TXT info (2=display, 3=save)
        txt2xls( tstId );

    case 4
        % first complete test txt->xls->mat->html
        bfname= '../data/180420_v0/online_DEEC_180420.txt';
        z_complete_process( bfname )
        
    case 5
        % browse all MSc
        error('under construction')
        % fetch remote data to a new folder "dname"
        % convert downloaded files to text files
        % list txt files in "dname"
        % run "z_complete_process" for all text files

    otherwise
        error('inv tstId')
end

return; % end of main function


function dname= mkdname( basePath )
if nargin<1,
    basePath= '';
end
[y,m,d,~,~,~]= datevec(now); n=1;
while 1,
   str= sprintf('%02d%02d%02dt%d', ...
      rem(y,100), m, d, n);
   dname= [basePath str];
   if ~exist(dname,'dir'),
      break;
   else
      n= n+1;
   end
end
