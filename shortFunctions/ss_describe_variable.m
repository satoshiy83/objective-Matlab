% Short script to convert Matlab variable to a description.
% Written by Satoshi Yamashita.

function result = ss_describe_variable(variable)
% Function to make a text describing given variable.
% result = ss_describe_variable(variable)
% Return value is a string.
    if isnumeric(variable)
        result = lf_describe_numeric(variable);
    elseif ischar(variable)
        result = lf_describe_char(variable);
    elseif isstring(variable)
        result = lf_describe_string(variable);
    elseif iscell(variable)
        result = lf_describe_cell(variable);
    elseif isstruct(variable)
        result = lf_describe_structure(variable);
    elseif islogical(variable)
        result = lf_describe_logical(variable);
    else
        result = class(variable);
    end
end

%% describe numeric vaiable.
function result = lf_describe_numeric(variable)
    if isempty(variable)
        result = 'empty.';
        return;
    end
    
    siz = size(variable);
    str = ['numeric of size: ',num2str(siz)];
    
    if prod(siz) > 10000
        result = str;
        return;
    end
    
    if length(siz) > 2
        m = zeros(siz(1),siz(2));
        n = siz(1) * siz(2);
        range = 1:n;
        for i = 1:prod(siz(3:end))
            str = [str,'\n',lf_index_of_matrix(siz,i)];
            m(:) = variable(range);
            str = [str,'\n',lf_describe_matrix(m),];
            
            range = range + n;
        end
        
        result = str;
    else
        result = [str,'\n',lf_describe_matrix(variable)];
    end
end
function result = lf_index_of_matrix(siz,depth)
    str = '(:,:,';
    n = mod(depth - 1,siz(3)) + 1;
    str = [str,num2str(n)];
    
    l = length(siz);
    if l > 3
        for i = 4:l
            n = ceil((mod(depth - 1,prod(siz(3:i))) + 1) ...
                / prod(siz(3:i - 1)));
            str = [str,',',num2str(n)];
        end
    end
    str = [str,')'];
    result = str;
end
function result = lf_describe_matrix(variable)
    str = '';
    siz = size(variable);
    for r = 1:siz(1)
        str = [str,lf_describe_number(variable(r,1))];
        if siz(2) < 2
            str = [str,'\n'];
            continue;
        end
        
        for c = 2:siz(2)
            str = [str,'\t',lf_describe_number(variable(r,c))];
        end
        str = [str,'\n'];
    end
    
    if length(str) > 2
        str = str(1:end - 2);
    end
    
    result = str;
end
function result = lf_describe_number(n)
    str = num2str(n);
    
    if length(str) > 7
        if n > 0
            str = sprintf('%.1e',n);
        else
            str = sprintf('%.0e',n);
        end
    end
    
    result = str;
end

%% describe char array.
function result = lf_describe_char(variable)
    result = ['char with length: ',num2str(length(variable)),'\n' ...
        ,variable];
end

%% describe string.
function result = lf_describe_string(variable)
    result = ['string with length: ',num2str(strlength(variable)),'\n' ...
        ,convertStringsToChars(variable)];
end

%% describe cell array.
function result = lf_describe_cell(variable)
    siz = size(variable);
    str = ['cell array of size: ',num2str(siz),' {'];
    
    for i = 1:prod(siz)
        str = [str,'\n',lf_index_of_cell(siz,i),' {\n'];
        ttr = ss_describe_variable(variable{i});
        ttr = ss_indent_text(ttr);
        str = [str,ttr,'\n}'];
    end
    
    result = str;
end
function result = lf_index_of_cell(siz,index)
    str = '(';
    n = mod(index - 1,siz(1)) + 1;
    str = [str,num2str(n)];
    
    l = length(siz);
    if l > 1
        for i = 2:l
            n = ceil((mod(index - 1,prod(siz(1:i))) + 1) ...
                / prod(siz(1:i - 1)));
            str = [str,',',num2str(n)];
        end
    end
    str = [str,')'];
    
    result = str;
end

%% describe structure.
function result = lf_describe_structure(variable)
    str = 'structure with fields {';
    
    names = fieldnames(variable);
    values = struct2cell(variable);
    for i = 1:length(names)
        name = names{i};
        value = values{i};
        str = [str,'\nfield: ',name];
        ttr = ss_describe_variable(value);
        ttr = ss_indent_text(ttr);
        str = [str,'\n',ttr];
    end
    str = [str,'\n}'];
    
    result = str;
end

%% describe logical.
function result = lf_describe_logical(variable)
    siz = size(variable);
    str = ['logical of size: ',num2str(siz)];
    
    if prod(siz) > 10000
        result = str;
        return;
    end
    
    if length(siz) > 2
        m = zeros(siz(1),siz(2));
        n = siz(1) * siz(2);
        range = 1:n;
        for i = 1:prod(siz(3:end))
            str = [str,'\n',lf_index_of_matrix(siz,i)];
            m(:) = variable(range);
            str = [str,'\n',lf_describe_logical_matrix(m),];
            
            range = range + n;
        end
        
        result = str;
    else
        result = [str,'\n',lf_describe_logical_matrix(variable)];
    end
end
function result = lf_describe_logical_matrix(variable)
    str = '';
    siz = size(variable);
    for r = 1:siz(1)
        str = [str,num2str(variable(r,1))];
        if siz(2) < 2
            str = [str,'\n'];
            continue;
        end
        
        for c = 2:siz(2)
            str = [str,'\t',num2str(variable(r,c))];
        end
        str = [str,'\n'];
    end
    
    if length(str) > 2
        str = str(1:end - 2);
    end
    
    result = str;
end
