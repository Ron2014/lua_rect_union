
local ViewBase = class("ViewBase", cc.Node)

function ViewBase:ctor(app, name)
    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResourceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResourceBinding(binding)
    end

    self:onCreate()
end

function ViewBase:onCreate()
end

function ViewBase:getApp()
    return self.app_
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:createResourceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    assert(self.resourceNode_, string.format("ViewBase:createResourceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

--[[
通过配置，简化控件响应的初始化操作：
RESOURCE_BINDING = {
    childName = {               -- 控件名
        varname = xxx,          -- 对应变量名
        events = {
            {event = "touch", method = xxx},    -- 这里只写了一个对touch处理的示例, onTouch写在Widget、GameView
            {event = xxx, method = xxx},
            ...
        },
    }
}
]]
function ViewBase:createResourceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResourceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node = self.resourceNode_:getChildByName(nodeName)
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                node:onTouch(handler(self, self[event.method]))
            end
        end
    end
end

function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:add(self)
    display.runScene(scene, transition, time, more)
    return self
end

-- 注册控件事件========================================================
function ViewBase:getListeners()
    if not self.listeners_ then
        self.listeners_ = {}
    end
    return self.listeners_
end

function ViewBase:regTouch(widget, funcName, eventType)
    if not widget then
        print("======== regTouch error!!! no widget")
        return
    end
    
    -- print("======regTouch success", funcName)
    local listeners = self:getListeners()
    if eventType then
        listeners[widget] = listeners[widget] or Dict:create()
        listeners[widget]:set(eventType, funcName)
    else
        listeners[widget] = funcName
    end

    widget:addTouchEventListener(self.onProcessTouch, self)
end

function ViewBase.onProcessTouch(sender, eventType)
    -- print("===========ViewBase.onProcessTouch 1", eventType)
    local sender = sender.obj_ or sender
    if not sender:isVisible() then return end

    -- print("===========ViewBase.onProcessTouch 2", sender, sender.wnd_)
    local wnd = sender.wnd_
    if not (wnd and wnd:isValid()) then return end

    -- print("===========ViewBase.onProcessTouch 3")
    local listeners = wnd:getListeners()
    local callback = listeners[sender]
    if iskindof(callback, "Dict") then
        callback = callback:get(eventType)
    end

    -- print("===========ViewBase.onProcessTouch 4", callback)
    local func = wnd[callback]
    if func then
        func(wnd, sender, eventType)
    end
end

return ViewBase
