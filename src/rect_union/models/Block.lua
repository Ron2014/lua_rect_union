Block = class("Block")

regMetaMethod(Block, "tostring",
function(self)
    return string.format("Block:(%s,%s)-(%s,%s)", self.lbRow_, self.lbCol_, self.rtRow_, self.rtCol_)
end)

function Block:ctor(headId, tailId)
    self.headId_ = headId
    self:setTail(tailId or headId)
end

function Block:head()
    return self.headId_
end

function Block:tail()
    return self.tailId_
end

function Block:width()
    return (self.rtCol_ - self.lbCol_ + 1) * UNIT_SIZE
end

function Block:height()
    return (self.rtRow_ - self.lbRow_ + 1) * UNIT_SIZE
end

function Block:setTail(tailId)
    self.tailId_ = tailId

    self.lbRow_, self.lbCol_ = getRowAndColumnById(self.headId_)
    self.rtRow_, self.rtCol_ = getRowAndColumnById(self.tailId_)
end

function Block:getRect()
    local x0, y0 = getPositionById(self.headId_)                -- 左下角
    return cc.rect(x0, y0, self:width(), self:height())
end

function Block:lineUp()
    local row = self.rtRow_ + 1
    if row > ROW then return end

    local id0, id1 = getIdByRowAndColumn(row, self.lbCol_), getIdByRowAndColumn(row, self.rtCol_)

    local i = 0
    return function()
        local id = id0 + i
        if id > id1 then
            return nil, nil
        end
        i = i + 1
        return i, id
    end, id0, id1
end

function Block:lineDown()
    local row = self.lbRow_ - 1
    if row < 1 then return end

    local id0, id1 = getIdByRowAndColumn(row, self.lbCol_), getIdByRowAndColumn(row, self.rtCol_)

    local i = 0
    return function()
        local id = id0 + i
        if id > id1 then
            return nil, nil
        end
        i = i + 1
        return i, id
    end, id0, id1
end

function Block:lineLeft()
    local col = self.lbCol_ - 1
    if col < 1 then return end

    local id0, id1 = getIdByRowAndColumn(self.lbRow_, col), getIdByRowAndColumn(self.rtRow_, col)

    local i = 0
    return function()
        local id = id0 + i*COLUMN
        if id > id1 then
            return nil, nil
        end
        i = i + 1
        return i, id
    end, id0, id1
end

function Block:lineRight()
    local col = self.rtCol_ + 1
    if col > COLUMN then return end

    local id0, id1 = getIdByRowAndColumn(self.lbRow_, col), getIdByRowAndColumn(self.rtRow_, col)

    local i = 0
    return function()
        local id = id0 + i*COLUMN
        if id > id1 then
            return nil, nil
        end
        i = i + 1
        return i, id
    end, id0, id1
end

return Block