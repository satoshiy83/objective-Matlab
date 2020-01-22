% Foundation Class: SYData < SYObject.
% Written by Satoshi Yamashita.
% Fundamental Class of data which stores variable and provides synchronous
% use of it among multiple objects.

classdef SYData < SYObject
properties (Constant)
    EventNameVarChanged = 'SYDataVarChanged';
end
properties
    var = [];
end

methods
function obj = SYData(variable)
% Foundation class of data container.
% obj = SYData(variable)
% A property var retains the content.
    if nargin < 1
        return;
    end
    
    obj.var = variable;
end
function obj = initWithVariable(obj,variable)
% Initializing method with variable.
% obj = initWithVariable(obj,variable)
% The argument variable should be a Matlab variable such as numeric, array,
% or char.
    obj.var = variable;
end
function obj = initWithData(obj,data)
% Initializing method with an SYData instance.
% obj = initWithData(obj,data)
    obj.var = data.var;
end
function obj = initWithContentsOfFile(obj,name)
% Initializing method with a file path.
% obj = initWithContentsOfFile(obj,name)
    if exist(name,'file') == 2
        fileInfo = who('-file',name);
        if length(fileInfo) == 1 && ismember('bytes',fileInfo)
            load(name,'bytes');
            obj.var = bytes;
        else
            s = load(name);
            obj.var = s;
        end
    else
        disp(['No ',name,' file was found.']);
    end
end

function dest = copy(obj,dest)
% Method to make a 'shallow' copy.
% dest = copy(obj,dest)
% Return value is an instance of the class.
    if nargin < 2
        dest = SYData;
    end
    copy@SYObject(obj,dest);
    
    dest.var = obj.var;
end

function set.var(obj,variable)
    obj.var = variable;
    obj.setVar(variable);
end
function setVar(obj,variable)
% Bypass method from set.var.
% Do not call directly.
    if isa(variable,'SYObject')
        disp(['Warning: SYData should not contain an objective class ',...
            'instance. You should use SYarray instead.']);
    end
    
%     notification = SYNotification;
%     notification.initWithName(SYData.EventNameVarChanged,obj);
%     defaultCenter = SYNotificationCenter.defaultCenter;
%     defaultCenter.postNotification(notification);
end

function result = isEqual(obj,pbj)
% Method to compare objects contents.
% result = isEqual(obj,pbj)
% Return value is a boolean.
    result = obj.isEqualToData(pbj);
end
function result = isEqualToData(obj,pbj)
% Method to compare bytes of objects.
% result = isEqualToData(obj,pbj)
% Argument pbj is an SYData instance.
% Return value is a boolean.
    result = false;
    if ~isa(pbj,'SYData')
        return;
    end
    
    if isa(obj.var,'SYObject')
        result = obj.var.isEqual(pbj.var);
    else
        if ~strcmp(class(obj.var),class(pbj.var))
            return;
        end
        if iscell(obj.var)
            array = SYArray(obj.var{:});
            brray = SYArray(pbj.var{:});
            result = array.isEqualToArray(brray);
        else
            result = obj.var == pbj.var;
        end
    end
end

function result = description(obj)
% Method to give a simple description of the instance.
% result = description(obj)
% Return value is a string.
    str = [class(obj),' with {\n'];
    if isa(obj.var,'SYObject')
        ttr = obj.var.description;
    else
        ttr = ss_describe_variable(obj.var);
    end
    ttr = ss_indent_text(ttr);
    str = [str,ttr,'\n}'];
    
    result = str;
end

function result = writeToFile(obj,name)
% Method to export a content of the instance.
% result = writeToFile(obj,name)
% The argument name is string of file path.
    bytes = obj.var;
    result = writeToFile(name,'bytes');
end

end
end