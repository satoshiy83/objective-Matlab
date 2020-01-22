

classdef SYApplication < SYResponder
properties (Constant)
    sharedApplication = SYApplication;
end
properties
    delegate = nan; % id.
    
    eventQueue = nan; % SYArray.
    running = nan; % bool.
    
    windows = nan; % SYArray.
end

methods
function obj = SYApplication
    
end

function obj = init(obj)
    init@SYResponder(obj);
    
    obj.eventQueue = SYArray;
    defaultCenter = SYNotificationCenter.defaultCenter;
    defaultCenter.init;
    
    obj.windows = SYArray;
end

function run(obj)
    defaultCenter = SYNotificationCenter.defaultCenter;
    
    obj.running = true;
    while obj.running
        if obj.eventQueue.count > 0
            event = obj.eventQueue.objectAtIndex(1);
            obj.eventQueue.removeObjectAtIndex(1);
            obj.sendEvent(event);
        end
        
        defaultCenter.postStoredNotifications;
        
        % temporal treatment.
        pause(0.001);
    end
end
function stop(obj)
    obj.running = false;
end
function terminate(obj)
    obj.running = false;
    % under construction.
end

function sendEvent(obj,event)
    % under construction.
end
function postEventAtStart(obj,event,startFlag)
    if startFlag
        obj.eventQueue.insertObjectAtIndex(event,1);
    else
        obj.eventQueue.addObject(event);
    end
end


end
end
