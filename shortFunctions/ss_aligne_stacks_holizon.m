% Short script to aligne image stack in horizontal direction.
% Written by Satoshi Yamashita.

function result = ss_aligne_stacks_holizon(array)
% Short script to aligne images stacks in given array.
% result = ss_aligne_stacks_holizon(array)
% Argument array is an SYArray instance.
% Return value is a 32-bit SYImage instance.
if ~isa(array,'SYArray')
    disp('The argument ''array'' must be SYArray instance.');
    return;
end
if array.count < 1
    disp('Array is empty.');
    return;
end

frame = [0,0];
stackCount = 0;
for i = 1:array.count
    image = array.objectAtIndex(i);
    frame(1) = max([frame(1),image.frameSize(1)]);
    frame(2) = frame(2) + image.frameSize(2);
    if stackCount < image.countStack
        stackCount = image.countStack;
    end
end
if image.graphicsContext.colorSpace == SYGraphicsContext.ColorSpaceGrayscale
    bitDepth = 1;
elseif image.isTransparent
    bitDepth = 4;
else
    bitDepth = 3;
end

bitmap = zeros(frame(1),frame(2),bitDepth,stackCount);
bitmap(:) = 128;

range = [1,0,0,0];
for i = 1:array.count
    image = array.objectAtIndex(i);
    image = image.copy;
    image.graphicsContext.bitsPerComponent = 32;
    range(2) = image.frameSize(1);
    range(3) = range(4) + 1;
    range(4) = range(3) - 1 + image.frameSize(2);
    
    brray = image.bitmapImageArray(true);
    if brray.count < 1
        continue;
    end
    for j = 1:brray.count
        rep = brray.objectAtIndex(j);
        bitmap(range(1):range(2),range(3):range(4),:,j) = ...
            rep.bitmap.var;
    end
end

image = SYImage;
for z = 1:size(bitmap,4)
    rep = SYBitmapImageRep(SYData(bitmap(:,:,:,z)));
    image.addRepresentation(rep);
end

result = image;
end
