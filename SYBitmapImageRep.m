% Foundation Class: SYImageRep < SYObject.
% Written by Satoshi Yamashita.
% Fundamental class of image representation which stores raw bitmap data.

classdef SYBitmapImageRep < SYObject
properties (Constant)
    % ImageRep type.
    RepTypeImage = 0;
    RepTypeMask = 1;
    RepTypeThumbnail = 2;
    RepTypeORI = 3;
end
properties
    repType = nan; % SYBitmapImageRep.RepType.
    bitmap = nan; % SYData.
    width = nan; % double.
    height = nan; % double.
    bitsPerComponent = nan; % uint32.
    componentsPerPixel = nan; % double.
end

methods
function obj = SYBitmapImageRep(data)
% Foundation class containing image data.
% obj = SYBitmapImageRep(data)
% Argument data is an SYData instance containing bitmap data.
    if nargin < 1
        return;
    end
    
    if isa(data,'SYData')
        obj.initWithData(data);
    elseif isnumeric(data)
        obj.initWithData(SYData(data));
    end
end
function obj = initWithData(obj,data)
% Initialization method.
% obj = initWithData(obj,data)
% Argument data is an SYData instance containing bitamp data.
    if ~isa(data,'SYData')
        data = SYData(data);
    end
    if ~isnumeric(data.var)
        return;
    end
    
    obj.repType = SYBitmapImageRep.RepTypeImage;
    obj.bitmap = data;
    obj.width = size(data.var,2);
    obj.height = size(data.var,1);
    if isa(data.var,'uint8')
        obj.bitsPerComponent = uint32(8);
    elseif isa(data.var,'uint16')
        obj.bitsPerComponent = uint32(16);
    elseif isa(data.var,'single')
        obj.bitsPerComponent = uint32(32);
    elseif isa(data.var,'double')
        obj.bitsPerComponent = uint32(64);
    end
    obj.componentsPerPixel = size(data.var,3);
end

function dest = copy(obj,dest)
% Method to make a copy of obj.
% dest = copy(obj,dest)
    if nargin < 2
        dest = SYBitmapImageRep;
    end
    copy@SYObject(obj,dest);
    
    dest.repType = obj.repType;
    dest.bitmap = obj.bitmap;
    dest.width = obj.width;
    dest.height = obj.height;
    dest.bitsPerComponent = obj.bitsPerComponent;
    dest.componentsPerPixel = obj.componentsPerPixel;
end

function set.bitmap(obj,data)
    obj.bitmap = data;
    obj.setBitmap(data);
end
function setBitmap(obj,data)
    
end

function result = colorAtXY(obj,x,y)
% Method returning color at x (column) and y (row).
% result = colorAtXY(obj,x,y)
% Return value is a row vector of color.
    color = obj.bitmap.var(y,x,:);
    result = color(:)';
end

function result = splitChannels(obj)
% Method to split bitmap into individual planes.
% result = splitChannels(obj)
% Return value is an SYArray instance containing SYbitmapImageRep of each
% plane.
    array = SYArray();
    for i = 1:obj.componentsPerPixel
        bitmap_ = obj.bitmap.var(:,:,i);
        array.addObject(SYBitmapImageRep(SYData(bitmap_)));
    end
    result = array;
end

end
end
