% Foundation Class: SYNotification.
% Written by Satoshi Yamashita.
% The fundamental class to notify event.

classdef SYNotification < SYObject
properties
    name = nan;
    object = nan;
end

methods

function obj = initWithName(obj,name,object)
% Initialization method with notificaton name and sender object.
% obj = initWithName(obj,name,object)
% The argument (char) name is a name of notification.
% The argument (id) object is a sender object.
    obj.name = name;
    obj.object = object;
end

end
end
