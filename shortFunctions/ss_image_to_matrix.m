% Short script to convert SYImage to 4D matrix.
% Written by Satoshi Yamashita.

function result = ss_image_to_matrix(image)
% Short script to convert SYImage instance to 4D matrix.
% result = ss_image_to_matrix(image)
% Argument image is an SYImage instance.
% Return value is a 4D matrix.

stack = [];
array = image.representations;
for i = 1:array.count
    rep = array.objectAtIndex(i);
    if rep.repType == SYBitmapImageRep.RepTypeImage
        bitmap = image.drawBitmapRep(rep);
        stack = cat(4,stack,bitmap);
    end
end

result = stack;
end
