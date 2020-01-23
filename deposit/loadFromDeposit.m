% Common function.
% Written by Satoshi Yamashita.

% This function load variables from a shared deposit.

function loadFromDeposit()
str = which('loadFromDeposit.m');
str = [str(1:end - length('loadFromDeposit.m')),'deposit.mat'];

if ~exist(str,'file')
    disp('Nothing in deposit.');
    return;
end

evalin('caller',['load(''',str,''');']);

end
