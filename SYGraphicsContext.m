% Foundation Class: SYGraphicsContext < SYObject.
% Written by Satoshi Yamashita.
% Fundamental class managing drawing.

classdef SYGraphicsContext < SYObject
properties (Constant)
    % Comoposite mode.
    CompositeModeOver = 0;
    CompositeModeLighten = 1;
    CompositeModeDarken = 2;
    CompositeModeMultiply = 3;
    
    % Color space.
    ColorSpaceGrayscale = 0;
    ColorSpaceRGB = 1;
    ColorSpaceRGBA = 2;
    ColorSpaceHSB = 3;
    ColorSpaceHSBA = 4;
    ColorSpaceIndexed = 5;
    ColorSpaceComposite = 6;
    
    % current context.
    currentContext = SYGraphicsContext;
end
properties
    data = nan; % SYData.
    width = nan; % uint32.
    height = nan; % uint32.
    bitsPerComponent = nan; % uint32.
    compositeMode = nan; % SYGraphicsContext.Composite.
    colorSpace = nan; % SYGraphicsContext.ColorSpace.
    lut = nan; % uint8[n,m],double[n,m];
    range = nan; % double[n,2];
end

methods (Static)
function drawInto(context,frame,source,mask)
    if context.bitsPerComponent == 8
        d = 255;
        t = 'uint8';
    elseif context.bitsPerComponent == 16
        d = 65535;
        t = 'uint16';
    elseif context.bitsPerComponent == 32
        d = 1;
        t = 'single';
    else
        d = 1;
        t = 'double';
    end
    
    % indices describes an area in the context.
    c_x_l = max([1,frame(1)]);
    c_x_r = min([context.width,frame(1) + frame(3) - 1]);
    c_y_b = max([1,frame(2)]);
    c_y_t = min([context.height,frame(2) + frame(4) - 1]);
    citmap = context.data.var(c_y_b:c_y_t,c_x_l:c_x_r,:);

    % jndices describes an area in the source.
    s_x_l = max([1,2 - frame(1)]);
    s_x_r = min([frame(3),context.width - frame(1) + 1]);
    s_y_b = max([1,2 - frame(2)]);
    s_y_t = min([frame(4),context.height - frame(2) + 1]);
    sitmap = source(s_y_b:s_y_t,s_x_l:s_x_r,:);
    nask = mask(s_y_b:s_y_t,s_x_l:s_x_r);

    if context.compositeMode == SYGraphicsContext.CompositeModeOver
        bitmap = double(sitmap) .* nask;
    elseif context.compositeMode == SYGraphicsContext.CompositeModeLighten
        bitmap = cat(4,citmap,sitmap);
        bitmap = double(max(bitmap,[],4)) .* nask;
    elseif context.compositeMode == SYGraphicsContext.CompositeModeDarken
        bitmap = cat(4,citmap,sitmap);
        bitmap = double(min(bitmap,[],4)) .* nask;
    elseif context.compositeMode == SYGraphicsContext.CompositeModeMultiply
        bitmap = double(citmap) ./ d .* double(citmap) .* nask;
    end
    citmap = double(citmap) .* (1 - nask);
    context.data.var(c_y_b:c_y_t,c_x_l:c_x_r,:) = cast(bitmap + citmap,t);
end
end
methods
function obj = SYGraphicsContext(data_,width_,height_, ...
        bitsPerComponent_,compositeMode_,colorSpace_,lut_,range_)
% Foundation class managing graphcis context.
% obj = SYGraphicsContext(data_,width_,height_, ...
%        bitsPerComponent_,compositeMode_,colorSpace_,lut_,range_)
% Optional arguments below.
% Argument (SYData) data_ holds context's bitmap raw data.
% Argument (int) width_ and height_ indicate image size.
% Argument (int) bitsPerComponent indicates data type (8, 16, 32, or 64).
% Argument (SYGraphicsContext.CompositeMode) compositeMode_.
% Argument (SYGraphicsContext.ColorSpace) colorSpace_.
% Argument (uint8[n,m],double[n,m]) lut_ is a look up table.
% Argument (double[n,2]) range_ indicates range of value to show.
    if nargin < 1
        return;
    end
    
    obj.initWithContext(data_,width_,height_, ...
        bitsPerComponent_,compositeMode_,colorSpace_,lut_,range_);
end
function obj = initWithContext(obj,data_,width_,height_, ...
        bitsPerComponent_,compositeMode_,colorSpace_,lut_,range_)
% Initialization method with context parameters.
% obj = initWithContext(obj,data_,width_,height_, ...
%        bitsPerComponent_,compositeMode_,colorSpace_,lut_,range_)
% Argument (SYData) data_ holds context's bitmap raw data.
% Argument (int) width_ and height_ indicate image size.
% Argument (int) bitsPerComponent indicates data type (8, 32, or 64).
% Argument (SYGraphicsContext.CompositeMode) compositeMode_.
% Argument (SYGraphicsContext.ColorSpace) colorSpace_.
% Argument (uint8[n,m],double[n,m]) lut_ is a look up table.
% Argument (double[n,2]) range_ indicates range of value to show.
    obj.init;
    
    obj.data = data_;
    obj.width = width_;
    obj.height = height_;
    obj.bitsPerComponent = bitsPerComponent_;
    obj.compositeMode = compositeMode_;
    obj.colorSpace = colorSpace_;
    obj.lut = lut_;
    obj.range = range_;
end

function dest = copy(obj,dest)
% Method to make a 'shallow' copy.
% dest = copy(obj,dest)
    if nargin < 2
        dest = SYGraphicsContext;
    end
    copy@SYObject(obj,dest);
    
    dest.data = obj.data;
    dest.width = obj.width;
    dest.height = obj.height;
    dest.bitsPerComponent = obj.bitsPerComponent;
    dest.compositeMode = obj.compositeMode;
    dest.colorSpace = obj.colorSpace;
    dest.lut = obj.lut;
    dest.range = obj.range;
end

function result = isTransparent(obj)
    if obj.colorSpace == SYGraphicsContext.ColorSpaceRGBA || ...
            obj.colorSpace == SYGraphicsContext.ColorSpaceHSBA
        result = true;
    elseif obj.colorSpace == SYGraphicsContext.ColorSpaceIndexed || ...
            obj.colorSpace == SYGraphicsContext.ColorSpaceComposite
        if size(obj.lut,2) > 3
            result = true;
        else
            result = false;
        end
    else
        result = false;
    end
end
end
end
