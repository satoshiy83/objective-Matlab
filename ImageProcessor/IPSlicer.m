
classdef IPSlicer < SYObject
properties(Constant)

end

methods(Static)

function result = sliceXZ(image)
    array = image.bitmapImageArray(false);
    bitmapRep = array.objectAtIndex(1);
    
    if bitmapRep.bitsPerComponent == 8
        d = 'uint8';
    elseif bitmapRep.bitsPerComponent == 16
        d = 'uint16';
    elseif bitmapRep.bitsPerComponent == 32
        d = 'single';
    elseif bitmapRep.bitsPerComponent == 64
        d = 'double';
    end
    bitmap = zeros(array.count,bitmapRep.width, ...
        bitmapRep.componentsPerPixel,d);
    
    jmage = SYImage;
    for i = 1:bitmapRep.height
        for j = 1:array.count
            bitmapRep = array.objectAtIndex(j);
            bitmap(j,:,:) = bitmapRep.bitmap.var(i,:,:);
        end
        jmage.addRepresentation(SYBitmapImageRep(SYData(bitmap)));
    end
    
    result = jmage;
end

function result = sliceYZ(image)
    array = image.bitmapImageArray(false);
    bitmapRep = array.objectAtIndex(1);
    
    if bitmapRep.bitsPerComponent == 8
        d = 'uint8';
    elseif bitmapRep.bitsPerComponent == 16
        d = 'uint16';
    elseif bitmapRep.bitsPerComponent == 32
        d = 'single';
    elseif bitmapRep.bitsPerComponent == 64
        d = 'double';
    end
    bitmap = zeros(array.count,bitmapRep.height, ...
        bitmapRep.componentsPerPixel,d);
    
    jmage = SYImage;
    for i = 1:bitmapRep.height
        for j = 1:array.count
            bitmapRep = array.objectAtIndex(j);
            bitmap(j,:,:) = permute(bitmapRep.bitmap.var(:,i,:),[2,1,3]);
        end
        jmage.addRepresentation(SYBitmapImageRep(SYData(bitmap)));
    end
    
    result = jmage;
end

end
end
