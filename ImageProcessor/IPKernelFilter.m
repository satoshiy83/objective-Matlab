

classdef IPKernelFilter < SYObject
properties(Constant)

end

methods(Static)

function result = filteringWithKernel(image,kernel)
    if image.graphicsContext.colorSpace == ...
            SYGraphicsContext.ColorSpaceHSB || ...
            image.graphicsContext.colorSpace == ...
            SYGraphicsContext.ColorSpaceHSBA || ...
            image.graphicsContext.colorSpace == ...
            SYGraphicsContext.ColorSpaceIndexed
        bitmap = double(image.drawBitmapRep(nan));
    else
        bitmapRep = image.representations.objectAtIndex(1);
        bitmap = double(bitmapRep.bitmap.var);
    end
    
    mask = isnan(bitmap);
    bitmap(mask) = 0;
    
    siz = [size(bitmap,1),size(bitmap,2)];
    if mod(size(kernel,1),2) == 0
        m = size(kernel,1) / 2 - 1;
        indices = [ones(1,m),1:siz(1),ones(1,m) * siz(1)];
        
        siz(1) = siz(1) - 1;
    else
        m = (size(kernel,1) - 1) / 2;
        indices = [ones(1,m),1:siz(1),ones(1,m) * siz(1)];
    end
    if mod(size(kernel,2),2) == 0
        m = size(kernel,2) / 2 - 1;
        jndices = [ones(1,m),1:siz(2),ones(1,m) * siz(2)];
        
        siz(2) = siz(2) - 1;
    else
        m = (size(kernel,2) - 1) / 2;
        jndices = [ones(1,m),1:siz(2),ones(1,m) * siz(2)];
    end
    
    if image.graphicsContext.colorSpace == ...
            SYGraphicsContext.ColorSpaceGrayscale
        c = 1;
    elseif image.graphicsContext.colorSpace == ...
            SYGraphicsContext.ColorSpaceComposite
        c = size(bitmap,3);
    else
        c = 3;
    end
    
    if image.graphicsContext.bitsPerComponent == 8
        d = 'uint8';
    elseif image.graphicsContext.bitsPerComponent == 16
        d = 'uint16';
    elseif image.graphicsContext.bitsPerComponent == 32
        d = 'single';
    else
        d = 'double';
    end
    
    citmap = zeros([siz,c]);
    
    for i = 1:size(kernel,1)
        indices_ = indices(i:siz(1) + i - 1);
        for j = 1:size(kernel,2)
            jndices_ = jndices(j:siz(2) + j - 1);
            
            citmap = citmap + bitmap(indices_,jndices_,1:c) * kernel(i,j);
        end
    end
    
    if size(bitmap,3) > size(citmap,3)
        citmap = cat(3,citmap,bitmap(:,:,size(citmap,3) + 1:end));
    end
    
    citmap(mask) = nan;
    citmap = cast(citmap,d);
    result =  SYImage(SYData(citmap));
end

end
end
