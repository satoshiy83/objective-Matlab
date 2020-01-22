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

end
end
