% Common function.
% Written by Satoshi Yamashita.

% This function pop deposited file.

function popDeposit()
str = which('popDeposit.m');
str = str(1:end - length('popDeposit.m'));
format = [str,'deposit.*.mat'];

s = dir(format);
list = {s.name};
count = length(list);

if count > 0
    movefile([str,'deposit.',num2str(count),'.mat'],[str,'deposit.mat']);
else
    if exist([str,'deposit.mat'],'file')
        delete([str,'deposit.mat']);
    end
    disp('Deposit queue is empty.');
end

end
