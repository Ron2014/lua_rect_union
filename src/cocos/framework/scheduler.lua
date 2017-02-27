
local scheduler = scheduler or {}
local sch = cc.Director:getInstance():getScheduler()

function scheduler:create(func, interval, delay)
    if type(func)~="function" then return end

    local delayFunc = nil
    local delay = delay or 0
    local paused = (delay>0)
    local id = sch:scheduleScriptFunc(func, interval, paused)

    if paused then
        self:once(functor(self.pause, self, id, false), delay)
    else
        func()
    end

    return id
end

function scheduler:once(func, delay)
    if type(func)~="function" then return end
    if delay<=0 then func() return end 
    return sch:scheduleScriptFunc(func, delay, false)
end

function scheduler:pause(id, paused)
    sch:pauseScriptEntry(id, paused)
end

function scheduler:remove(id)
    if id==nil then return end
    return sch:unscheduleScriptEntry(id)
end

return scheduler