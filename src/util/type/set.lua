--[[
集合
--]]

Set = class("Set", Dict)

-- override
function Set:_tostring()
    return table.concat(self:keys(), "; ")
end

function Set:ctor(...)
    Set.super.ctor(self)

    local args = {...}
    for _, v in pairs(args) do
        self:append(v)
    end
end

function Set:set(value, key)
    if key == nil then
        key = value
        value = true
    end
    Set.super.set(self, key, value)
end

function Set:append(...)
    self:set(...)
end