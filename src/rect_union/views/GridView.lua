
-- GridView is a combination of view and controller
GridView = singletonClass("GridView", cc.load("mvc").ViewBase)
local GridSprite = import("rect_union.views.GridSprite")

function GridView:onCreate()
    local grids = {}

    local id = 0
    for i=1,ROW,1 do
        for j=1,COLUMN,1 do
            id = id + 1
            grids[id] = GridSprite:create(id):addTo(self)
        end
    end

    -- 响应区
    local interact = ccui.Widget:create()
    interact:setAnchorPoint(0, 0)
    interact:setContentSize(CC_DESIGN_RESOLUTION.width, CC_DESIGN_RESOLUTION.height)
    interact:addTo(self)

    interact:setTouchEnabled(true)
    self:regTouch(interact, "onTouchGridBegin", TOUCH_EVENT_BEGAN)
    self:regTouch(interact, "onTouchGridEnded", TOUCH_EVENT_ENDED)
    self:regTouch(interact, "onTouchGridMoved", TOUCH_EVENT_MOVED)
    self:regTouch(interact, "onTouchGridCanceled", TOUCH_EVENT_CANCELED)

    self.grids_ = grids
    self.selected_ = Set:create()
    self.selecting_ = false
end

function GridView:clearSelected()
    for _, id in pairs(self.selected_:keys()) do
        self:selectGrid(id)
    end
end

function GridView:startSelect()
    if not self:isValid() then
        return
    end
    self.selecting_ = true
end

function GridView:onTouchGridBegin(sender)
    self.schTouch_ = scheduler:once(functor(self.startSelect, self), 0.5)
end

function GridView:onTouchGridCanceled(sender)
    scheduler:remove(self.schTouch_)
    self.schTouch_ = nil
end

function GridView:onTouchGridEnded(sender)
    self:onTouchGridCanceled(sender)

    if self.selecting_ then
        self.selecting_ = false
    else
        local pos = sender:getTouchEndPosition()
        local id = getIdByPosition(pos)
        print(pos.x, pos.y, id)
        self:selectGrid(id)
    end
end

function GridView:onTouchGridMoved(sender)
    if self.selecting_ then
        local pos = sender:getTouchMovePosition()
        local id = getIdByPosition(pos)
        print(pos.x, pos.y, id)
        self:selectGrid(id, true)
    end
end

function GridView:selectGrid(id, force)
    local grid = self.grids_[id]
    if not grid then return end

    if self.selected_:exist(id) then
        if force then return end
        self.selected_:remove(id)
        grid:hideArea()
    else
        self.selected_:append(id)
        grid:showArea()
    end
end

function GridView:getSelect()
    return self.selected_
end

return GridView