
classdef IPHistogram < SYObject
properties(Constant)

end

methods(Static)

function result = imageHistogram(image,n,range)
    array = image.bitmapImageArray(false);
    bitmapRep = array.objectAtIndex(1);
    
    if isnan(range)
        range = double(IPHistogram.imageRange(image));
    end
    if isnan(n)
        if bitmapRep.bitsPerComponent == 8 || ...
            bitmapRep.bitsPerComponent == 16
            n = min([256,range(2) - range(1)]);
        else
            n = 256;
        end
    end
    hstgrm = zeros(1 + bitmapRep.componentsPerPixel,n);
    hstgrm(1,:) = range(1):((range(2) - range(1)) / (n - 1)):range(2);
    
    for i = 1:array.count
        bitmapRep = array.objectAtIndex(i);
        m = bitmapRep.bitmap.var <= hstgrm(1,1);
        c = sum(sum(m,1),2);
        hstgrm(2:end,1) = hstgrm(2:end,1) + c(:);
        d = c(:);
        for j = 2:n
            m = bitmapRep.bitmap.var <= hstgrm(1,j);
            c = sum(sum(m,1),2);
            hstgrm(2:end,j) = hstgrm(2:end,j) + c(:) - d;
            d = c(:);
        end
    end
    
    result = hstgrm;
end
function result = imageRange(image)
    array = image.bitmapImageArray(false);
    M = nan;
    m = nan;
    for i = 1:array.count
        bitmapRep = array.objectAtIndex(i);
        m = min([m,min(bitmapRep.bitmap.var(:))]);
        M = max([M,max(bitmapRep.bitmap.var(:))]);
    end
    result = [m,M];
end

end
end
