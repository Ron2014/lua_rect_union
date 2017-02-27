ArrayX = class("ArrayX", Array)

regMetaMethod(ArrayX, "newindex",
function(ins, key, val)
    assert(type(key)~="number", "please use append/remove")
    rawset(ins, key, val)
end)

function ArrayX:init(data)
    self.data_ = {}
    self.index_ = {}
    self.length_ = 0

    if not data then return end

    for v in pairs(data) do
        self:append(v)
    end
end

function ArrayX:append(node)
    if self:exist(node) then
        self:remove(node)
    end

    self.length_ = self.length_ + 1

    local index = self.index_[node]
    local last = self.data_[self.length_]
    if index and last then
        self.data_[index] = last
        self.index_[last] = index
    end

    self.data_[self.length_] = node
    self.index_[node] = self.length_
end

function ArrayX:exist(node)
    local index = self.index_[node]
    if not index then return end

    if index > self.length_ then return end

    return true
end

function ArrayX:remove(node)
    local index = self.index_[node]
    if not index then return end
    self:removeAt(index)
    return index
end

function ArrayX:removeAt(index)
    if index > self.length_ then return end

    local node = self.data_[index]
    if not node then return end

    local last = self.data_[self.length_]

    self.index_[node] = self.length_
    self.data_[self.length_] = node

    self.index_[last] = index
    self.data_[index] = last

    self.length_ = self.length_ - 1

    return node
end

function ArrayX:recover(length)
    assert(length<=(#self.data_), "ArrayX:recover length error")
    self.length_ = length
end

function ArrayX:items()
    local i = 0
    return function()
        i = i + 1
        return self:item(i)
    end
end

function ArrayX:item(idx)
    if idx>0 and idx<=self.length_ then
        return self.data_[idx]
    end
end

function ArrayX:clear()
    self.data_ = {}
    self.index_ = {}
    self.length_ = 0    
end