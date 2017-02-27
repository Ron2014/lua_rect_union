Calculator = singletonClass("Calculator")

local Block = import("rect_union.models.Block")

function Calculator:clean()
    self.count_ = 0
    self.cost_ = 0
    self.minResult_ = nil
    self.marked_ = {}
    self.result_ = Stack:create()

    MainScene():clearBlocks()
end

SEARCH_DIRECT = {
    { "lineRight",    true,   },
    { "lineUp",       true,   },
    { "lineLeft",     false,  },
    { "lineDown",     false,  },
}

-- a = {
--     length = 0,
--     blocks = {},
--     visited = Set(),
--     current = nil,
-- }

function Calculator:run()
    self:clean()

    local selected = GridView():getSelect()
    local grids = ArrayX:create()

    for id in pairs(selected:data()) do
        grids:append(id)
    end

    local tm = os.clock()
    self:perm(0, grids, nil)
    print(selected:length(), os.clock() - tm)
    
    -- print("DONE!!!", self.cost_, self.count_)
    self:show()
end

function Calculator:isMarked(head, tail)
    return self.marked_[head] and self.marked_[head][tail]
end

function Calculator:mark(head, tail)
    self.marked_[head] = self.marked_[head] or {}
    self.marked_[head][tail] = true
end

function Calculator:CheckOneMoreLength(hasLeft)
    if not self.minResult_ then
        return true
    end

    local minLength = self.minResult_:length()
    local length = self.result_:length()

    if hasLeft then
        return length + 2 < minLength
    end

    return length + 1 < minLength
end

function Calculator:foundOne(depth, grids, block)
    assert(block, "no block")

    -- local blank = {}
    -- for i=1,depth,1 do
    --     blank[i] = "    "
    -- end
    -- blank = table.concat(blank)

    -- printf("%s %s %d", blank, block, grids:length())

    -- self:CheckCostStart()
    local isChecked = self:CheckOneMoreLength(grids:length()>0) -- 373 0.045
    -- self:CheckCostEnd()

    if not isChecked then
        return
    end

    self.result_:push(block)
    self:perm(depth, grids, nil)
    self.result_:pop()
end

function Calculator:recordResult()
    self.minResult_ = Stack:create()

    for _, node in ipairs(self.result_:data()) do
        printf("===%s", node)
        self.minResult_:push(node)
    end

    print("====Calculator:recordResult", self.result_:length())
end

function Calculator:CheckCostStart()
    self.costStart_ = os.clock()
end

function Calculator:CheckCostEnd()
    self.cost_ = (self.cost_ or 0) + (os.clock() - self.costStart_)
    self.costStart_ = nil
    self.count_ = (self.count_ or 0) + 1
end

function Calculator:perm(depth, grids, block)
    depth = depth + 1

    local length = grids:length()

    if length>0 then
        if block then
            --1. 上下左右合并
            local _head, _tail = block:head(), block:tail()

            for _, node in ipairs(SEARCH_DIRECT) do
                local head, tail = _head, _tail
                local canMerge, dels = false, {}

                local method, forward = unpack(node)

                self:CheckCostStart()
                local iter, id0, id1 = block[method](block) -- 376 0.257
                self:CheckCostEnd()

                if forward then
                    tail = id1
                else
                    head = id0
                end

                if iter and not self:isMarked(head, tail) then
                    canMerge = true
                    
                    for i, id in iter do
                        if grids:exist(id) then
                            grids:remove(id)
                        else
                            canMerge = false
                            break
                        end
                    end
                end

                if canMerge then
                    self:mark(head, tail)

                    -- self:CheckCostStart()
                    local newBlock = Block:create(head, tail)   -- 377 0.130
                    -- self:CheckCostEnd()

                    self:perm(depth, grids, newBlock)
                end

                grids:recover(length)
            end

            --2. 不合并
            self:foundOne(depth, grids, block)
        else
            local id = grids:item(1)

            -- self:CheckCostStart()
            local block = Block:create(id)  -- 377 0.130
            -- self:CheckCostEnd()

            grids:remove(id)
            self:perm(depth, grids, block)
            grids:append(id)
        end

    else
        -- show result
        if block then
            self:foundOne(depth, grids, block)
        else
            self:recordResult()
        end
    end
end

function Calculator:show()
    if not self.minResult_ then
        print("still no result")
        return
    end

    MainScene():showBlocks(self.minResult_)
end
