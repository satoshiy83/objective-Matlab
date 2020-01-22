% Short script to indent given text with a tab.
% Written by Satoshi Yamashita.

function result = ss_indent_text(str)
% Function to indent text.
% result = ss_indent_text(str)
% The argument str is a char array.
% Return value is a char array.
    if ~ischar(str)
        result = nan;
        return;
    end
    
    lines = split(str,'\n');
    ttr = '';
    for i = 1:length(lines) - 1
        ttr = [ttr,'\t',lines{i},'\n'];
    end
    ttr = [ttr,'\t',lines{end}];
    
    result = ttr;
end
