% Common function.
% Written by Satoshi Yamashita.

% This function push deposited file.

function pushDeposit()
str = which('pushDeposit.m');
str = str(1:end - length('pushDeposit.m'));
format = [str,'deposit*.mat'];

if ~exist([str,'deposit.mat'],'file')
    disp('Nothing in deposit.');
    return;
end

s = dir(format);
list = {s.name};
count = length(list);

if count > 0
    movefile([str,'deposit.mat'],[str,'deposit.',num2str(count),'.mat']);
end

end
