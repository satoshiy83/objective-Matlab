

classdef SYButton < SYControl
properties
    button = nan; % uicontrol.
    
    state = nan; % SYControl.StateValue.
end

methods
function obj = SYButton

end

function obj = init(obj)
    init@SYControl(obj);
    
    obj.button = uicontrol;
    obj.button.Style = 'pushbutton';
    obj.button.Callback = @button_invoked;
    
    function button_invoked(~,~)
        obj.mouseDown(nan);
    end
end
function obj = initWithFrame(obj,frame)
    initWithFrame@SYControl(obj,frame);
    
    obj.button.Position = frame;
end

function setWindow(obj,newWindow)
    obj.button.Parent = newWindow;
end



end
end
