% Foundation Class: SYColor < SYObject.
% Written by Satoshi Yamashita.
% Fundamental superclass of color.
% SYColor stores color value and converts it to any type.
% The color values are in [0,255] for uint8 or [0,1] in double data type.

classdef SYColor < SYObject
properties (Constant)
    % ColorSpace. Compatible with SYGraphicsContext.ColorSpace.
    ColorGray = 0;
    ColorRGB = 1;
    ColorRGBA = 2;
    ColorHSB = 3;
    ColorHSBA = 4;
    ColorIndexed = 5;
    ColorComposite = 6;
end
properties
    bitsPerComponent = nan; % uint32.
    colorSpace = nan; % SYColor.ColorSpace.
    color = nan; % double[n], uint8[n], uint16[n].
    lut = nan; % double[n,m].
    range = nan; % double[n,2].
end

methods
function obj = SYColor(bitsPerComponent,colorSpace,color,lut,range)
% Foundation class representing a color.
% obj = SYColor(bitsPerComponent,colorSpace,color,lut,range)
% Argument (uint8) bitsPerComponent indicates data type for output.
% Argument (SYColor.ColorSpace) colorSpace indicates color space.
% Argument (double[n],uint8[n]) color is a value of the color.
% Argument (double[n,m],uint8[n,m]) lut is a look up table.
% Argument (double[n,2]) range specifies range for normalization.
    if nargin < 1
        return;
    end
    
    obj.bitsPerComponent = bitsPerComponent;
    obj.colorSpace = colorSpace;
    obj.color = color;
    obj.lut = lut;
    obj.range = range;
end

function dest = copy(obj,dest)
% Method to make a copy.
    if nargin < 2
        dest = SYColor;
    end
    copy@SYObject(obj,dest);
    
    dest.bitsPerComponent = obj.bitsPerComponent;
    dest.colorSpace = obj.colorSpace;
    dest.color = obj.color;
    dest.lut = obj.lut;
    dest.range = obj.range;
end

function set.lut(obj,lut)
    obj.lut = obj.normalizeLut(lut);
    obj.setLut(lut);
end
function setLut(~,~)
% Bypass method from set.lut. Note that obj were already set normalized
% setLut(obj,lut)
% lut, while setLut() is given not-normalized lut in its argument.
% Do not call directly.
end

function result = grayColor(obj)
% Method returning grayscale color.
% result = grayColor(obj)
    if isempty(obj.color)
        result = nan;
        return;
    end
    
    if obj.colorSpace == SYColor.ColorGray
        c = obj.normalize(obj.color);
    elseif obj.colorSpace == SYColor.ColorRGB
        c = obj.normalize(obj.color);
        c = mean(c);
    elseif obj.colorSpace == SYColor.ColorRGBA
        c = obj.normalize(obj.color(1:3));
        c = mean(c);
    elseif obj.colorSpace == SYColor.ColorHSB
        c = obj.normalize(obj.color);
        c = c(3);
    elseif obj.colorSpace == SYColor.ColorHSBA
        c = obj.normalize(obj.color);
        c = c(3);
    elseif obj.colorSpace == SYColor.ColorIndexed
%         c = obj.lut(obj.normalizeIndex(obj.color),1:3);
        c = obj.normalizeIndex(obj.color);
        if ~isnan(c)
            c = mean(obj.lut(c,1:3));
        end
    elseif obj.colorSpace == SYColor.ColorComposite
        c = obj.normalize(obj.RGBColor);
        c = mean(c);
    end
    
    if obj.bitsPerComponent == 8
        result = uint8(c * 255);
    elseif obj.bitsPerComponent == 16
        result = uint16(c * 65535);
    else
        result = c;
    end
end
function result = RGBColor(obj)
% Method returning rgb color.
% result = RGBColor(obj)
    if isempty(obj.color)
        result = nan;
        return;
    end
    
    if obj.colorSpace == SYColor.ColorGray
        c = obj.normalize(obj.color);
        c = [c,c,c];
    elseif obj.colorSpace == SYColor.ColorRGB
        c = obj.normalize(obj.color);
    elseif obj.colorSpace == SYColor.ColorRGBA
        c = obj.normalize(obj.color(1:3));
    elseif obj.colorSpace == SYColor.ColorHSB
        c = obj.convertHSBToRGB(obj.normalize(obj.color));
    elseif obj.colorSpace == SYColor.ColorHSBA
        c = obj.convertHSBToRGB(obj.normalize(obj.color(1:3)));
    elseif obj.colorSpace == SYColor.ColorIndexed
%         c = obj.lut(obj.normalizeIndex(obj.color),1:3);
        c = obj.normalizeIndex(obj.color);
        if ~isnan(c)
            c = obj.lut(c,1:3);
        else
            c = [1,1,1];
        end
    elseif obj.colorSpace == SYColor.ColorComposite
        c = obj.lut(:,1:3) .* obj.normalize(obj.color(:));
        c = max(c,[],1);
    end
    
    if obj.bitsPerComponent == 8
        result = uint8(c * 255);
    elseif obj.bitsPerComponent == 16
        result = uint16(c * 65535);
    else
        result = c;
    end
end
function result = RGBAColor(obj)
% Method returning rgba color.
% result = RGBAColor(obj)
    if isempty(obj.color)
        result = nan;
        return;
    end
    
    if obj.colorSpace == SYColor.ColorGray
        c = obj.normalize(obj.color);
        c = [c,c,c,1];
    elseif obj.colorSpace == SYColor.ColorRGB
        c = obj.normalize(obj.color);
        c = [c,1];
    elseif obj.colorSpace == SYColor.ColorRGBA
        c = obj.normalize(obj.color);
    elseif obj.colorSpace == SYColor.ColorHSB
        c = obj.convertHSBToRGB(obj.normalize(obj.color));
        c = [c,1];
    elseif obj.colorSpace == SYColor.ColorHSBA
        c = obj.normalize(obj.color);
        c = [obj.convertHSBToRGB(c(1:3)),c(4)];
    elseif obj.colorSpace == SYColor.ColorIndexed
        c = obj.normalizeIndex(obj.color);
        if ~isnan(c)
%             c = obj.lut(obj.normalizeIndex(obj.color),:);
            c = obj.lut(c,:);
            if length(c) < 4
                c = [c,1];
            end
        else
            c = [0,0,0,0];
        end
    elseif obj.colorSpace == SYColor.ColorComposite
        c = obj.lut .* obj.normalize(obj.color(:));
        c = max(c,[],1);
        if length(c) < 4
            c = [c,1];
        end
    end
    
    if obj.bitsPerComponent == 8
        result = uint8(c * 255);
    elseif obj.bitsPerComponent == 16
        result = uint16(c * 65535);
    else
        result = c;
    end
end
function result = HSBColor(obj)
% Method returning hsb color.
% reuslt = HSBColor(obj)
    if isempty(obj.color)
        result = nan;
        return;
    end
    
    if obj.colorSpace == SYColor.ColorGray
        c = obj.normalize(obj.color);
        c = [0,0,c];
    elseif obj.colorSpace == SYColor.ColorRGB
        c = obj.normalize(obj.color);
        c = obj.convertRGBToHSB(c);
    elseif obj.colorSpace == SYColor.ColorRGBA
        c = obj.normalize(obj.color(1:3));
        c = obj.convertRGBToHSB(c);
    elseif obj.colorSpace == SYColor.ColorHSB
        c = obj.normalize(obj.color);
    elseif obj.colorSpace == SYColor.ColorHSBA
        c = obj.normalize(obj.color(1:3));
    elseif obj.colorSpace == SYColor.ColorIndexed
%         c = obj.lut(obj.normalizeIndex(obj.color),1:3);
        c = obj.normalizeIndex(obj.color);
        if ~isnan(c)
            c = obj.lut(c,1:3);
        else
            c = [1,0,1];
        end
        c = obj.convertRGBToHSB(c);
    elseif obj.colorSpace == SYColor.ColorComposite
        c = obj.lut(:,1:3) .* obj.normalize(obj.color(:));
        c = max(c,[],1);
        c = obj.convertRGBToHSB(c);
    end
    
    if obj.bitsPerComponent == 8
        result = uint8(c * 255);
    elseif obj.bitsPerComponent == 16
        result = uint16(c * 65535);
    else
        result = c;
    end
end
function result = HSBAColor(obj)
% Method returning hsba color.
% result = HSBAColor(obj)
    if isempty(obj.color)
        result = nan;
        return;
    end
    
    if obj.colorSpace == SYColor.ColorGray
        c = obj.normalize(obj.color);
        c = [0,0,c,1];
    elseif obj.colorSpace == SYColor.ColorRGB
        c = obj.normalize(obj.color);
        c = obj.convertRGBToHSB(c);
        c = [c,1];
    elseif obj.colorSpace == SYColor.ColorRGBA
        c = obj.normalize(obj.color);
        c = [obj.convertRGBToHSB(c(1:3)),c(4)];
    elseif obj.colorSpace == SYColor.ColorHSB
        c = obj.normalize(obj.color);
        c = [c,1];
    elseif obj.colorSpace == SYColor.ColorHSBA
        c = obj.normalize(obj.color);
    elseif obj.colorSpace == SYColor.ColorIndexed
%         c = obj.lut(obj.normalizeIndex(obj.color),:);
        c = obj.normalizeIndex(obj.color);
        if ~isnan(c)
            if length(c) < 4
                c = [obj.convertRGBToHSB(c),1];
            else
                c = [obj.convertRGBToHSB(c(1:3)),c(4)];
            end
        else
            c = [1,0,0,0];
        end
    elseif obj.colorSpace == SYColor.ColorComposite
        c = obj.lut(:,1:3) .* obj.normalize(obj.color(:));
        c = max(c,[],1);
        if length(c) < 4
            c = [obj.convertRGBToHSB(c),1];
        else
            c = [obj.convertRGBToHSB(c(1:3)),c(4)];
        end
    end
    
    if obj.bitsPerComponent == 8
        result = uint8(c * 255);
    elseif obj.bitsPerComponent == 16
        result = uint16(c * 65535);
    else
        result = c;
    end
end

function result = convertRGBToHSB(~,rgb)
% Method to convert rgb color to hsb color.
% result = convertRGBToHSB(~,rgb)
% Argument rgb is a normalized rgb value.
% Return value is a normalized hsb value.
    if any(isnan(rgb))
        result = [1,0,1];
        return;
    end
    
    [M,i] = max(rgb);
    m = min(rgb);
    c = M - m;
    if c == 0
        h = 0;
    elseif i == 1
        h = mod((rgb(2) - rgb(3)) / c,6);
    elseif i == 2
        h = 2 + (rgb(3) - rgb(1)) / c;
    else
        h = 4 + (rgb(1) - rgb(2)) / c;
    end
    h = h / 6;
    b = (M + m) / 2;
    if b == 0 || b == 1
        s = 0;
    else
        s = c / (1 - abs(2 * b - 1));
    end
    result = [h,s,b];
end
function result = convertHSBToRGB(~,hsb)
% Method to convert hsb color to rgb color.
% result = convertHSBToRGB(~,hsb)
% Argument rgb is a normalized hsb value.
% Return value is a normalized rgb value.
    if any(isnan(hsb))
        result = [1,1,1];
        return;
    end
    
    c = (1 - abs(2 * hsb(3) - 1)) * hsb(2);
    h = mod(hsb(1) * 6,6);
    x = c * ( 1 - abs(mod(h,2) - 1));
    m = hsb(3) - c /2;
    if h < 1
        array = [c + m,x + m,m];
    elseif h < 2
        array = [x + m,c + m,m];
    elseif h < 3
        array = [m,c + m,x + m];
    elseif h < 4
        array = [m,x + m,c + m];
    elseif h < 5
        array = [x + m,m,c + m];
    elseif h < 6
        array = [c + m,m,x + m];
    end
    result = array;
end

function result = normalize(obj,color)
% Method to normalize a color.
% result = normalize(obj,color)
% Argument color is either rgb, rgba, hsb, hsba, or stack for composition.
% Return value is a normalized value \in [0,1].
    if length(obj.range) > 1
        color = (double(color) - obj.range(:,1)) ./ ...
            (obj.range(:,2) - obj.range(:,1));
    elseif isa(color,'uint8')
        color = double(color) / 255;
    elseif isa(color,'uint16')
        color = double(color) / 65535;
    end
    
    color(color < 0) = 0;
    color(color > 1) = 1;
    
    result = color;
end
function result = normalizeIndex(obj,index)
% Method to normalize index of color.
% result = normalizeIndex(obj,index)
    if length(obj.range) < 2
        if index < 1
            index = 1;
        elseif index > size(obj.lut,1)
            index = size(obj.lut,1);
        end
        result = index;
        return;
    end
    
    index = (double(index) - obj.range(1)) / (obj.range(2) - obj.range(1));
    n = size(obj.lut,1) - 1;
    index = round(n * index) + 1;
    result = index;
end
function result = normalizeLut(~,lut)
% Method to normalize look up table.
% result = normalizeLut(obj,lut)
    if isa(lut,'uint8')
        lut = double(lut) / 255;
    else
        lut(lut < 0) = 0;
        lut(lut > 1) = 1;
    end
    result = lut;
end

end
end
