% Foundation Class: SYImage < SYObject.
% Written by Satoshi Yamashita.
% Fundamental class of image to open, handle, and export bitmap data.

classdef SYImage < SYObject
properties
    representations = nan; % SYArray.
    
    data = nan; % SYData.
    frameSize = nan; % double[2].
    graphicsContext = nan; % SYGraphicsContext.
    range = nan; % doble[n,2].
    focused = false; % bool.
end

methods
function obj = SYImage(input)
% Foundation class representing an image.
% obj = SYImage(input)
% Optional argument input is either bitmap raw data, SYData instance 
% containing it, or file path.
    if nargin < 1
        obj.init;
        return;
    end
    
    if isa(input,'SYData')
        obj.initWithData(input);
    elseif isa(input,'SYGraphicsContext')
        obj.initWithGraphicsContext(input);
    elseif isa(input,'SYBitmapImageRep')
        obj.initWithBitmapRep(input);
    elseif isnumeric(input)
        obj.initWithData(SYData(input));
    elseif ischar(input) || isstring(input)
        obj.initWithContentsOfFile(input);
    end
end

function obj = init(obj)
% Initialization method.
% obj = init(obj)
    init@SYObject(obj);
    
    obj.representations = SYArray;
end
function obj = initWithData(obj,data)
% Initialization method with SYData instance.
% obj = initWithData(obj,data)
% Note that the argument data is not a formated data of image but a pseudo
% pointer using SYData.
    obj.init;
    
    bitmapRep = SYBitmapImageRep(data);
    obj.addRepresentation(bitmapRep);
    
    obj.prepareGraphicsContext;
end
function obj = initWithBitmapRep(obj,bitmapRep)
% Initialization method with SYBitmapImageRep instance.
% obj = initWithBitmapRep(obj,rep)
    obj.init;

    obj.addRepresentation(bitmapRep);

    obj.prepareGraphicsContext;
end
function obj = initWithContentsOfFile(obj,path)
% Initialization method with file path.
% obj = initWithContentsOfFile(obj,path)
    obj.init;
    
    if isstring(path)
        path = convertStringsToChars(path);
    end

    array = strsplit(path,'.');
    ext = array{end};
    if isequal(ext,'tif') || isequal(ext,'tiff') || isequal(ext,'TIF')
        info = imfinfo(path);
        num_stack = numel(info);
        for i = 1:num_stack
            bitmap = imread(path,i,'Info',info);
            bitmapRep = SYBitmapImageRep(SYData(bitmap));
            obj.addRepresentation(bitmapRep);
        end
    else
        if isequal(ext,'png')
            [bitmap,~,alpha] = imread(path);
            if ~isempty(alpha)
                bitmap = cat(3,bitmap,alpha);
            end
        else
            bitmap = imread(path);
        end
        bitmapRep = SYBitmapImageRep(SYData(bitmap));
        obj.addRepresentation(bitmapRep);
    end
    obj.prepareGraphicsContext;
end
function obj = initWithGraphicsContext(obj,context)
% Initialization method with SYGraphcisContext.
% obj = initWithGraphicsContext(obj,context)
% Note that a first SYBitmapRep is initialized from the context and so the
% context's bitamp data must be allocated in advance.
    obj.init;
    
    bitmapRep = SYBitmapImageRep(context.data.copy);
    obj.addRepresentation(bitmapRep);
    
    obj.graphicsContext = context;
end

function prepareGraphicsContext(obj)
% Method to prepare graphicsContext from first imageRep.
% prepareGraphicsContext(obj)
    if obj.countStack < 1
        return;
    end
    
    bitmapRep = obj.representations.objectAtIndex(1);
    if isnan(obj.frameSize)
        width = bitmapRep.width;
        height = bitmapRep.height;
    else
        width = obj.frameSize(2);
        height = obj.frameSize(1);
    end
    bitsPerComponenet = bitmapRep.bitsPerComponent;
    compositeMode = SYGraphicsContext.CompositeModeOver;
    lut = nan;
    switch bitmapRep.componentsPerPixel
        case 1
            if isnumeric(bitmapRep.bitmap.var)
                colorSpace = SYGraphicsContext.ColorSpaceGrayscale;
                obj.range = [min(bitmapRep.bitmap.var(:)), ...
                    max(bitmapRep.bitmap.var(:))];
            elseif islogical(bitmapRep.bitmap.var)
                colorSpace = SYGraphicsContext.ColorSpaceIndexed;
                lut = uint8([0,0,0; 255,255,255]);
                obj.range = [0,1];
            end
        case 3
            colorSpace = SYGraphicsContext.ColorSpaceRGB;
        case 4
            colorSpace = SYGraphicsContext.ColorSpaceRGBA;
        otherwise
            colorSpace = SYGraphicsContext.ColorSpaceComposite;
    end
    if bitsPerComponenet == 8
        d = 'uint8';
    elseif bitsPerComponenet == 16
        d = 'uint16';
    elseif bitsPerComponenet == 32
        d = 'single';
    else
        d = 'double';
    end
    
    if colorSpace == SYGraphicsContext.ColorSpaceGrayscale
        c = 1;
    elseif colorSpace == SYGraphicsContext.ColorSpaceRGBA
        c = 4;
    else
        c = 3;
    end
    obj.data = SYData(zeros(height,width,c,d));
%     obj.data.var = obj.drawBitmapRep();
    
    context = SYGraphicsContext;
    context.initWithContext(obj.data,width,height,bitsPerComponenet, ...
        compositeMode,colorSpace,lut,obj.range);
    obj.graphicsContext = context;
    
    obj.frameSize = [height,width];

    obj.data.var = obj.drawBitmapRep();
end
function set.graphicsContext(obj,context)
    obj.graphicsContext = context;
    obj.setGraphicsContext(context);
end
function setGraphicsContext(obj,context)
% Bypass method from set.graphicsContext.
% Do not call directly.
    obj.data = context.data;
    obj.frameSize = [context.height,context.width];
    obj.range = context.range;
end
function set.frameSize(obj,siz)
    obj.frameSize = siz;
    obj.setFrameSize(siz);
end
function setFrameSize(obj,siz)
% Bypass method from set.frameSize.
% Do not call directly.
    obj.graphicsContext.width = siz(2);
    obj.graphicsContext.height = siz(1);
    
%     obj.data.var = obj.drawBitmapRep(nan);
end
function set.range(obj,newRange)
    obj.range = newRange;
    obj.setRange(newRange);
end
function setRange(obj,newRange)
% Bypass method from set.range.
% Do not call directly.
    if ~isnan(obj.graphicsContext)
        obj.graphicsContext.range = newRange;
    end
    
%     obj.data.var = obj.drawBitmapRep(nan);
end
function setCompositeMode(obj,mode)
% Method to set (SYGraphicsContext.CompositeMode) composite mode.
% setCompositeMode(obj,mode)
    obj.graphicsContext.compositeMode = mode;
    
%     obj.data.var = obj.drawBitmapRep(nan);
end
function setLut(obj,lut)
% Method to set look up table.
% setLut(obj,lut)
    obj.graphicsContext.lut = lut;
    
%     obj.data.var = obj.drawBitmapRep(nan);
end

function delete(obj)
    if obj.focused
        obj.unlockFocus;
    end
    
    delete@SYObject(obj);
end

function dest = copy(obj,dest)
% Method to make a 'shallow' copy.
% dest = copy(obj,dest)
    if nargin < 2
        dest = SYImage;
    end
    copy@SYObject(obj,dest);
    
    dest.representations = obj.representations.copy;
%     dest.data = obj.data.copy;
%     dest.frameSize = obj.frameSize;
    dest.graphicsContext = obj.graphicsContext.copy;
%     dest.range = obj.range;
end

function result = writeToFile(obj,path_,scaled)
% Method to write the image into a file.
% result = writeToFile(obj,path,scaled)
% Argument path specifies the file path.
% Argument scaled is boolean, indicating either color and frame are raw or
% according to the image graphics context.
% Return value is a boolean indicating whether the image is written into
% the file.
    if obj.countStack < 1
        result = false;
        return;
    end

    if isstring(path_)
        path_ = convertStringsToChars(path_);
    end
    
    stack = obj.bitmapImageArray(scaled);
    
    strs = strsplit(path_,'.');
    ext = strs{end};
    if strcmp(ext,'tif') || strcmp(ext,'tiff')
        tag = obj.tagForTiff(scaled);
        result = obj.writeTiffToFile(path_,stack,tag);
    elseif strcmp(ext,'gif')
        result = obj.writeGifToFile(path_,stack);
    elseif strcmp(ext,'jpeg') || strcmp(ext,'jpg')
        result = obj.writeJpegToFile(path_,stack);
    elseif strcmp(ext,'png')
        result = obj.writePngToFile(path_,stack);
    elseif strcmp(ext,'ras')
        result = obj.writeRasToFile(path_,stack);
    end
end
function result = writeTiffToFile(~,path_,stack,tag)
% Submethod called by writeToFile.
% result = writeTiffToFile(~,path_,stack,tag)
% Do not call directly.
    timg = Tiff(path_,'w');
    timg.setTag(tag);
    
    bitmapRep = stack.objectAtIndex(1);
    if tag.SampleFormat == Tiff.SampleFormat.IEEEFP
        timg.write(single(bitmapRep.bitmap.var));
    else
        timg.write(bitmapRep.bitmap.var);
    end
    timg.close();
    result = true;
    
    if stack.count > 1
        for i = 2:stack.count
            timg = Tiff(path_,'a');
            timg.setTag(tag);
            bitmapRep = stack.objectAtIndex(i);
            if tag.SampleFormat == Tiff.SampleFormat.IEEEFP
                timg.write(single(bitmapRep.bitmap.var));
            elseif tag.BitsPerSample == 8
                timg.write(uint8(bitmapRep.bitmap.var));
            elseif tag.BitsPerSample == 16
                timg.write(uint16(bitmapRep.bitmap.var));
            end
            timg.close();
        end
    end
end
function result = tagForTiff(obj,scaled)
% Submethod called by writeToFile.
% result = tagForTiff(obj,scaled)
% Do not call directly.
    if scaled
        tag.ImageLength = obj.frameSize(1);
        tag.ImageWidth = obj.frameSize(2);
        if obj.graphicsContext.bitsPerComponent == 8
            tag.BitsPerSample = 8;
            tag.SampleFormat = Tiff.SampleFormat.UInt;
        elseif obj.graphicsContext.bitsPerComponent == 16
            tag.BitsPerSample = 16;
            tag.SampleFormat = Tiff.SampleFormat.UInt;
        elseif obj.graphicsContext.bitsPerComponent == 32
            tag.BitsPerSample = 32;
            tag.SampleFormat = Tiff.SampleFormat.IEEEFP;
        elseif obj.graphicsContext.bitsPerComponent == 64
            tag.BitsPerSample = 32;
            tag.SampleFormat = Tiff.SampleFormat.IEEEFP;
        end
        if obj.graphicsContext.colorSpace == ...
                SYGraphicsContext.ColorSpaceGrayscale
            tag.SamplesPerPixel = 1;
            tag.Photometric = Tiff.Photometric.MinIsBlack;
        elseif obj.isTransparent
            tag.SamplesPerPixel = 4;
            tag.ExtraSamples = Tiff.ExtraSamples.AssociatedAlpha;
            tag.Photometric = Tiff.Photometric.RGB;
        else
            tag.SamplesPerPixel = 3;
            tag.Photometric = Tiff.Photometric.RGB;
        end
    else
        bitmapRep = obj.representations.objectAtIndex(1);
        tag.ImageLength = bitmapRep.height;
        tag.ImageWidth = bitmapRep.width;
        if bitmapRep.bitsPerComponent == 8
            tag.BitsPerSample = 8;
            tag.SampleFormat = Tiff.SampleFormat.UInt;
        elseif bitmapRep.bitsPerComponent == 16
            tag.BitsPerSample = 16;
            tag.SampleFormat = Tiff.SampleFormat.UInt;
        elseif bitmapRep.bitsPerComponent == 32
            tag.BitsPerSample = 32;
            tag.SampleFormat = Tiff.SampleFormat.IEEEFP;
        elseif bitmapRep.bitsPerComponent == 64
            tag.BitsPerSample = 32;
            tag.SampleFormat = Tiff.SampleFormat.IEEEFP;
        end
        if obj.graphicsContext.colorSpace == ...
                SYGraphicsContext.ColorSpaceComposite
            tag.SamplesPerPixel = 1;
            tag.Photometric = Tiff.Photometric.MinIsBlack;
        elseif bitmapRep.componentsPerPixel == 4
            tag.SamplesPerPixel = 4;
            tag.ExtraSamples = Tiff.ExtraSamples.AssociatedAlpha;
            tag.Photometric = Tiff.Photometric.RGB;
        elseif bitmapRep.componentsPerPixel == 3
            tag.SamplesPerPixel = 3;
            tag.Photometric = Tiff.Photometric.RGB;
        else
            tag.SamplesPerPixel = 1;
            tag.Photometric = Tiff.Photometric.MinIsBlack;
        end
    end
    tag.Compression = Tiff.Compression.None;
    tag.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    
    result = tag;
end
function result = writeGifToFile(~,path_,stack)
% Submethod called by writeToFile.
% result = writeGifToFile(~,path_,stack)
% Do not call directly.
    bitmapRep = stack.objectAtIndex(1);
    imwrite(bitmapRep.bitmap.var,path_,'Compresssion','none');
    result = true;
    
    if stack.count > 1
        for i = 2:stack.count
            bitmapRep = stack.objectAtIndex(i);
            imwrite(bitmapRep.bitmap.var,path_,'WriteMode','append', ...
                'Compression','none');
        end
    end
end
function result = writeJpegToFile(~,path_,stack)
% Submethod called by writeToFile.
% result = writeJpegToFile(~,path_,stack)
% Do not call directly.
    if stack.count == 1
        bitmapRep = stack.objectAtIndex(1);
        imwrite(bitmapRep.bitmap.var,path_);
        result = true;
    else
        array = strsplit(path_,'.');
        ext = array{end};
        str = [path_(1:length(path_) - length(ext) - 1),'-stack'];
        mkdir(str);
        for i = 1:stack.count
            ttr = [str,'/slice-',num2str(i),'.',ext];
            bitmapRep = stack.objectAtIndex(i);
            imwrite(bitmapRep.bitmap.var,ttr);
        end
    end
end
function result = writePngToFile(obj,path_,stack)
% Submethod called by writeToFile.
% result = writePngToFile(obj,path_,stack)
% Do not call directly.
    if stack.count == 1
        bitmapRep = stack.objectAtIndex(1);
        if obj.isTransparent
            imwrite(bitmapRep.bitmap.var(:,:,1:3),path_, ...
                'Alpha',bitmapRep.bitmap.var(:,:,4));
        else
            imwrite(bitmapRep.bitmap.var(:,:,:),path_);
        end
        result = true;
    else
        array = strsplit(path_,'.');
        ext = array{end};
        str = [path_(1:length(path_) - length(ext) - 1),'-stack'];
        mkdir(str);
        for i = 1:stack.count
            ttr = [str,'/slice-',num2str(i),'.',ext];
            bitmapRep = stack.objectAtIndex(i);
            if obj.isTransparent
                imwrite(bitmapRep.bitmap.var(:,:,1:3),ttr, ...
                    'Alpha',bitmapRep.bitmap.var(:,:,4));
            else
                imwrite(bitmapRep.bitmap.var(:,:,:),ttr);
            end
        end
    end
end
function result = writeRasToFile(~,path_,stack)
% Submethod called by writeToFile.
% result = writeRasToFile(~,path_,stack)
% Do not call directly.
    if stack.count == 1
        bitmapRep = stack.objectAtIndex(1);
        if obj.isTransparent
            imwrite(bitmapRep.bitmap.var(:,:,1:3),path_, ...
                'Alpha',bitmapRep.bitmap.var(:,:,4));
        else
            imwrite(bitmapRep.bitmap.var(:,:,:),path_);
        end
        result = true;
    else
        array = strsplit(path_,'.');
        ext = array{end};
        str = [path_(1:length(path_) - length(ext) - 1),'-stack'];
        mkdir(str);
        for i = 1:stack.count
            ttr = [str,'/slice-',num2str(i),'.',ext];
            bitmapRep = stack.objectAtIndex(i);
            if obj.isTransparent
                imwrite(bitmapRep.bitmap.var(:,:,1:3),ttr, ...
                    'Alpha',bitmapRep.bitmap.var(:,:,4));
            else
                imwrite(bitmapRep.bitmap.var(:,:,:),ttr);
            end
        end
    end
end

function result = bitmapImageArray(obj,scaled)
% Method returning an array of image reps of image type, called by
% writeToFile().
% result = bitmapImageArray(obj,scaled)
% Argument (bool) scaled indicates whether the image is scaled according to
% obj graphics context.
% Return value is an SYArray instance containing image reps.
    array = SYArray;
    for i = 1:obj.representations.count
        bitmapRep = obj.representations.objectAtIndex(i);
        if bitmapRep.repType ~= SYBitmapImageRep.RepTypeImage
            continue;
        end
        
        if scaled
            data_ = SYData(obj.drawBitmapRep(bitmapRep));
            array.addObject(SYBitmapImageRep(data_));
        else
            if obj.graphicsContext.colorSpace == ...
                    SYGraphicsContext.ColorSpaceComposite
                array.addObjectsFromArray(bitmapRep.splitChannels);
            else
                array.addObject(bitmapRep);
            end
        end
    end
    result = array;
end

function result = drawBitmapRep(obj,bitmapRep)
% Method to draw an image according to obj graphics context.
% result = drawBitmapRep(obj,bitmapRep)
% Argument (SYBitmapImageRep) bitmapRep is the image to be drawn. It can be
% nan, and if so, this method draw obj first image rep.
% Return value is a bitmap raw data.
    if nargin < 2 || isnan(bitmapRep)
        bitmapRep = obj.representations.objectAtIndex(1);
    end
    
    if obj.graphicsContext.colorSpace == ...
            SYGraphicsContext.ColorSpaceGrayscale
        c = 1;
    elseif obj.isTransparent
        c = 4;
    else
        c = 3;
    end
    if obj.graphicsContext.bitsPerComponent == 8
        d = 'uint8';
    elseif obj.graphicsContext.bitsPerComponent == 16
        d = 'uint16';
    elseif obj.graphicsContext.bitsPerComponent == 32
        d = 'single';
    else
        d = 'double';
    end
    
    width = obj.frameSize(2);
    height = obj.frameSize(1);
    bitmap = zeros(height,width,c,d);
    
    if obj.graphicsContext.colorSpace == ...
            SYGraphicsContext.ColorSpaceIndexed || ...
            obj.graphicsContext.colorSpace == ...
            SYGraphicsContext.ColorSpaceComposite
       if length(obj.graphicsContext.lut) < 2
           result = bitmap;
           return;
       end
    end
    
    xRange = [0,0];
    color = SYColor(obj.graphicsContext.bitsPerComponent, ...
        obj.graphicsContext.colorSpace, ...
        nan, ...
        obj.graphicsContext.lut, ...
        obj.graphicsContext.range);
    for x = 1:bitmapRep.width
        xRange(1) = xRange(2) + 1;
        xRange(2) = round(x * width / bitmapRep.width);
        if xRange(1) > xRange(2)
            continue;
        end
        yRange = [0,0];
        for y = 1:bitmapRep.height
            yRange(1) = yRange(2) + 1;
            yRange(2) = round(y * height / bitmapRep.height);
            if yRange(1) > yRange(2)
                continue;
            end
            color.color = bitmapRep.colorAtXY(x,y);
            if obj.graphicsContext.colorSpace == ...
                    SYGraphicsContext.ColorSpaceGrayscale
                bitmap(yRange(1):yRange(2),xRange(1):xRange(2)) = ...
                    color.grayColor;
            elseif obj.isTransparent
                w = xRange(2) - xRange(1) + 1;
                h = yRange(2) - yRange(1) + 1;
                bitmap(yRange(1):yRange(2),xRange(1):xRange(2),:) = ...
                    ones(h,w,d) .* permute(color.RGBAColor,[1,3,2]);
            else
                w = xRange(2) - xRange(1) + 1;
                h = yRange(2) - yRange(1) + 1;
                bitmap(yRange(1):yRange(2),xRange(1):xRange(2),:) = ...
                    ones(h,w,d) .* permute(color.RGBColor,[1,3,2]);
            end
        end
    end
    
    result = bitmap;
end

function result = isTransparent(obj)
% Method indicating if obj has an alpha channel.
% result = isTransparent(obj)
% Return value is a boolean.
    result = obj.graphicsContext.isTransparent;

%     if obj.graphicsContext.colorSpace == ...
%             SYGraphicsContext.ColorSpaceRGBA || ...
%             obj.graphicsContext.colorSpace == ...
%             SYGraphicsContext.ColorSpaceHSBA
%         result = true;
%     elseif obj.graphicsContext.colorSpace == ...
%             SYGraphicsContext.ColorSpaceIndexed || ...
%             obj.graphicsContext.colorSpace == ...
%             SYGraphicsContext.ColorSpaceComposite
%         lut = obj.graphicsContext.lut;
%         if size(lut,2) > 3
%             result = true;
%         else
%             result = false;
%         end
%     else
%         result = false;
%     end
end

function showImage(obj)
% Method to display obj first image rep in a window.
% showImage(obj)
%     bitmap = obj.drawBitmapRep(nan);
    bitmap = obj.data.var;
    if obj.isTransparent
        bitmap(:,:,4) = [];
    end
    imshow(bitmap);
end

function addRepresentation(obj,rep)
% Method to add a image representation.
% addRepresentation(obj,rep)
% Argument rep is either an SYBitmapImageRep instance or SYData instance
% holding bitmap data.
    if ~isa(rep,'SYBitmapImageRep')
        rep = SYBitmapImageRep(rep);
    end
    
    obj.representations.addObject(rep);
    
    if isnan(obj.graphicsContext)
        obj.prepareGraphicsContext;
    end
end
function result = countStack(obj)
% Method returning a number of slices in a stack.
% result = countStack(obj)
    if obj.representations.count < 1
        result = 0;
        return;
    end
    
    count = 0;
    for i = 1:obj.representations.count
        rep = obj.representations.objectAtIndex(i);
        if rep.repType == SYBitmapImageRep.RepTypeImage
            count = count + 1;
        end
    end
    result = count;
end

function splitChannels(obj)
% Method to split channels into grayscale slices.
% splitChannels(obj)
    if obj.countStack < 1
        return;
    end
    
    array = SYArray();
    for i = 1:obj.countStack
        rep = obj.representations.objectAtIndex(i);
        if rep.repType == SYBitmapImageRep.RepTypeImage
            array.addObjectsFromArray(rep.splitChannels);
        else
            array.addObject(rep);
        end
    end
    obj.representations = array;
    
    obj.graphicsContext.colorSpace = SYGraphicsContext.ColorSpaceGrayscale;
end

end
end
