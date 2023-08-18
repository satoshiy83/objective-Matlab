% Foundation Class: SYDictionary < SYObject.
% Written by Satoshi Yamashita.
% Fundamental superclass of dictinary that contains cell array and returns
% object for given key.
% For the key, char array and string are not distinguished.

classdef SYDictionary < SYObject
properties
    keyArray = nan; % SYArray.
    contentArray = nan; % SYArray.
end

methods
function obj = SYDictionary(data)
% Foundation class holding objects with keys.
% obj = SYDictionary(array)
% Argument data is an SYData instance containing dictionary data.
    obj.keyArray = SYArray;
    obj.contentArray = SYArray;
    
    if nargin < 1
        return;
    end
    
    if isa(data,'SYData')
        obj.initWithData(data);
    end
end
function obj = initWithData(obj,data)
% Initializing medhos with an SYData instance.
% obj = initWithData(obj,data)
    if ~isa(data,'SYData')
        disp('data must be SYData instance');
        return;
    end
    
    s = data.var;
    array = SYArray;
    obj.keyArray = array.initWithData(SYData(s.keyArray_));
    array = SYArray;
    obj.contentArray = array.initWithData(SYData(s.contentArray_));
end
function obj = initWithKeyAndContentArray(obj,keyArray_,contentArray_)
% Initializing method with SYArray instances for the key array and objects
% array.
% obj = initWithKeyAndContentArray(obj,keyArray_,contentArray_)
    if ~isa(keyArray_,'SYArray') || ~isa(contentArray_,'SYArray')
        disp('Argument arrays must be SYArray instances.');
        return;
    end
    
    obj.keyArray = keyArray_;
    obj.contentArray = contentArray_;
end

function dest = copy(obj,dest)
% Method to make a 'shallow' copy.
% dest = copy(obj,dest)
% Return value is an instance of the class.
    if nargin < 2
        dest = SYDictionary({});
    end
    copy@SYObject(obj,dest);
    
    dest.keyArray = obj.keyArray.copy;
    dest.contentArray = obj.contentArray.copy;
end

function result = data(obj)
% Method to convert the instance to an SYData instance.
% result = data(obj)
% Return value is an SYData instance.
    s.keyArray_ = obj.keyArray.data.var;
    s.contentArray_ = obj.contentArray.data.var;
    
    result = SYData(s);
end

function result = isEqual(obj,pbj)
% Method to compare objects contents.
% result = isEqual(obj,pbj)
% Argument pbj is an SYDictionary instance.
% Return value is a boolean.
    result = obj.isEqualToDictionary(pbj);
end
function result = isEqualToDictionary(obj,pbj)
% Method to compare entries in dictionaries.
% result = isEqualToDictionary(obj,pbj)
% Argument pbj is an SYDictionary instance.
% Return value is a boolean.
    result = false;
    if ~isa(pbj,'SYDictionary')
        return;
    end
    
    sel = str2func('ss_compare_string');
    [array,indices] = obj.keyArray.sortedArrayWithUsingComparator(sel);
    [brray,jndices] = pbj.keyArray.sortedArrayWithUsingComparator(sel);
    
    if ~array.isEqualToArray(brray)
        return;
    end
    
    array = SYArray;
    for i = indices
        array.addObject(obj.contentArray.objectAtIndex(i));
    end
    brray = SYArray;
    for i = jndices
        brray.addObject(pbj.contentArray.objectAtIndex(i));
    end
    if ~array.isEqualToArray(brray)
        return;
    end
    
    result = true;
end

function result = description(obj)
% Method to give a simple description of the instance.
% result = description(obj)
% Return value is a string.
    str = [class(obj),' with ',num2str(obj.count),' entry(ies) {'];
    
    enumerator = SYEnumerator;
    enumerator.initWithArray(obj.keyArray);
    fnumerator = SYEnumerator;
    fnumerator.initWithArray(obj.contentArray);
    while ~enumerator.isNextObjectNan
        key = enumerator.nextObject;
        if ischar(key)
            str = cat(2,str,'\nKey :',key,' {');
        elseif isstring(key)
            str = cat(2,str,'\nKey :',convertStringsToChars(key),' {');
        elseif isa(key,'SYObject')
            str = cat(2,str,'\nKey :',key.description,' {');
        else
            str = cat(2,str,'\nKey :',ss_describe_variable(key),' {');
        end
        
        pbj = fnumerator.nextObject;
        if isa(pbj,'SYObject')
            ttr = pbj.description;
        else
            ttr = ss_describe_variable(pbj);
        end
        ttr = ss_indent_text(ttr);
        str = cat(2,str,'\n',ttr,'\n}');
    end
    str = [str,'\n}'];
    
    result = str;
end

function result = count(obj)
% Method returning a number of entries.
% result = count(obj)
    result = obj.keyArray.count;
end
function result = allKeys(obj)
% Method returning a copy of the keys.
% result = allKeys(obj)
% Return value is an SYArray instance.
    result = obj.keyArray.copy;
end

function result = objectForKey(obj,key)
% Method to request an object for key.
% result = objectForKey(obj,key)
    if obj.count < 1
        result = nan;
        return;
    end
    index = obj.keyArray.indexOfObject(key);
    if ~isempty(index)
        result = obj.contentArray.objectAtIndex(index(1));
        return;
    elseif ischar(key)
        index = obj.keyArray.indexOfObject(convertCharsToStrings(key));
        if ~isempty(index)
            result = obj.contentArray.objectAtIndex(index(1));
            return
        end
    elseif isstring(key)
        index = obj.keyArray.indexOfObject(convertStringsToChars(key));
        if ~isempty(index)
            result = obj.contentArray.objectAtIndex(index(1));
            return
        end
    end
    
    result = nan;
end

function setObjectForKey(obj,key,value)
% Method to add an entry or replace an object when the key exists.
% setObjectForKey(obj,key,value)
% Argument key is an object responding to eq(). The key should be char
% array.
% Argument value is an object to be stored as a content for the key.
    if nargin < 2
        return;
    end
    
    index = obj.keyArray.indexOfObject(key);
    if isempty(index)
        obj.keyArray.addObject(key);
        obj.contentArray.addObject(value);
    else
        obj.contentArray.replaceObjectAtIndex(value,index);
    end
end
function addEntriesFromDictionary(obj,dict)
% Method to add entries from another SYDictionary instance.
% addEntriesFromDictionary(obj,dict)
    array = dict.allKeys;
    if array.count < 1
        return;
    end
    
    for i = 1:array.count
        key = array.objectAtIndex(i);
        pbj = dict.objectForKey(key);
        obj.setObjectForKey(key,pbj);
    end
end

function removeAllObjects(obj)
% Method to clear entries.
% removeAllObjects(obj)
    obj.keyArray.removeAllObjects;
    obj.contentArray.removeAllObjects;
end
function removeObjectForKey(obj,key)
% Method to remove an object for the key.
% removeObjectForKey(obj,key)
    if obj.count < 1
        return;
    end
    
    index = obj.keyArray.indexOfObject(key);
    if ~isempty(index)
        obj.keyArray.removeObjectAtIndex(index);
        obj.contentArray.removeObjectAtIndex(index);
    end
end

function result = isNanForKey(obj,key)
% Method to check if an entry exists for the key.
% result = isNanForKey(obj,key)
    result = true;
    if nargin < 1 || obj.count < 1
        return;
    end
    
    index = obj.keyArray.indexOfObject(key);
    if ~isempty(index)
        object = obj.objectForKey(key);
        if length(object) ~= 1 || ~isnan(object)
            result = false;
        end
    elseif ischar(key)
        index = obj.keyArray.indexOfObject(convertCharsToStrings(key));
        if ~isempty(index)
            object = obj.objectForKey(key);
            if length(object) ~= 1 || ~isnan(object)
                result = false;
            end
        end
    elseif isstring(key)
        index = obj.keyArray.indexOfObject(convertStringsToChars(key));
        if ~isempty(index)
            object = obj.objectForKey(key);
            if length(object) ~= 1 || ~isnan(object)
                result = false;
            end
        end
    end
end

end
end
