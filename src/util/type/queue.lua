--[[
队列
用途：
    1. 只能增加/删除头部和尾部的数据，不能向中间插数据，也不能删除中间的数据
        （排队显示的提示信息，关掉一个再显示下一个；
            排队创建的怪物，刷出一个怪物，过一段时间再刷出第二个）

        a = Queue()
        b = {}

        lim = 10000
        for i=1,lim do
            a:append(i)
            b[i] = i
        end

        length = a:length()

        tm = os.clock()
        for i=1,lim do
            local data = a:remove()
            -- 对data进行处理
            length = length - 1
        end
        print(os.clock()-tm)            -- 0

        length = #b
        tm = os.clock()
        for i=1,lim do
            local data = table.remove(b, 1)     -- 模拟出队
            -- 对data进行处理
            length = length - 1
        end
        print(os.clock()-tm)            -- 0.624

--]]

Queue = class("Queue", Array)
regMetaMethod(Queue, "newindex",
function(ins, key, val)
    assert(type(key)~="number", "please use function to add/remove element!")
    rawset(ins, key, val)
end)

function Queue:ctor(data)
    self.head_ = 1
    self:init(data)
end

function Queue:init(data)
    self.data_ = data or {}
    self.tail_ = self.head_ + #self.data_
end

function Queue:length()
    local head = self.head_
    local tail = self.tail_

    return tail - head
end

-- 插入队尾
function Queue:append(node)
    local tail = self.tail_
    self.data_[tail] = node
    self.tail_ = tail + 1
end

-- 出队，必是队首数据
function Queue:remove()
    local head = self.head_
    local tail = self.tail_

    if head==tail then
        -- 没数据
        return nil
    end

    local node = self.data_[head]

    self.data_[head] = nil
    self.head_ = head + 1

    return node
end

function Queue:head()
    local head = self.head_
    return self.data_[head]
end

function Queue:clear()
    self.data_ = {}
    self.head_ = 1
    self.tail_ = 1
end