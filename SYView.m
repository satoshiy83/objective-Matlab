

classdef SYView < SYResponder
properties
    frame = nan; % int[4].
    
    superview = nan; % SYView.
    subviews = nan; % SYArray.
    window = nan; % figure handle.
end

methods
function obj = SYView

end

function obj = init(obj)
    obj.subviews = SYArray;
end
function obj = initWithFrame(obj,frame)
    obj.init;
    
    obj.frame = frame;
end

function set.frame(obj,newFrame)
    obj.frame = newFrame;
    obj.setFrame(newFrame);
end
function setFrame(~,~)
    
end
function set.window(obj,newWindow)
    obj.window = newWindow;
    obj.setWindow(newWindow);
end
function setWindow(~,~)
    
end

function delete(obj)
    obj.subviews.makeObjectsPerformSelector(@removeFromSuperview);
    
    if ~isnan(obj.superview)
        obj.removeFromSuperview;
    end
    
    delete@SYResponder(obj);
end

function dest = copy(obj,dest)
    if nargin < 2
        dest = SYView;
    end
    copy@SYResponder(obj,dest);
    
    obj.frame = obj.frame;
    obj.subviews = SYArray;
end

function removeFromSuperview(obj)
    array = obj.superview.subviews;
    array.removeObject(obj);
    
    obj.superview = nan;
end

function addSubview(obj,view)
    obj.subviews.addObject(view);
    view.superview = obj;
    view.window = obj.window;
end

function displayView(obj)
    obj.drawRect(obj.frame);
    
    if obj.subviews.count > 0
        for i = 1:obj.subviews.count
            view = obj.subviews.objectAtIndex(i);
            view.displayView;
        end
    end
end
function drawRect(~,~)
    
end

end
end
