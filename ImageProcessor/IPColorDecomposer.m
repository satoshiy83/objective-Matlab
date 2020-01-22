% Image Processor Class: IPColorDecomposer < SYObject.
% Written by Satoshi Yamashita.

classdef IPColorDecomposer < SYObject
properties
    
end

methods(Static)

function result = decomposeColor(image)
% result = decomposeColor(image)
% Class method to convert given image to an SYImage instance with indexed
% color.
% Argument image is either a bitmap raw data or SYImage instance.
% Return value is an 8-bit SYImage instance.
    if isa(image,'SYImage')
        image = image.drawBitmapRep(nan);
    end
    
    if isa(image,'float')
        range = [0,1];
        range(1) = min(image(:));
        range(2) = max(image(:));
        image = uint8(255 * (image - range(1)) / (range(2) - range(1)));
    end
    
    array = [];
    for c = 1:size(image,3)
        channel = image(:,:,c);
        array = cat(2,array,channel(:));
    end
    
    [lut,~,indices] = unique(array,'row');
    if size(lut,2) == 1
        lut = cat(2,lut,lut,lut);
    end
    w = size(image,2);
    h = size(image,1);
    bitmap = zeros(h,w);
    bitmap(:) = indices;
    
    context = SYGraphicsContext;
    context.initWithContext(SYData(bitmap),w,h, ...
        8,SYGraphicsContext.CompositeModeOver, ...
        SYGraphicsContext.ColorSpaceIndexed,lut,nan);
    result = SYImage(context);
end

end
end
