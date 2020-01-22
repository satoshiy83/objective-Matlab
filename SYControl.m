

classdef SYControl < SYView
properties (Constant)
    % State value.
    StateValueMixed = 0;
    StateValueOff = 1;
    StateVlueOn = 2;
end
    
properties
    target = nan; % id.
    action = nan; % function handle.
    
    enabled = nan; % bool.
    
    value = nan; % id.
end

methods
function obj = SYControl
    
end

function delete(obj)
    delete@SYView(obj);
end

function dest = copy(obj,dest)
    if nargin < 2
        dest = SYControl;
    end
    copy@SYView(obj,dest);
    
    dest.target = obj.target;
    dest.action = obj.action;
    dest.enabled = obj.enabled;
    dest.value = obj.value;
end

function result = sendActionTo(~,action,target)
    if isa(target,'SYObject')
        if target.respondsToSelector(action)
            target.action;
            result = true;
        else
            result = false;
        end
    else
        target.action;
    end
end

function mouseDown(~,~)
    
end

end
end
