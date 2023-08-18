% Foundation Class: SYSet < SYObject
% Written by Satoshi Yamashita.
% Fundamental class of set which store variables and objects in a set.

classdef SYSet < SYObject
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
function obj = SYSet(varargin)
% Foundation class of data container in a set.
% obj = SYSet(varargin)
    if length(varargin) < 2
        if ~isempty(varargin) && ~isnan(varargin(1))
            obj.elements = varargin;
        else
            obj.elements = {};
        end
        return
    end

    indices = ones(1,length(varargin),'logical');
    for i = 1:(length(varargin) - 1)
        if isnan(varargin(i))
            indices(i) = false;
        end

        if ~indices(i)
            continue
        end

        for j = (i + 1):length(varargin)
            if ~indices(j)
                continue
            end

            if isEqual(varargin(i),varargin(j))
                indices(j) = false;
            end
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
                pbj = array{i,3};
            case obj.DataTypeSYObjectNoData
                fh = str2func(array{i,1});
                pbj = fh();
            case obj.DataTypeSYObjectWithData
                fh = str2func(array{i,1});
                pbj = fh();
                pbj.initWithData(SYData(array{i,3}));
            case obj.DataTypeSYData
                fh = str2func(array{i,1});
                pbj = fh(array{i,3});
            otherwise
                pbj = array{i,3};
        end
        obj.elements{i} = pbj;
    end
end
function obj = initWithArray(obj,array)
% Initializing method with an SYArray instance.
% obj = initWithArray(obj,array,copyItems)
    obj.removeAllObjects;

    if array.count < 1
        return
    elseif array.count == 1
        obj.elements{1} = array.objectAtIndex(1);
        return
    end

    indices = ones(1,array.count,'logical');
    for i = 1:(array.count - 1)
        if ~indices(i)
            continue
        end

        for j = (i + 1):array.count
            if ~indices(j)
                continue
            end

            if isEqual(array.objectAtIndex(i),array.objectAtIndex(j))
                indices(j) = false;
            end
        end
    end

    obj.elements = array.elements{indices};
end

function dest = copy(obj,dest)
% Method to make a 'shallow' copy.
% dest = copy(obj,dest)
% Return value is an instance of the class.
    if nargin < 2
        dest = SYSet;
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
        pbj = obj.elements{i};
        array{i,1} = class(pbj);
        if isa(pbj,'SYObject')
            if isa(pbj,'SYData')
                array{i,2} = obj.DataTypeSYData;
                pbj = pbj.var;
            elseif pbj.respondToSelector('data') && ...
                    pbj.respondToSelector('initWithData')
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

function result = count(obj)
% Method returning number of itmes in the array.
% result = count(obj)
    result = length(obj.elements);
end
function result = allObjects(obj)
% Method returning an SYArray instance containing elements in the set.
% result = allObjects(obj)
    result = SYArray(obj.elements{ones(obj.count,1,'logical')});
end
function result = containsObject(obj,item)
% Method returning a boolean whether the array contains an item.
% result = containsObject(obj,item)
    result = any(cellfun(@(x) isEqual(x,item),obj.elements));
end

function addObject(obj,item)
% Method to add an item at the end of the array.
% addObject(obj,item)
    if ~obj.containsObject(item)
        obj.elements{obj.count + 1} = item;
    end
end
function addObjectsFromArray(obj,array)
% Method to add items from an SYArray instance.
% addObjectsFromArray(obj,array)
    if nargin < 2 || ~isa(array,'SYArray') || array.count < 1
        return;
    end
    
    for i = 1:array.count
        obj.addObject(array.objectAtIndex(i));
    end
end

function removeObject(obj,item)
% Method to remove an item.
% removeObject(obj,item)
    if obj.count < 1
        return
    end

    for i = 1:obj.count
        if iscell(obj.elements{i}) && iscell(item)
            a = obj.elements{i};
            a = SYArray(a{:});
            b = SYArray(item{:});
            if isEqual(a,b)
                obj.elements(i) = [];
                return
            end
        elseif ~iscell(obj.elements{i}) && ~iscell(item) && ...
                length(size(obj.elements{i})) == length(size(item)) && ...
                all(size(obj.elements{i}) == size(item))
            if all(obj.elements{i} == item)
                obj.elements(i) = [];
                return
            end
        end
    end
end
function removeAllObjects(obj)
% Method to clear the set.
% removeAllObjects(obj)
    obj.elements = {};
end

function result = anyObject(obj)
% Method returning an item in the set randomly.
% result = anyObject(obj)
    if obj.count < 1
        result = nan;
        return
    end

    i = randi(obj.count);
    result = obj.elements{i};
end

end
end
