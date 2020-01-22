% Image Processor Class: IPEpitheliumSurface < SYObject.
% Written by Satoshi Yamashita.

classdef IPEpitheliumSurface < SYObject
properties(Constant)
    rodRadius = 1;
end

methods(Static)

function result = epitheliumSurface(image,normal,cellDiameter, ...
        threshold,direction)
% Class method to draw a depth map of epithelium apical surface in a stack.
% result = epitheliumSurface(image,normal,cellDiameter,threshold,direction)
% Argument (SYImage) image is the image stack of epithelium.
% Argument (char) normal specifies an axis of reslicing, either by 'x' or
% 'y'.
% Argument (double) cellDiameter specifies the maximum width of cells.
% Argument (double) threshold specifies signal-noise ratio.
% Argument (char) direction specifies how to choose the apical surface at
% each point, either by 'first' or 'last'.
    window = figure;
    
    bitmapRep = image.representations.objectAtIndex(1);
    jmage = SYImage;
    jmage.addRepresentation(bitmapRep);
    hstgrm = IPHistogram.imageHistogram(jmage,256,nan);
    h = cumsum(hstgrm(2,:)) / sum(hstgrm(2,:));
    i = find(h > threshold,1);
    t = hstgrm(1,i);
    
    if isequal(normal,'y')
        jmage = IPSlicer.sliceXZ(image);
    else
        jmage = IPSlicer.sliceYZ(image);
    end
    
    epi_surf = SYData;
    epi_surf.var = zeros(bitmapRep.height,bitmapRep.width,'uint16');
    kmage = SYImage(epi_surf);
    width = bitmapRep.width;
    height = bitmapRep.height;
    if width > 512
        r = 512 / width;
        width = 512;
        height = round(height * r);
    end
    if height > 512
        r = 512 / height;
        height = 512;
        width = round(width * r);
    end
    kmage.frameSize = [height,width];
    range = [0,1];
    
    siz = round(jmage.frameSize * r);
    
    bitmap = SYData; citmap = SYData;
    
    ditmap = zeros(height + siz(1),width,'uint16');
    
    array = jmage.bitmapImageArray(false);
    for i = 1:array.count
        bitmapRep = array.objectAtIndex(i);
        bitmap.var = uint8(bitmapRep.bitmap.var < t);
        bitmap.var(1,:) = 1;
        bitmap.var(end,:) = 0;
        bitmap.var = IPConnectedComponents.connectedBinaryComponents( ...
            bitmap.var,4);
        bitmap.var = bitmap.var == bitmap.var(1,1);

        IPEpitheliumSurface.removeDusts(bitmap);

        citmap.var = IPEpitheliumSurface.curvetureOfCurveture(bitmap);

        IPEpitheliumSurface.focusBendingPoints(citmap,2);

        IPEpitheliumSurface.bridgeEdges(bitmap,citmap,cellDiameter);
        
        IPEpitheliumSurface.bridgeRims(bitmap,citmap,cellDiameter);
        
        bitmap.var(1,:) = true;
        
        bitmap.var = IPConnectedComponents.connectedBinaryComponents( ...
            uint8(bitmap.var),4);
        bitmap.var = uint16(bitmap.var == bitmap.var(1,1));
        
        mask = bitmap.var(2:end,:) > 0;
        mask = cat(1,mask,zeros(1,size(mask,2),'logical'));
        bitmap.var(mask) = 0;
        bitmap.var(end,:) = 1;

        for j = 1:size(bitmap.var,2)
            d = find(bitmap.var(:,j),1,direction);
            
            if isequal(normal,'y')
                epi_surf.var(i,j) = d;
            else
                epi_surf.var(j,i) = d;
            end
            range(2) = max([range(2),d]);
        end
        
        if ishandle(window)
            kmage.range = range;
            lmage = SYImage(bitmap);
            lmage.frameSize = siz;
            lmage.range = [0,1];
            
            figure(window);
            
            ditmap(1:height,:) = kmage.drawBitmapRep(nan);
            ditmap(height + 1:end,:) = lmage.drawBitmapRep(nan);
            
            if ishandle(window)
                imshow(ditmap);
                drawnow;
            end
        end
    end
    
    if ishandle(window)
        delete(window);
    end
    
    kmage.frameSize = image.frameSize;
    result = kmage;
end
function removeDusts(bitmap)
% Class method to remove negative pixel adjacent to 3 positive pixels.
% removeDusts(bitmap)
% Argument (SYData) bitmap carries logical bitmap data in which apical
% extra cellular space is filled with positive value.
    citmap = zeros(size(bitmap.var) + 2,'uint8');
    m = [-1,0; 0,-1; 1,0; 0,1];
    indices = 2:size(bitmap.var,1) + 1;
    jndices = 2:size(bitmap.var,2) + 1;
    while true
        citmap(:) = 0;
        for i = 1:size(m,1)
            citmap(indices + m(i,1),jndices + m(i,2)) = ...
                citmap(indices + m(i,1),jndices + m(i,2)) + ...
                uint8(bitmap.var);
        end
        ditmap = citmap(2:end - 1,2:end - 1);
        ditmap(bitmap.var) = 0;
        
        ditmap = ditmap > 2;
        if any(ditmap(:))
            bitmap.var(ditmap) = true;
        else
            return;
        end
    end
end
function result = curvetureOfCurveture(bitmap)
% Class method to plot curvature of apical surface.
% result = curvetureOfCurveture(bitmap)
% Argument (SYData) bitmap carries logical bitmap data in which apical
% extra cellular space is filled with positive value.
    citmap = bitmap.var(1:end - 1,:);
    citmap(bitmap.var(2:end,:)) = false;
    ditmap = double(citmap) .* (1:size(citmap,1))';
    
    eitmap = zeros([size(bitmap.var),3]);
    
    d = 4;
    for x = d + 1:size(citmap,2) - d
        column = ditmap(:,x);
        for y = (column(citmap(:,x)))'
            dyp = 0;
            dyn = 0;
            for dx = 1:d
                ys = ditmap(:,x + dx);
                ys = ys(citmap(:,x + dx));
                dys = ys - y;
                [~,I] = min(abs(dys));
                dyp = dyp + dys(I) / dx;
                
                ys = ditmap(:,x - dx);
                ys = ys(citmap(:,x - dx));
                dys = y - ys;
                [~,I] = min(abs(dys));
                dyn = dyn + dys(I) / dx;
            end
            dyp = dyp / d;
            dyn = dyn / d;
            eitmap(y,x,1) = dyp - dyn;
            eitmap(y,x,2) = dyp;
            eitmap(y,x,3) = dyn;
        end
    end
    
    result = eitmap;
end
function focusBendingPoints(citmap,threshold)
% Class method to mark points on apical surface with curveture larger than
% the threshold.
% focusBendingPoints(citmap,threshold)
% Argument (SYData) citmap carries 3 channels double bitmap data of
% curveture.
% Argument (double) threshold specifies the threshold for curvature.
    ditmap = uint8(citmap.var(:,:,1) > threshold);
    if ~any(ditmap(:))
        citmap.var(:,:,1) = 0;
        return;
    end
    
    ditmap = IPConnectedComponents.connectedBinaryComponents(ditmap,8);
    eitmap = zeros(size(ditmap));
    for i = 1:max(ditmap(:))
        fitmap = ditmap == i;
        gitmap = fitmap .* citmap.var(:,:,1);
        [~,I] = max(gitmap(:));
        eitmap(I) = 1;
    end
    citmap.var(:,:,1) = eitmap;
end
function bridgeEdges(bitmap,citmap,gap)
% Class method to draw a line between two points on bitmap.
% stroke(bitmap,points)
% Argument (SYData) bitmap carries logical bitmap data in which apical
% extra cellular space is filled with positive value.
% Argument (SYData) citmap carries 3 channels double bitmap data of
% curveture.
% Argument (double) gap is the maximum width of a cell.
    siz = size(bitmap.var);
    indices = find(citmap.var(:,:,1));
    [rows,columns] = ind2sub(siz,indices');
    for i = 1:length(indices)
        y1 = rows(i);
        x1 = columns(i);
        jndices = abs(columns - x1) < gap;
        
        kndices = columns - x1 > 0;
        lndices = find(jndices & kndices);
        for j = lndices
            y2 = rows(j);
            x2 = columns(j);
            dy = y2 - y1;
            dx = x2 - x1;
            
            s1 = abs((dy / dx) - citmap.var(y1,x1,3));
            s2 = abs((dy / dx) - citmap.var(y2,x2,2));
            if s1 < 0.3 && s2 < 0.3
                IPEpitheliumSurface.stroke(bitmap,[x1,y1 + 1; x2,y2 + 1]);
            end
        end
        
        kndices = columns - x1 < 0;
        lndices = find(jndices & kndices);
        for j = lndices
            y2 = rows(j);
            x2 = columns(j);
            dy = y1 - y2;
            dx = x1 - x2;
            
            s1 = abs((dy / dx) - citmap.var(y1,x1,2));
            s2 = abs((dy / dx) - citmap.var(y2,x2,3));
            if s1 < 0.3 && s2 < 0.3
                IPEpitheliumSurface.stroke(bitmap,[x1,y1 + 1; x2,y2 + 1]);
            end
        end
    end
end
function stroke(bitmap,points)
% Class method to draw a line between two points on bitmap.
% stroke(bitmap,points)
% Argument (SYData) bitmap carries logical bitmap data in which apical
% extra cellular space is filled with positive value.
% Argument (int[2,2]) points carries two row vectors between which line is
% drawn.
    p = points(1,:);
    q = points(2,:);
    
    siz = size(bitmap.var);
    if p(1) < 1 || p(2) < 1 || p(1) > siz(2) || p(2) > siz(1) || ...
            q(1) < 1 || q(2) < 1 || q(1) > siz(2) || q(2) > siz(1)
        disp('Break!');
        return;
    end
    
    d = ceil(sqrt((p(1) - q(1)) ^ 2 + (p(2) - q(2)) ^ 2));
    for i = 0:d
        r = round((p * i + q * (d - i)) / d);
        bitmap.var(r(2),r(1)) = false;
    end
end
function bridgeRims(bitmap,citmap,gap)
% Class method to draw lines from bending points to rim of image.
% bridgeRims(bitmap,citmap,gap)
% Argument (SYData) bitmap carries logical bitmap data in which apical
% extra cellular space is filled with positive value.
% Argument (SYData) citmap carries 3 channels double bitmap data of
% curveture.
% Argument (double) gap is the maximum width of a cell.
    siz = size(bitmap.var);
    indices = find(citmap.var(:,:,1));
    [rows,columns] = ind2sub(siz,indices');
    
    indices = find(columns < gap);
    for i = indices
        x1 = columns(i);
        y1 = rows(i);
        
        d = sqrt(citmap.var(y1,x1,2) ^ 2 + 1) * x1;
        if d < gap
            x2 = 1;
            y2 = round(y1 - citmap.var(y1,x1,2) * x1);
            if y2 < 1
                y2 = 1;
            elseif y2 >= siz(1)
                y2 = siz(1) - 1;
            end
            IPEpitheliumSurface.stroke(bitmap,[x1,y1 + 1; x2,y2 + 1]);
        end
    end
    
    w = size(bitmap.var,2);
    snmuloc = w - columns;
    indices = find(snmuloc < gap);
    for i = indices
        x1 = columns(i);
        y1 = rows(i);
        
        d = sqrt(citmap.var(y1,x1,3) ^ 2 + 1) * snmuloc(i);
        if d < gap
            x2 = w;
            y2 = round(y1 + citmap.var(y1,x1,3) * snmuloc(i));
            if y2 < 1
                y2 = 1;
            elseif y2 >= siz(1)
                y2 = siz(1) - 1;
            end
            IPEpitheliumSurface.stroke(bitmap,[x1,y1 + 1; x2,y2 + 1]);
        end
    end
end
% function dropEdges(bitmap,citmap)
%     siz = size(bitmap.var);
%     indices = find(citmap.var(:,:,1));
%     [rows,columns] = ind2sub(siz,indices');
%     for i = 1:length(indices)
%         x = columns(i);
%         y = rows(i);
%         bitmap.var(y:end,x) = false;
%     end
% end

function result = surfaceOFSlice(image,slice,normal,cellDiameter,threshold)
% Class method to test surface detection at one slice.
% result = surfaceOFSlice(image,slice,normal,cellDiameter,threshold)
% Argument (SYImage) is a stack image.
% Argument (double) slice specifies the slice to be tested. If \in [0,1],
% it specifies a propotional position of the slice.
% Argument (char) normal specifies an axis of reslicing, either by 'x' or
% 'y'.
% Argument (double) cellDiameter specifies the maximum width of cells.
% Argument (double) threshold specifies signal-noise ratio.
    bitmapRep = image.representations.objectAtIndex(1);
    jmage = SYImage;
    jmage.addRepresentation(bitmapRep);
    hstgrm = IPHistogram.imageHistogram(jmage,256,nan);
    h = cumsum(hstgrm(2,:)) / sum(hstgrm(2,:));
    i = find(h > threshold,1);
    t = hstgrm(1,i);
    
    if isequal(normal,'y')
        jmage = IPSlicer.sliceXZ(image);
    else
        jmage = IPSlicer.sliceYZ(image);
    end
    
    if slice >= 0 && slice <= 1
        slice = round(slice * jmage.countStack);
    end
    if slice < 1
        slice = 1;
    elseif slice > jmage.countStack
        slice = jmage.countStack;
    end
    
    array = jmage.bitmapImageArray(false);
    bitmapRep = array.objectAtIndex(slice);
    bitmap = SYData;
    bitmap.var = uint8(bitmapRep.bitmap.var < t);
    bitmap.var(1,:) = 1;
    bitmap.var(end,:) = 0;
    bitmap.var = IPConnectedComponents.connectedBinaryComponents( ...
        bitmap.var,4);
    bitmap.var = bitmap.var == bitmap.var(1,1);

    IPEpitheliumSurface.removeDusts(bitmap);

    citmap.var = IPEpitheliumSurface.curvetureOfCurveture(bitmap);

    IPEpitheliumSurface.focusBendingPoints(citmap,2);

    IPEpitheliumSurface.bridgeEdges(bitmap,citmap,cellDiameter);

    IPEpitheliumSurface.bridgeRims(bitmap,citmap,cellDiameter);

    bitmap.var(1,:) = true;

    bitmap.var = IPConnectedComponents.connectedBinaryComponents( ...
        uint8(bitmap.var),4);
    bitmap.var = uint16(bitmap.var == bitmap.var(1,1));
    
    jmage = SYImage(bitmap);
    jmage.range = [0,1];
    jmage.addRepresentation(bitmapRep);
    result = jmage;
end

function result = projectSurface(image,surface,thickness)
% Class method to project apical surface.
% result = projectSurface(image,surface,thickness)
% Argument (SYImage) image is the stack.
% Argument (SYImage) surface is a grayscale image of depth map.
% Argument (double) thickness is depth below apical surface being
% projected.
    siz = image.frameSize;
    bitsPerComponent = image.graphicsContext.bitsPerComponent;
    if bitsPerComponent == 8
        d = 'uint8';
    elseif bitsPerComponent == 16
        d = 'uint16';
    elseif bitsPerComponent == 32
        d = 'single';
    elseif bitsPerComponent == 64
        d = 'double';
    end
    bitmap = zeros(siz,d);
    
    bitmapRep = surface.representations.objectAtIndex(1);
    surface = bitmapRep.bitmap.var;
    
    array = image.bitmapImageArray(false);
    z_count = array.count;
    
    for x = 1:siz(2)
        for y = 1:siz(1)
            z = surface(y,x);
            if z + thickness > z_count
                indices = z:z_count;
            else
                indices = z:z + thickness;
            end
            c = 0;
            for z = indices
                bitmapRep = array.objectAtIndex(z);
                c = max([c,bitmapRep.bitmap.var(y,x)]);
            end
            bitmap(y,x) = c;
        end
    end
    
    result = SYImage(SYData(bitmap));
end

end
end
