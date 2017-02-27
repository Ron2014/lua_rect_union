GridSprite = class("GridSprite", function(id)
        local params = GridSprite.params
        local widget = ccui.Widget:create()
        widget:setAnchorPoint(0, 0)
        widget:setContentSize(params.size)
        return widget
    end)

GridSprite.params = {
    rect = cc.rect(0, 0, 75, 75),
    capInsets = cc.rect(0, 0, 75, 75),
    size = cc.size(UNIT_SIZE, UNIT_SIZE),
}

function GridSprite:ctor(id)
    local params = GridSprite.params

    self.id_ = id
    self:setPosition(getPositionById(id))

    local size = params.size
    local frame = display.newSprite("grid.png", size.width * 0.5, size.height * 0.5, params)
        :addTo(self)
    self.frame_ = frame

    local row, col = getRowAndColumnById(id)
    local text = string.format("%s\n(%s,%s)", id, row, col)
    local title = cc.Label:createWithSystemFont(text, "Arial", 9)
        :addTo(self)
        :setPosition(size.width * 0.5, size.height * 0.5)
    self.title_ = title

    local rect = cc.rect(0,0,size.width,size.height)
    local area = cc.Sprite:create()
    area:setAnchorPoint(0,0)
    area:setColor(cc.c3b(254,223,18))
    area:setOpacity(128)
    area:setPosition(0, 0)
    area:setTextureRect(rect)
    area:addTo(self)
    area:hide()
    self.area_ = area
end

function GridSprite:hideArea()
    self.area_:hide()
end

function GridSprite:showArea()
    self.area_:show()
end

function GridSprite:id()
    return self.id_
end

return GridSprite