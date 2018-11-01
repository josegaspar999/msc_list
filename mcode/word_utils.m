function word_utils( cmd, fname )
if nargin<1
    main_tst(5)
    return
end

global MSWord

switch cmd
    case 'startWord'
        MSWord= struct('actxWord', [], 'wordHandle', []);
        MSWord.actxWord= startWord;

    case 'openFile'
        if isempty(MSWord.actxWord), warning('empty actxWord'); return; end
        MSWord.wordHandle= openFile( MSWord.actxWord, fname );
        
    case 'saveAsTxt'
        if isempty(MSWord.actxWord), warning('empty actxWord'); return; end
        if isempty(MSWord.wordHandle), warning('empty wordHandle'); return; end
        saveAsTxt( MSWord.wordHandle, fname );

    case 'closeWord'
        if isempty(MSWord.actxWord), warning('empty actxWord'); return; end
        if ~isfield(MSWord, 'wordHandle')
            MSWord.wordHandle= [];
        end
        closeWord( MSWord.actxWord, MSWord.wordHandle );

    otherwise
        error('inv cmd')
end


function actxWord= startWord( varargin )
try
    visible= false; % true;
    if numel(varargin)>0
        visible=varargin{1};
    end
    % Start an ActiveX session with Word:
    actxWord = actxserver('Word.Application');
    actxWord.Visible = visible;
catch
    delete(actxWord);
    s=lasterror;
    %error(s.message);
    warning(s.message);
    actxWord= [];
end


function wordHandle= openFile( actxWord, fname )
try
    if ~exist(fname,'file');
        % Create new document:
        wordHandle = invoke(actxWord.Documents,'Add');
    else
        % Open existing document:
        %wordHandle = invoke(actxWord.Documents,'Open',fname);
        wordHandle = invoke( actxWord.Documents, 'Open', fname, 0 );
    end
catch
    delete(actxWord);
    s=lasterror;
    error(s.message);
end


function saveAsTxt( wordHandle, fname )
try
    invoke( wordHandle, 'SaveAs2', fname, 7 );
catch
    s=lasterror;
    %error(s.message);
    warning(s.message);
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
