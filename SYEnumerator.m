% Foundation Class: SYEnumerator < SYObject
% Written by Satoshi Yamashita.
% Fundamental Class enmuerating entries in an SYArray and return nan at
% the end.

classdef SYEnumerator < SYObject
properties
    array = nan; % SYArray.
    index = nan; % double.
end

methods
function obj = SYEnumerator(array_)
% Foundation class to enumerate entries in an SYArray instance.
% obj = SYEnumerator(array_)
% Argument array_ is an SYArray instance.
    if nargin > 0
        obj = obj.initWithArray(array_);
    end
end
function obj = initWithArray(obj,array_)
% Method to initialize SYEnumerator instance with SYArray instance.
% obj = initWithArray(obj,array_)
% Argument array_ is an SYArray instance.
% Return value is an SYEnumerator instance.
    if ~isa(array_,'SYArray')
        disp('The array must be an SYArray instance.');
        obj = nan;
        return;
    end
    
    obj.array = array_.copy;
    obj.index = 1;
end

function result = nextObject(obj)
% Method returning a next object in the array.
% result = nextObject(obj)
    if obj.index > obj.array.count
        result = nan;
    else
        result = obj.array.objectAtIndex(obj.index);
    end
    
    obj.index = obj.index + 1;
end
function result = isNextObjectNan(obj)
% Method to check if enumeration passed all objects in the array.
% result = isNextObjectNan(obj)
% Return value is true if all objects were enumerated already.
    if obj.index > obj.array.count
        result = true;
    else
        result = false;
    end
end

end
end
