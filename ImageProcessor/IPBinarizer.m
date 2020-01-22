% Image Processor Class: IPBinarizer < SYObject.
% Written by Satoshi Yamashita.

classdef IPBinarizer < SYObject
properties

end

methods(Static)

function result = binarizeImage(image,threshold)
% result = binarizeImage(image,threshold)
% Class method to binarize image.
% Argument image is a bitmap raw data or SYImage instance.
% Argument threshold must be same type and depth with the image.
% Return value is a (double[h,w]) bitmap raw data.
    if isnumeric(image) && size(image,3) == 1
        bitmap = zeros(size(image,1),size(image,2));
        bitmap(image >= threshold) = 1;
    else
        if isnumeric(image)
            citmap = image;
        else
            citmap = image.drawBitmapRep(nan);
        end
        bitmap = ones(size(citmap,1),size(citmap,2));
        for i = 1:3
            bitmap(citmap(:,:,i) < threshold(i)) = 0;
        end
    end
    result = bitmap;
end

end
end
