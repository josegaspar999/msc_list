function word_utils( cmd, fname )
if nargin<1
    main_tst(5)
    return
end

global MSWord

switch cmd
    case 'startWord'
        MSWord= struct('actxWord', startWord, 'wordHandle',[]);

    case 'openFile'
        MSWord.wordHandle= openFile( MSWord.actxWord, fname );

    case 'closeWord'
        if ~isfield(MSWord, 'wordHandle')
            MSWord.wordHandle= [];
        end
        closeWord( MSWord.actxWord, MSWord.wordHandle );

    otherwise
        error('inv cmd')
end


function actxWord= startWord( varargin )
try
    visible= true; %false;
    if numel(varargin)>0
        visible=varargin{1};
    end
    % Start an ActiveX session with Word:
    actxWord = actxserver('Word.Application');
    actxWord.Visible = visible;
catch
    delete(actxWord);
    s=lasterror;
    error(s.message);
end


function wordHandle= openFile( actxWord, fname )
try
    if ~exist(fname,'file');
        % Create new document:
        wordHandle = invoke(actxWord.Documents,'Add');
    else
        % Open existing document:
        wordHandle = invoke(actxWord.Documents,'Open',fname);
    end
catch
    delete(actxWord);
    s=lasterror;
    error(s.message);
end


function closeWord( actxWord, wordHandle )

% Save existing file:
% invoke(wordHandle,'Save');

% Close the word window:
if ~isempty(wordHandle)
    invoke(wordHandle,'Close');
end

% Quit MS Word
invoke(actxWord,'Quit');
% Close Word and terminate ActiveX:
delete(actxWord);
