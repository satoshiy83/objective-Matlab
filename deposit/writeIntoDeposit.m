% Common function.
% Written by Satoshi Yamashita.

% This function saves workspace variables into a shared deposit.

function writeIntoDeposit(varargin)
str = which('writeIntoDeposit.m');
str = [str(1:end - length('writeIntoDeposit.m')),'deposit.mat'];

if length(varargin) < 1
    evalin('caller',['save(''',str,''');']);
else
    vars = '';
    for i = 1:length(varargin)
        vars = [vars,',''',varargin{i},''''];
    end
    evalin('caller',['save(''',str,'''',vars,');']);
end

end
