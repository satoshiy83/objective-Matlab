% Foundatin Class: SYPainter < SYObject
% Written by Satoshi Yamashita.
% Fundamental class to draw into a context.

classdef SYPainter < SYObject
properties (Constant)
    segmentLine = 0;
    segmentArc = 1;
end

properties
    context = nan; % SYGraphicContext.

    segmentArray = nan; % SYArray.
    isPathClosed = nan; % Bool.

    lineWidth = nan; % Float.
    isAliased = nan; % Bool.

    initialPoint = nan; % Float[2].
    currentPoint = nan; % Float[2].
end

methods
function obj = SYPainter(context)
% Foundation class of processor.
% obj = SYPainter(context)
% Argument context is an SYGraphicContext instance to be drawn into.
    obj.context = context;

    obj.init;
end

function obj = init(obj)
% Initializing method.
% obj = init(obj)
    obj.segmentArray = SYArray;
    obj.isPathClosed = false;

    obj.lineWidth = 1.0;
    obj.isAliased = true;
end

function move(obj,point)
% Method to set an initial point.
% move(obj,point)
% The painter must be initialized or all points must be removed before.
    if ~isnan(obj.currentPoint)
        return
    end

    obj.isPathClosed = false;

    obj.initialPoint = point;
    obj.currentPoint = point;
end
function addLine(obj,point)
% Method to add a line to the point from an end point of the painter.
% addLine(obj,point)
% Argument point is a struction with fields 'x' and 'y'.
    if ~isstruct(obj.currentPoint)
        return
    end

    seg.type = SYPainter.segmentLine;
    seg.startPoint = obj.currentPoint;
    seg.endPoint = point;
    obj.segmentArray.addObject(seg);

    obj.currentPoint = point;
end
function addArc(obj,center,radius,startAngle,endAngle,clockwise)
% Method to add an arc.
% addArc(obj,center,radius,startAngle,endAngle,clockwise)
% Argument center is a structure with fields 'x' and 'y' of the arc center.
% Argument radius is a double defining the arc radius.
% Argument startAngle is a double defining the arc start angle in radian.
% Argument endAngle is a double defining the arc end angle in radian.
% Argument clockwise is a boolean specifying the arc drawn from the start
% point in clockwise or not.
    if ~isstruct(obj.currentPoint)
        return
    end

    startAngle = mod(startAngle,2 * pi());
    endAngle = mod(endAngle,2 * pi());

    startPoint.x = center.x + radius * cos(startAngle);
    startPoint.y = center.y + radius * sin(startAngle);
    endPoint.x = center.x + radius * cos(endAngle);
    endPoint.y = center.y + radius * sin(endAngle);

    if obj.currentPoint.x ~= startPoint.x || ...
            obj.currentPoint.y ~= startPoint.y
        obj.addLine(startPoint);
    end

    seg.type = SYPainter.segmentArc;
    seg.startPoint = startPoint;
    seg.endPoint = endPoint;
    seg.center = center;
    seg.radius = radius;
    seg.startAngle = startAngle;
    seg.endAngle = endAngle;
    seg.clockwise = clockwise;
    obj.segmentArray.addObject(seg);

    obj.currentPoint = endPoint;
end
function close(obj)
% Method to close the drawning path.
% close(obj)
    if ~isstruct(obj.currentPoint)
        return
    end
    
    if obj.currentPoint.x ~= obj.initialPoint.x || ...
            obj.currentPoint.y ~= obj.initialPoint.y
        obj.addLine(obj.initialPoint);
    end

    obj.initialPoint = nan;
    obj.currentPoint = nan;
    obj.isPathClosed = true;
end
function removeAllPoints(obj)
% Method to remove all points in the painter.
% emoveAllPoints(obj)
    obj.initialPoint = nan;
    obj.currentPoint = nan;
    obj.isPathClosed = false;

    obj.segmentArray.removeAllObjects;
end

function fill(obj,color)

end
function stroke(obj,color)
% Method to draw the path into the context.
% stroke(obj,color)
% Argument color is an SYColor instance or vector specifying the drawing
% color.
    if obj.segmentArray.count < 1
        return
    end

    if isa(color,"SYColor")
        color = color.color;
    end

    for i = 1:obj.segmentArray.count
        seg = obj.segmentArray.objectAtIndex(i);

        frame = enframe_segment(seg);
        siz = [frame(4) - frame(2) + 1,frame(3) - frame(1) + 1];

        mask = mask_segment(seg);

        grame = [frame(1),frame(2), ...
            frame(3) - frame(1) + 1,frame(4) - frame(2) + 1];
        if obj.context.bitsPerComponent == 8
            t = 'uint8';
        elseif obj.context.bitsPerComponent == 16
            t = 'uint16';
        elseif obj.context.bitsPerComponent == 32
            t = 'single';
        else
            t = 'double';
        end
        source = repmat(permute(cast(color(:),t),[3,2,1]),siz);
        SYGraphicsContext.drawInto(obj.context,grame,source,mask);
    end

    function result = enframe_segment(seg)
        frame = [0,0,0,0];
        if seg.type == SYPainter.segmentLine
            enframe_line();
        elseif seg.type == SYPainter.segmentArc
            enframe_arc();
        end

        function enframe_line()
            x_min = min([seg.startPoint.x, seg.endPoint.x]);
            x_max = max([seg.startPoint.x, seg.endPoint.x]);
            y_min = min([seg.startPoint.y, seg.endPoint.y]);
            y_max = max([seg.startPoint.y, seg.endPoint.y]);
            frame = [x_min - obj.lineWidth, y_min - obj.lineWidth, ...
                     x_max + obj.lineWidth, y_max + obj.lineWidth];
        end
        function enframe_arc()
            x_min = min([seg.startPoint.x, seg.endPoint.x]);
            x_max = max([seg.startPoint.x, seg.endPoint.x]);
            y_min = min([seg.startPoint.y, seg.endPoint.y]);
            y_max = max([seg.startPoint.y, seg.endPoint.y]);

            if seg.clockwise == true
                if seg.startAngle > seg.endAngle
                    if seg.endAngle < pi() / 2
                        if seg.startAngle > pi() * 0.75
                            x_min = seg.center.x - seg.radius;
%                             x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        elseif seg.startAngle > pi()
                            x_min = seg.center.x - seg.radius;
%                             x_max = seg.center.x + seg.radius;
%                             y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        elseif seg.startAngle > pi() / 2
%                             x_min = seg.center.x - seg.radius;
%                             x_max = seg.center.x + seg.radius;
%                             y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        end
                    elseif seg.endAngle < pi()
                        if seg.startAngle > pi() * 0.75
                            x_min = seg.center.x - seg.radius;
%                             x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
%                             y_max = seg.center.y + seg.radius;
                        elseif seg.startAngle > pi()
                            x_min = seg.center.x - seg.radius;
%                             x_max = seg.center.x + seg.radius;
%                             y_min = seg.center.y - seg.radius;
%                             y_max = seg.center.y + seg.radius;
                        end
                    elseif seg.endAngle < pi() * 0.75
                        if seg.startAngle > pi() * 0.75
%                             x_min = seg.center.x - seg.radius;
%                             x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
%                             y_max = seg.center.y + seg.radius;
                        end
                    end
                else % seg.startAngle < seg.endAngle
                    if seg.startAngle < pi() / 2
                        if seg.endAngle > pi() * 0.75
%                             x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
%                             y_min = seg.center.y - seg.radius;
%                             y_max = seg.center.y + seg.radius;
                        elseif seg.endAngle > pi()
%                             x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
%                             y_max = seg.center.y + seg.radius;
                        elseif seg.endAngle > pi() / 2
                            x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
%                             y_max = seg.center.y + seg.radius;
                        else
                            x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        end
                    elseif seg.startAngle < pi()
                        if seg.endAngle > pi() * 0.75
%                             x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
%                             y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        elseif seg.endAngle > pi()
%                             x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        elseif seg.endAngle > pi() / 2
                            x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        end
                    elseif seg.startAngle < pi() * 0.75
                        if seg.endAngle > pi() * 0.75
                            x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
%                             y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.ruaius;
                        elseif seg.endAngle > pi()
                            x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        end
                    else
                            x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                    end
                end
            else % seg.clockwise == false
                if seg.startAngle > seg.endAngle
                    if seg.endAngle < pi() / 2
                        if seg.startAngle > pi() * 0.75
%                             x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
%                             y_min = seg.center.y - seg.radius;
%                             y_max = seg.center.y + seg.radius;
                        elseif seg.startAngle > pi()
%                             x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
%                             y_max = seg.center.y + seg.radius;
                        elseif seg.startAngle > pi() / 2
                            x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
%                             y_max = seg.center.y + seg.radius;
                        else
                            x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        end
                    elseif seg.endAngle < pi()
                        if seg.startAngle > pi() * 0.75
%                             x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
%                             y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        elseif seg.startAngle > pi()
%                             x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        else
                            x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        end
                    elseif seg.endAngle < pi() * 0.75
                        if seg.startAngle > pi() * 0.75
                            x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
%                             y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        else
                            x_min = seg.center.x - seg.radius;
                            x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        end
                    else
                        x_min = seg.center.x - seg.radius;
                        x_max = seg.center.x + seg.radius;
                        y_min = seg.center.y - seg.radius;
                        y_max = seg.center.y + seg.radius;
                    end
                else % seg.startAngle < seg.endAngle
                    if seg.startAngle < pi() / 2
                        if seg.endAngle > pi() * 0.75
                            x_min = seg.center.x - seg.radius;
%                             x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        elseif seg.endAngle > pi()
                            x_min = seg.center.x - seg.radius;
%                             x_max = seg.center.x + seg.radius;
%                             y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        elseif seg.endAngle > pi() / 2
%                             x_min = seg.center.x - seg.radius;
%                             x_max = seg.center.x + seg.radius;
%                             y_min = seg.center.y - seg.radius;
                            y_max = seg.center.y + seg.radius;
                        end
                    elseif seg.startAngle < pi()
                        if seg.endAngle > pi() * 0.75
                            x_min = seg.center.x - seg.radius;
%                             x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
%                             y_max = seg.center.y + seg.radius;
                        elseif seg.endAngle > pi()
                            x_min = seg.center.x - seg.radius;
%                             x_max = seg.center.x + seg.radius;
%                             y_min = seg.center.y - seg.radius;
%                             y_max = seg.center.y + seg.radius;
                        end
                    elseif seg.startAngle < pi() * 0.75
                        if seg.endAngle > pi() * 0.75
%                             x_min = seg.center.x - seg.radius;
%                             x_max = seg.center.x + seg.radius;
                            y_min = seg.center.y - seg.radius;
%                             y_max = seg.center.y + seg.radius;
                        end
                    end
                end
            end

            frame = [x_min - obj.lineWidth, y_min - obj.lineWidth, ...
                     x_max + obj.lineWidth, y_max + obj.lineWidth];
        end

        result = round(frame);
    end
    function result = mask_segment(seg)
        mask = zeros(siz);

        if obj.lineWidth == 1 && obj.isAliased
            if seg.type == SYPainter.segmentLine
                mask_line();
            elseif seg.type == SYPainter.segmentArc
                mask_arc();
            end
        else
            if seg.type == SYPainter.segmentLine
                mask_line_wide();
            elseif seg.type == SYPainter.segmentArc
                mask_arc_wide();
            end
        end

        function mask_line()
            w = abs(round(seg.endPoint.x) - round(seg.startPoint.x));
            h = abs(round(seg.endPoint.y) - round(seg.startPoint.y));

            if seg.endPoint.x >= seg.startPoint.x
                x = 0:w;
            else
                x = w:-1:0;
            end
            if seg.endPoint.y >= seg.startPoint.y
                y = 0:h;
            else
                y = h:-1:0;
            end
            d = abs(h * x - w * y');

            nask = zeros([h + 1,w + 1],'logical');
            if w >= h
                [~,indices] = min(d,[],1);
                jndices = sub2ind([h + 1,w + 1],indices',(1:(w + 1))');
                nask(jndices) = true;
            else
                [~,indices] = min(d,[],2);
                jndices = sub2ind([h + 1,w + 1],(1:(h + 1))',indices);
                nask(jndices) = true;
            end
            mask(2:(2 + h),2:(2 + w)) = double(nask);
        end
        function mask_arc()
            ditmap = abs(distanceAround(frame,seg.center) - seg.radius);
            nask = ditmap <= 0.5;
            mask(nask) = 1;

            aitmap = angleAround(frame,seg.center);
            nask = angleOut(aitmap,seg);
            mask(nask) = 0;
        end
        function mask_line_wide()
            ditmap = distanceFromLine(frame,seg.startPoint,seg.endPoint);

            d = sqrt((seg.endPoint.x - seg.startPoint.x)^2 ...
                + (seg.endPoint.y - seg.startPoint.y)^2);
            e = [seg.endPoint.y - seg.startPoint.y, ...
                seg.endPoint.x - seg.startPoint.x] / d;
            xitmap = (frame(1):frame(3)) - seg.startPoint.x;
            yitmap = (frame(2):frame(4))' - seg.startPoint.y;
            iptmap = xitmap * e(2) + yitmap * e(1);
            nask = iptmap < 0 | iptmap > d;

            mask(:) = obj.lineWidth - ditmap;
            mask(mask < 0) = 0;
            mask(mask > 0.95) = 1.0;
            mask(nask) = 0;
        end
        function mask_arc_wide()
            ditmap = abs(distanceAround(frame,seg.center) - seg.radius);

            aitmap = angleAround(frame,seg.center);
            nask = angleOut(aitmap,seg);

            mask(:) = obj.lineWidth - ditmap;
            mask(mask < 0) = 0;
            mask(mask > 0.95) = 1.0;
            mask(nask) = 0;
        end

        result = mask;
    end
end

end
end

% Assistant functions.

function result = distanceAround(frame,point)
% Method returning a map of distance from a point.
% result = distanceAround(frame,point)
% Argument frame is int[4] for left, bottom, right, top positions.
% Argument point is a structure with fields 'x' and 'y'.
    xmap = (frame(1) - point.x):1:(frame(3) - point.x);
    ymap = (frame(2) - point.y):1:(frame(4) - point.y);
    result = sqrt(xmap .^ 2 + ymap' .^ 2);
end
function result = distanceFromLine(frame,point,qoint)
% Method returning a map of distance from a line.
% result = distanceFromLine(frame,point,qoint)
% Argument frame is int[4] for left, bottom, right, top positions.
% Argument point is a structure with fields 'x' and 'y' specifying the
% start of the line.
% Argument qoint is a structure with fields 'x' and 'y' specifying the end
% of the line.
    xmap = frame(1):frame(3);
    ymap = frame(2):frame(4);
    d = sqrt((qoint.x - point.x)^2 + (qoint.y - point.y)^2);
    result = abs((qoint.x - point.x)*(point.y - ymap') ...
        - (point.x - xmap)*(qoint.y - point.y)) / d;
end
function result = angleAround(frame,point)
% Method returning a map of angle in radian from a point.
% result = angleAround(frame,point)
% Argument frame is int[4] for left, bottom, right, top positions.
% Argument point is a structure with fields 'x' and 'y'.
    xmap = (frame(1) - point.x):1:(frame(3) - point.x);
    ymap = (frame(2) - point.y):1:(frame(4) - point.y);
    amap = angle(xmap + 1i * ymap');
    mask = amap < 0;
    amap(mask) = amap(mask) + 2 * pi;
    result = amap;
end
function result = angleOut(amap,seg)
% Method returning a mask for an arc segment.
% result = angleOut(amap,seg)
% Argument amap is a map of angle in radian.
% Argument seg is an arc segment structure.
    if seg.clockwise
        if seg.startAngle > seg.endAngle
            result = amap > seg.startAngle | amap < seg.endAngle;
        else
            result = amap > seg.startAngle & amap < seg.endAngle;
        end
    else
        if seg.startAngle > seg.endAngle
            result = amap < seg.startAngle & amap > seg.endAngle;
        else
            result = amap < seg.startAngle | amap > seg.endAngle;
        end
    end
end
