
classdef IPMedianBlur < SYObject
properties(Constant)

end

methods(Static)

function result = medianBlur(image,radius)
    if radius < 1
        disp('radius must be larger than 1.');
        result = nan;
        return;
    end
    
    array = image.bitmapImageArray(false);
    jmage = SYImage;
    for i = 1:array.count
        bitmapRep = array.objectAtIndex(i);
        bitmapRep = IPMedianBlur.medianBlurBitmapRep(bitmapRep,radius);
        jmage.addRepresentation(bitmapRep);
    end
    
    result = jmage;
end
function result = medianBlurBitmapRep(bitmapRep,radius)
    sadius = floor(radius);
    fan = ones(sadius,sadius,2);
    fan(:,:,1) = repmat(1:sadius,sadius);
    fan(:,:,2) = fan(:,:,1)';
    fan = sum(fan .^ 2,3) <= radius ^ 2;
    mask = ones(sadius * 2 + 1,'logical');
    mask(1:sadius,1:sadius) = fan;
    mask = mask & mask(:,end:-1:1);
    mask = mask & mask(end:-1:1,:);
    
    bitmap = nan(bitmapRep.height + sadius * 2, ...
        bitmapRep.width + sadius * 2, ...
        bitmapRep.componentsPerPixel);
    bitmap(sadius + 1:end - sadius,sadius + 1:end - sadius,:) = ...
        bitmapRep.bitmap.var;
    if bitmapRep.bitsPerComponent == 8
        d = 'uint8';
    elseif bitmapRep.bitsPerComponent == 16
        d = 'uint16';
    elseif bitmapRep.bitsPerComponent == 32
        d = 'single';
    elseif bitmapRep.bitsPerComponent == 64
        d = 'double';
    end
    citmap = zeros(bitmapRep.height,bitmapRep.width, ...
        bitmapRep.componentsPerPixel,d);
    
    indices = 0:size(mask,1) - 1;
    jndices = 0:size(mask,2) - 1;
    for r = 1:bitmapRep.height
        for c = 1:bitmapRep.width
            for z = 1:bitmapRep.componentsPerPixel
                ditmap = bitmap(r + indices,c + jndices,z);
                values = ditmap(mask);
                values = sort(values(~isnan(values)));
                if length(values) > 1
                    citmap(r,c,z) = values(round(length(values) / 2));
                elseif length(value) == 1
                    citmap(r,c,z) = values(1);
                elseif isa(d,'single') || isa(d,'double')
                    citmap(r,c,z) = nan;
                end
            end
        end
    end
    
    result = SYBitmapImageRep(SYData(citmap));
end

end
end
