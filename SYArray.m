% Foundation Class: SYArray < SYObject
% Written by Satoshi Yamashita.
% Fundamental Class of array which store variables and objects in an array.
% SYArray cannot store nan.

classdef SYArray < SYObject
properties (Constant)
    DataTypeMatlabNative = 0;
    DataTypeSYObjectNoData = 1;
    DataTypeSYObjectWithData= 2;
    DataTypeSYData = 3;
end
properties
    elements = nan;
end

methods
function obj = SYArray(varargin)
% Foundation class of data container in an array.
% obj = SYArray(varargin)
    indices = ones(1,length(varargin),'logical');
    for i = 1:length(varargin)
        if isnumeric(varargin{i}) && length(varargin{i}) == 1 && ...
                isnan(varargin{i})
            indices(i) = false;
        end
    end
    
    obj.elements = varargin(indices);
end
function obj = initWithData(obj,data)
% Initializing method with an SYData instance.
% obj = initWithData(obj,data)
    obj.removeAllObjects;
    
    array = data.var;
    for i = 1:size(array,1)
        switch array{i,2}
            case obj.DataTypeMatlabNative
                obj.addObject(array{i,3});
            case obj.DataTypeSYObjectNoData
                fh = str2func(array{i,1});
                pbj = fh();
                obj.addObject(pbj);
            case obj.DataTypeSYObjectWithData
                fh = str2func(array{i,1});
                pbj = fh();
                pbj.initWithData(SYData(array{i,3}));
                obj.addObject(pbj);
            case obj.DataTypeSYData
                fh = str2func(array{i,1});
                pbj = fh(array{i,3});
                obj.addObject(pbj);
            otherwise
                obj.addObject(array{i,3});
        end
    end
end
function obj = initWithArray(obj,array,copyItems)
% Initializing method with an SYArray instance.
% obj = initWithArray(obj,array,copyItems)
% The argument copyItems is a boolean telling whether to copy items in the
% array.
    if ~isa(array,'SYArray')
        disp('The argument array must be an SYArray instance.');
        return;
    end
    
    if copyItems
        for i = 1:array.count
            pbj = array.objectAtIndex(i);
            if isa(pbj,'SYObject')
                pbj = pbj.copy;
            end
            obj.addObject(pbj);
        end
    else
        obj.elements = array.elements;
    end
end
function dest = copy(obj,dest)
% Method to make a 'shallow' copy.
% dest = copy(obj,dest)
% Return value is an instance of the class.
    if nargin < 2
        dest = SYArray;
    end
    copy@SYObject(obj,dest);
    
    dest.elements = obj.elements;
end

function result = data(obj)
% Method to convert the instance to an SYData instance.
% result = data(obj)
% Return value is an SYData instance.
    array = cell(obj.count,3);
    for i = 1:obj.count
        pbj = obj.objectAtIndex(i);
        array{i,1} = class(pbj);
        if isa(pbj,'SYObject')
            if isa(pbj,'SYData')
                array{i,2} = obj.DataTypeSYData;
                pbj = pbj.var;
            elseif pbj.respondsToSelector('data') && ...
                    pbj.respondsToSelector('initWithData')
                array{i,2} = obj.DataTypeSYObjectWithData;
                pbj = pbj.data.var;
            else
                array{i,2} = obj.DataTypeSYObjectNoData;
                pbj = nan;
            end
        else
            array{i,2} = obj.DataTypeMatlabNative;
        end
        array{i,3} = pbj;
    end
    result = SYData(array);
end

function result = description(obj)
% Method to give a simple description of the instance.
% result = description(obj)
% Return value is a string.
    str = [class(obj),' with ',num2str(obj.count),' item(s) {'];
    
    enumerator = SYEnumerator;
    enumerator.initWithArray(obj);
    i = 1;
    while ~enumerator.isNextObjectNan
        str = [str,'\nitem ',num2str(i)];
        item = enumerator.nextObject;
        if isa(item,'SYObject')
            ttr = item.description;
        else
            ttr = ss_describe_variable(item);
        end
        ttr = ss_indent_text(ttr);
        str = [str,'\n',ttr];
        
        i = i + 1;
    end
    str = [str,'\n}'];
    
    result = str;
end


function result = count(obj)
% Method returning number of itmes in the array.
% result = count(obj)
    result = length(obj.elements);
end

function result = objectAtIndex(obj,index)
% Method returning item in the array at the index.
% result = objectAtIndex(obj,index)
    result = obj.elements{index};
end
function result = objectsAtIndexes(obj,indices)
% Method returning a sub-array containing objects at indices.
% result = objectsAtIndexes(obj,indices)
    if islogical(indices) && length(indices) ~= obj.count
        indices = find(indices);
    end
    if isnumeric(indices)
        jndices = indices < 1 | indices > obj.count;
        indices(jndices) = [];
    end
    
    result = SYArray(obj.elements{indices});
end
function result = indexOfObject(obj,object)
% Method returning indices of object in the array.
% result = indexOfObject(obj,object)
% Return value is a vector.
    if obj.count < 1
        result = [];
        return;
    end
    
    array = zeros(obj.count,1,'logical');
    for i = 1:obj.count
        if iscell(obj.objectAtIndex(i)) && iscell(object)
            a = obj.objectAtIndex(i);
            a = SYArray(a{:});
            b = SYArray(object{:});
            array(i) = a.isEqual(b);
        elseif ~iscell(obj.objectAtIndex(i)) && ~iscell(object) && ...
                length(obj.objectAtIndex(i)) == length(object)
            a = obj.objectAtIndex(i) == object;
            array(i) = all(a(:));
        end
    end
    result = find(array);
end
function result = lastObject(obj)
% Method returning an item at the end of the array.
% result = lastObject(obj)
    if obj.count < 1
        result = nan;
    else
        result = obj.elements{end};
    end
end

function addObject(obj,element)
% Method to add an item at the end of the array.
% addObject(obj,element)
    if isnumeric(element) && length(element) == 1 && isnan(element)
        return;
    end
    
    obj.elements{obj.count + 1} = element;
end
function addObjects(obj,varargin)
% Method to add items at the end of the array.
% addObjects(obj,varargin)
% The argument can be multiple.
    if nargin < 2
        return;
    end
    
    for i = 1:length(varargin)
        obj.addObject(varargin{i});
    end
end
function addObjectsFromArray(obj,array)
% Method to add items from another SYArray instance.
% addObjectsFromArray(obj,array)
    if nargin < 2 || ~isa(array,'SYArray') || array.count < 1
        return;
    end
    
    for i = 1:array.count
        obj.addObject(array.objectAtIndex(i));
    end
end
function insertObjectAtIndex(obj,element,index)
% Method to insert an item with the argument element at the index.
% insertObjectAtIndex(obj,element,index)
    if isnumeric(element) && length(element) == 1 && isnan(element)
        return;
    end
    
    if index > obj.count
        obj.addObject(element)
    elseif index == 1
        obj.elements = cat(2,{element},obj.elements);
    else
        obj.elements = cat(2,obj.elements(1:index-1), ...
            {element}, ...
            obj.elements(index:end));
    end
end
function replaceObjectAtIndex(obj,element,index)
% Method to replace an item with the argument element at the index.
% replaceObjectAtIndex(obj,element,index)
    if isnumeric(element) && length(element) == 1 && isnan(element)
        return;
    end
    
    if index > obj.count
        obj.addObject(element);
    else
        obj.elements{index} = element;
    end
end
function removeAllObjects(obj)
% Method to clear the array.
% removeAllObjects(obj)
    obj.elements = {};
end
function removeObject(obj,object)
% Method to remove an item.
% removeObject(obj,object)
    indices = obj.indexOfObject(object);
    if ~isempty(indices)
        obj.elements(indices) = [];
    end
end
function removeObjectAtIndex(obj,index)
% Method to remove an item at the index.
% removeObjectAtIndex(obj,index)
    if index < 1 || index > obj.count
        return;
    end
    obj.elements(index) = [];
end

function result = isEqual(obj,pbj)
% Method to compare objects contents.
% result = isEqual(obj,pbj)
% Return value is a boolean.
    result = obj.isEqualToArray(pbj);
end
function result = isEqualToArray(obj,pbj)
% Method to compare the array with another SYArray instance.
% result = isEqualToArray(obj,pbj)
% Return value is a boolean.
    result = false;
    if ~isa(pbj,'SYArray') || obj.count ~= pbj.count
        return;
    end
    
    for i = 1:obj.count
        a = obj.objectAtIndex(i);
        b = pbj.objectAtIndex(i);
        if isa(a,'SYObject')
            if ~a.isEqual(b)
                return;
            end
        else
            if ~strcmp(class(a),class(b))
                return;
            end
            if iscell(a)
                array = SYArray(a{:});
                brray = SYArray(b{:});
                if ~array.isEqualToArray(brray)
                    return;
                end
            else
                if length(a) ~= length(b) || any(a ~= b)
                    return;
                end
            end
        end
    end
    result = true;
end

function [result1,result2] = sortedArrayWithUsingComparator(obj,comparator)
% Method to sort array with comparator.
% [result1,result2] = sortedArrayWithUsingComparator(obj,comparator)
% Argument comparator is a function hundle comparing two object and
% returning boolean.
% Return values are SYArray and optionally indices for sorting.
    if obj.count < 1
        result1 = SYArray;
        result2 = [];
        return;
    end
    
    enumerator = SYEnumerator(obj);
    array = SYArray;
    array.addObject(enumerator.nextObject);
    indices = 1; index = 2;
    
    while ~enumerator.isNextObjectNan
        pbj = enumerator.nextObject;
        flag = true;
        for i = 1:array.count
            qbj = array.objectAtIndex(i);
            f = comparator(pbj,qbj);
            if f == 1
                array.insertObjectAtIndex(pbj,i);
                if i == 1
                    indices = cat(2,index,indices);
                else
                    indices = cat(2,indices(1:i-1),index,indices(i:end));
                end
                flag = false;
                break;
            end
        end
        if flag
            array.addObject(pbj);
            indices = cat(2,indices,index);
        end
        index = index + 1;
    end
    result1 = array;
    result2 = indices;
end

function makeObjectsPerformSelector(obj,selector)
% Method to make objects in the arry executing the given selector.
% makeObjectsPerformSelector(obj,selector)
% Argument selector is a function hundle.
% The objects which are subclasses of SYObject and can respond to the
% selector execute the selector.
    for i = 1:obj.count
        pbj = obj.objectAtIndex(i);
        if isa(pbj,'SYObject') && pbj.respondsToSelector(selector)
            selector(pbj);
        end
    end
end

end
end
