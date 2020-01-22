% Foundation Class: SYNotificatoinCenter < SYObject
% Written by Satoshi Yamashita.
% Fundamental Class distributing notifications to observers.
% It prepares shared SYNotificationCenter instance named defaultCenter.

classdef SYNotificationCenter < SYObject
properties (Constant)
    defaultCenter = SYNotificationCenter;
end
properties
    queueToPostWhenIdle = nan; % SYArray.
    
    unLinkedObserverArray = nan; % SYArray.
    linkedObserverArray = nan; % SYArray.
    nameArray = nan; % SYArray.
end

methods
function obj = SYNotificationCenter
% Foundation class to distribute notifications to observers.
% obj = SYNotificationCenter
    obj = obj.init;
end
function obj = init(obj)
% Initializing method.
% obj = init(obj)
    init@SYObject(obj);
    
    obj.queueToPostWhenIdle = SYArray;
    obj.unLinkedObserverArray = SYArray;
    obj.linkedObserverArray = SYArray;
    obj.nameArray = SYArray;
end

function addObserver(obj,observer,selector,name,sender)
% Method to add an observer with function handle, name, and sender.
% addObsever(obj,observer,selector,name,sender)
% Argument (id) observer is an object respoding to a notification.
% Argument (function handle) selector is a method of the observer to
% respond. The selector must follow @selector(obj,notification) syntax and
% is given SYNotification object to the argument.
% Argument (char) name is a name of the event sender will send.
% Argument (id) sender is an object to send the notification. If nan, the
% observer will receive notifications with the name from any sender.
    index = obj.nameArray.indexOfObject(name);
    if isempty(index)
        obj.nameArray.addObject(name);
        index = obj.nameArray.count;
        obj.unLinkedObserverArray.addObject(SYArray);
        obj.linkedObserverArray.addObject(SYArray(SYArray,SYArray));
    end
    
    if isnan(sender)
        array = obj.unLinkedObserverArray.objectAtIndex(index);
        array.addObject(SYArray(observer,selector));
    else
        array = obj.linkedObserverArray.objectAtIndex(index);
        brray = array.objectAtIndex(1);
        crray = array.objectAtIndex(2);
        jndex = brray.indexOfObject(sender);
        if isempty(jndex)
            brray.addObject(sender);
            drray = SYArray;
            crray.addObject(drray);
        else
            drray = crray.objectAtIndex(jndex);
        end
        drray.addObject(SYArray(observer,selector));
    end
end
function removeObserver(obj,observer,name,sender)
% Method to remove observer.
% removeObserver(obj,observer,name,sender)
% Argument (id) observer is the observer object to be removed.
% Argument (char) name is a name of event where an entry of the observre
% associated with the name is removed. If nan, the event name is not used
% as a criteria to remove the observer.
% Argument (id) sender is an object sending a notification where an entry
% of the observer associated with the sender is removed. If nan, the sender
% is not used as a criteria to remove ther observer.
    if obj.nameArray.count < 1
        return;
    end
    
    if isnan(name)
        indices = 1:obj.nameArray.count;
    else
        indices = obj.nameArray.indexOfObject(name);
    end
    
    for i = indices
        if isnan(sender)
            array = obj.unLinkedObserverArray.objectAtIndex(i);
            if array.count > 0
                for j = array.count:-1:1
                    brray = array.objectAtIndex(j);
                    object = brray.objectAtIndex(1);
                    if object == observer
                        array.removeObjectAtIndex(j);
                    end
                end
            end
            
            array = obj.linkedObserverArray.objectAtIndex(i);
%             brray = array.objectAtIndex(1);
            crray = array.objectAtIndex(2);
            if crray.count > 0
                for j = 1:crray.count
                    drray = crray.objectAtIndex(j);
                    if drray.count < 1
                        continue;
                    end
                    for k = drray.count:-1:1
                        erray = drray.objectAtIndex(k);
                        object = erray.objectAtIndex(1);
                        if object == observer
                            drray.removeObjectAtIndex(k);
                        end
                    end
                end
            end
        else
            array = obj.linkedObserverArray.objecAtIndex(i);
            brray = array.objectAtIndex(1);
            crray = array.objectAtIndex(2);
            jndex = brray.indexOfObject(sender);
            if isempty(jndex)
                continue;
            end
            drray = crray.objectAtIndex(jndex);
            if drray.count < 1
                continue;
            end
            for j = drray.count:-1:1
                erray = drray.objectAtIndex(j);
                object = erray.objectAtIndex(1);
                if object == observer
                    drray.removeObjectAtIndex(j);
                end
            end
        end
    end
end

function postNotification(obj,notification)
% Method to post a notification.
% postNotification(obj,notification)
% Argument (SYNotification) is a notification containing an event name and
% its sender.
    name = notification.name;
    sender = notification.object;
    
    index = obj.nameArray.indexOfObject(name);
    if isempty(index)
        return;
    end
    
    array = obj.unLinkedObserverArray.objectAtIndex(index);
    if array.count > 0
        for i = 1:array.count
            brray = array.objectAtIndex(i);
            pbj = brray.objectAtIndex(1);
            selector = brray.objectAtIndex(2);
            selector(pbj,notification);
        end
    end
    
    array = obj.linkedObserverArray.objectAtIndex(index);
    brray = array.objectAtIndex(1);
    crray = array.objectAtIndex(2);
    jndex = brray.indexOfObject(sender);
    if isempty(jndex)
        return;
    end
    array = crray.objectAtIndex(jndex);
    if array.count > 0
        for i = 1:array.count
            brray = array.objectAtIndex(i);
            pbj = brray.objectAtIndex(1);
            selector = brray.objectAtIndex(2);
            selector(pbj,notification);
        end
    end
end
function postNotificationName(obj,name,sender)
% Method to post a notification with the event name and sender.
% postNotificationName(obj,name,sender)
% Argument (char) name is the name of event.
% Argument (id) sender is an object to send the notification.
    index = obj.nameArray.indexOfObject(name);
    if isempty(index)
        return;
    end
    
    notification = SYNotification;
    notification.initWithName(name,sender);
    
    array = obj.unLinkedObserverArray.objectAtIndex(index);
    if array.count > 0
        for i = 1:array.count
            brray = array.objectAtIndex(i);
            pbj = brray.objectAtIndex(1);
            selector = brray.objectAtIndex(2);
            selector(pbj,notification);
        end
    end
    
    array = obj.linkedObserverArray.objectAtIndex(index);
    brray = array.objectAtIndex(1);
    crray = array.objectAtIndex(2);
    jndex = brray.indexOfObject(sender);
    if isempty(jndex)
        return;
    end
    array = crray.objectAtIndex(jndex);
    if array.count > 0
        for i = 1:array.count
            brray = array.objectAtIndex(i);
            pbj = brray.objectAtIndex(1);
            selector = brray.objectAtIndex(2);
            selector(pbj,notification);
        end
    end
end

function postStoredNotifications(obj)
    if obj.queueToPostWhenIdle.count < 1
        return;
    end
    
    array = obj.queueToPostWhenIdle.copy;
    obj.queueToPostWhenIdle.removeAllObjects;
    
    for i = 1:array.count
        notification = array.objectAtIndex(i);
        obj.postNotification(notification);
    end
end
function postNotificationWhenIdle(obj,notification)
    obj.queueToPostWhenIdle.addObject(notification);
end
function postNotificatonNameWhenIdle(obj,name,sender)
    notification = SYNotification;
    notification.initWithName(name,sender);
    
    obj.queueToPostWhenIdle.addObject(notification);
end

end
end
