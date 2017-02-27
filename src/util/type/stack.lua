--[[
栈
用途：
    1. 先入后出的数据。可以使用的场合：
        （场景管理。从此场景会到刚刚的场景
            界面管理。新弹出的界面显示在最上一层，关掉后，刚刚的界面显示在最上一层）

        a = Stack()
        b = {}

        lim = 1000000
        for i=1,lim do
            a:push(i)
            b[i] = i
        end

        length = a:length()

        tm = os.clock()
        for i=1,lim do
            local data = a:pop()
            -- 对data进行处理
            length = length - 1
        end
        print(os.clock()-tm)            -- 0.234

        length = #b

        tm = os.clock()
        for i=1,lim do  
            local data = b[length]      -- 模拟出栈
            b[length] = nil
            -- 对data进行处理
            length = length - 1
        end
        print(os.clock()-tm)            -- 0.125

--]]

Stack = class("Stack", Array)
regMetaMethod(Stack, "newindex",
function(ins, key, val)
    assert(type(key)~="number", "please use function to add/remove element!")
    rawset(ins, key, val)
end)

function Stack:ctor()
    self.data_ = {}
    self.top_ = 0
end

function Stack:length()
    return self.top_
end

function Stack:append(node)
    self:push(node)
end

function Stack:remove()
    return self:pop()
end

-- 入栈
function Stack:push(node)
    local top = self.top_ + 1
    self.data_[top] = node
    self.top_ = top
end

-- 插入队首（插队）
function Stack:pop(idx)
    local top = self.top_
    local idx = idx or top

    assert(top>0 and idx>0, "can't pop when stack is empty")

    if idx<=top then
        local node = self.data_[idx]
        for i=idx,top,1 do
            self.data_[i] = self.data_[i+1]
        end
        self.data_[top] = nil
        self.top_ = top - 1
        return node
    end
end

function Stack:top()
    local top = self.top_
    return self.data_[top]
end

function Stack:clear()
    self.data_ = {}
    self.top_ = 0   
end