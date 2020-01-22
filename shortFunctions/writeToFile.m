% Functon to write into a file: result = writeToFile(filename,varargin).
% Argument filename is a (string) file path.
% Argument varargin are (string) names of variables in workspace.
% Return value is a boolean indicating if content was written into the
% path.
% Written by Satoshi Yamashita.

% This function saves workspace variables but asks for user decision when
% there is a file with the same name already.

function result = writeToFile(filename,varargin)
% Function to write variables into a file.
% result = writeToFile(filename,varargin)
% Return value is a boolean indicating whether the variables were written
% successfully.
result = false;
if nargin < 1 || ~ischar(filename)
    return;
end

array = strsplit(filename,'.');
ext = array(end);
if ~isequal(ext{1},'mat')
    filename = [filename,'.mat'];
end

if exist(filename,'file')
    message = 'File already exists. Do you overwrite it? y/n [n]: ';
    str = input(message,'s');
    if isequal(str,'y')
        if length(varargin) < 1
            evalin('caller',['save(''',filename,''');']);
        else
            str = '';
            for i = 1:length(varargin)
                str = [str,',''',varargin{i},''''];
            end
            evalin('caller',['save(''',filename,'''',str,');']);
        end
        result = true;
    end
else
    if length(varargin) < 1
        evalin('caller',['save(''',filename,''');']);
    else
        str = '';
        for i = 1:length(varargin)
            str = [str,',''',varargin{i},''''];
        end
        evalin('caller',['save(''',filename,'''',str,');']);
    end
    result = true;
end

end