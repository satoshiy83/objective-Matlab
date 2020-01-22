% Foundation Class: SYObject.
% Written by Satoshi Yamashita.
% The most fundamental superclass of all SY-classes, declaring principal
% methods.

classdef SYObject < handle
properties
end

methods

function obj = init(obj)
% Initialization method.
% obj = init(obj)
    % Implemented by subclasses.
end

function delete(obj)
% Method called when deallocating the object.
% Instances owned only by the object may be deallocated here.
    delete@handle(obj);
end

function dest = copy(~,dest)
% Method to make a 'shallow' copy.
% dest = copy(obj,dest)
% Return value is an instance of the class.
    if nargin < 2
        dest = SYObject;
    end
    % copy@superClass(obj,dest);
    % Subclass of myObject copy all properties to copiedObj here.
end

function result = isnan(~)
% Method to claim that obj is not nan.
% result = isnan(obj)
    result = false;
end

function result = respondsToSelector(obj,selector)
% Method to check if having the given selector.
% result = respondsToSelector(obj,selector)
% The argument selector is a string or function handle.
% Return value is a boolean.
    if isa(selector,'function_handle')
        selector = func2str(selector);
    end
    array = methods(obj);
    result = any(strcmp(array,selector));
end

function result = isEqual(obj,pbj)
% Method to compare objects contents.
% result = isEqual(obj,pbj)
% Return value is a boolean.
    result = obj == pbj;
end

function result = description(obj)
% Method to give a simple description of the instance.
% result = description(obj)
% Return value is a string.
    result = class(obj);
end

end
end
