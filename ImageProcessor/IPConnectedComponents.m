% Image Processor Class: IPConnectedComponents < SYObject.
% Written by Satoshi Yamashita.

classdef IPConnectedComponents < SYObject
properties
    bitmap = nan; % double[h,w].
    labelMap = nan; % double[h,w].
    neighborhood = nan; % double[4(8)].
end

methods(Static)

function result = connectedBinaryComponents(image,n)
% Class method to label connected non-zero pixels.
% result = connectedBinaryComponents(image,n)
% Argument image is either a bitmap raw data or SYImage instance.
% Argument n is a number of neighboring pixels, 4 or 8.
% Return value is (double[h,w]) labeled image.
    obj = IPConnectedComponents();
    
    if isnumeric(image)
        jmage = zeros(size(image,1) + 2,size(image,2) + 2);
        jmage(2:end - 1,2:end - 1) = any(image > 0,3);
        obj.bitmap = jmage;
    elseif isa(image,'SYImage')
        bitmap_ = image.drawBitmapRep(nan);
        jmage = zeros(size(bitmap_,1) + 2,size(bitmap_,2) + 2);
        jmage(2:end - 1,2:end - 1) = any(bitmap_ > 0,3);
        obj.bitmap = jmage;
    end
    obj.labelMap = zeros(size(obj.bitmap,1),size(obj.bitmap,2));
    
    h = size(obj.bitmap,1);
    if n == 8
        obj.neighborhood = [-h - 1:-h + 1,-1,1,h - 1:h + 1];
    else
        obj.neighborhood = [-h,-1,1,h];
    end
    
    indices = (find(obj.bitmap))';
    label = 1;
    for i = indices
        if obj.labelMap(i) == 0
            obj.connect(i,label);
            label = label + 1;
        end
    end
    
    result = obj.labelMap(2:end - 1,2:end - 1);
end

function result = connectedIntComponents(image,n)
% Class method to labeled connected pixels with 
% result = connectedIntComponents(image,n)
% Argument image is either a bitmap raw data or SYImage instance.
% Argument n is a number of neighboring pixels, 4 or 8.
% Return value is (double[h,w]) labeled image.
    if isa(image,'YSImage')
        image = image.drawBitmapRep(nan);
        if isa(image,'double')
            image = uint8(image * 255);
        end
    end
    
    if size(image,3) > 1
        image = IPGrayImage.grayImage(image,nan);
        if isa(image,'double')
            image = uint8(image * 255);
        end
    end
    
    bitmap = zeros(size(image));
    for i = 1:max(image(:))
        citmap = bitmap == i;
        ditmap = IPConnectedComponents.connectedBinaryComponents(citmap,n);
        bitmap = bitmap + (ditmap + max(bitmap(:))) .* citmap;
    end
    
    result = bitmap;
end

end

methods

function connect(obj,index,label)
% Method to label all pixels connected with pixel of index.
% connect(obj,index,label)
    indices = zeros(sum(obj.bitmap(:)),1);
    indices(1) = index;
    i = 1;
    j = 2;
    citmap = zeros(size(obj.bitmap,1),size(obj.bitmap,2));
    m = length(obj.labelMap(:));
    while i < j
        index = indices(i);
        obj.labelMap(index) = label;
        i = i + 1;
        
        neighbors = index + obj.neighborhood;
        neighbors(neighbors <= 0 | neighbors > m) = [];
        neighbors(obj.bitmap(neighbors) == 0) = [];
        neighbors(obj.labelMap(neighbors) > 0) = [];
        neighbors(citmap(neighbors) > 0) = [];
        if ~isempty(neighbors)
            citmap(neighbors) = 1;
            indices(j:j + length(neighbors) - 1) = neighbors;
            j = j + length(neighbors);
        end
    end
end

end
end