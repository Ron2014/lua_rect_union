--[[
无序数组
用途：
    1. M个数据中随机出N条不重复的数据（抽奖；掉落）

        a = Array()
        b = {}

        for i=1,1000000 do
            a:append(i)
            b[i] = i
        end

        length = a:length()

        tm = os.clock()
        for i=1,1000 do
            local idx = math.random(1, length)
            a:remove(idx)
            length = length - 1
        end
        print(os.clock()-tm)            -- 0

        length = #b
        tm = os.clock()
        for i=1,1000 do
            local idx = math.random(1, length)
            table.remove(b, idx)        -- 常用做法：删除数据又要保证，数据连贯
            length = length - 1
        end
        print(os.clock()-tm)            -- 5.959

--]]

Array = class("Array")
regMetaMethod(Array, "index",
function(ins, key)
    local cls = rawget(ins, "class")
    local val = cls[key]
    if val then return val end

    if type(key)=="number" then
        return ins.data_[key]
    end

    return rawget(ins, key)
end)

regMetaMethod(Array, "len",
function(ins)
    return ins:length()
end)

regMetaMethod(Array, "newindex",
function(ins, key, val)
    if type(key)=="number" then
        assert(val, "please use remove function to remove element!")

        local length = ins.length_
        assert(key>=1 and key<=length, "please use append function to add new element!")

        ins.data_[key] = val
    else
        rawset(ins, key, val)
    end
end)

regMetaMethod(Array, "tostring",
function(ins)
    return string.format("%s:%s", ins.__cname, ins:_tostring())
end)

-- override
function Array:_tostring()
    return table.concat(self:data(), "; ")
end

function Array:ctor(data)
    self:init(data)
end

function Array:init(data)
    self.data_ = data or {}
    self.length_ = #self.data_
end

function Array:length()
    return self.length_
end

function Array:data()
    return self.data_
end

function Array:append(node)
    local length = self.length_ + 1
    self.length_ = length
    self.data_[length] = node
end

-- 核心代码在此，节省删除数据的时间开销！！！
function Array:remove(index)
    local length = self.length_
    local node = self.data_[index]

    self.data_[index] = self.data_[length]
    self.data_[length] = nil
    self.length_ = length - 1

    return node
end

function Array:items( ... )
    return pairs(self.data_)
end

function Array:item(idx)
    return self.data_[idx]
end

function Array:clear()
    self.data_ = {}
    self.length_ = 0    
end

function Array:keys()
    local result = {}
    for key in sortpairs(self.data_) do
        table.insert(result, key)
    end
    return result
end