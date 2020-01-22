% Short script to compare strings by alphabetical order.
% Written by Satoshi Yamashita.
% Return value is -1 if the first argument is smaller than the second
% argument, 0 if the two argurments are equal, 1 if the first arguments is
% larger than the second argument, and -1 if the arguments are not string
% nor char.

function result = ss_compare_string(str,ttr)
% Funtion to compare strings by alphabetical order.
% result = ss_compare_string(str,ttr)
% Return value is -1 if the first argument is smaller than the second, 0 if
% equal, 1 if first is larger than second.
    if ~(ischar(str) || isstring(str)) || ...
            ~(ischar(ttr) || isstring(ttr))
        result = -1;
        return;
    end
    
    if ischar(str)
        str = string(str);
    elseif numel(str) > 1
        str = str';
        str = join(str(:));
    end
    if ischar(ttr)
        ttr = string(ttr);
    elseif numel(ttr) > 1
        ttr = ttr';
        ttr = join(ttr(:));
    end
    
    if str == ttr
        result = 0;
    elseif str < ttr
        result = 1;
    else
        result = -1;
    end
end
