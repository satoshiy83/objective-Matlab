% Common function.
% Written by Satoshi Yamashita.

% This function clear deposit.

function clearDeposit()
str = which('clearDeposit.m');
str = [str(1:end - length('clearDeposit.m')),'deposit*.mat'];

% if exist(str,'file')
%     delete(str);
% end
delete(str);

end
