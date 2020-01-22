
classdef IPGrayImage < SYObject
properties

end

methods(Static)

function result = grayImage(image,range)
% result = grayImage(image,range)
% Class method to convert given image to gray scale image.
% Argument image is either bitmap raw data or SYImage instance.
% Argument (double[2]) range.
% Return value is (uint8[h,w],double[h,w]) bitmap raw data.
    if isa(image,'SYImage')
        image = image.drawBitmapRep(nan);
    end
    
    if isa(image,'uint8')
        d = 8;
        image = double(image);
    else
        d = 32;
    end
    if isnan(range)
        if d == 8
            range = [0,255];
        else
            range = [0,1];
        end
    end
    
    if size(image,3) > 1
        image = mean(image(:,:,1:3),3);
    end
    
    image = (image - range(1)) / (range(2) - range(1));
    if d == 8
        image = uint8(image * 255);
    else
        image(image > 1) = 1;
        image(image < 0) = 0;
    end
    
    result = image;
end

end
end
