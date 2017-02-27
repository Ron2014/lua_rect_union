
MainScene = singletonClass("MainScene", cc.load("mvc").ViewBase)

local GridView = import("rect_union.views.GridView")
import("rect_union.models.Calculator")

function MainScene:onCreate()
    GridView:create()
        :addTo(self, 1)

    self.blocks_ = {}
    self.schFlash_ = scheduler:create(functor(self.flashBlocks, self), 1)
end

function MainScene:clearBlocks()
    for _, sprite in pairs(self.blocks_) do
        sprite:removeFromParent()
    end
    self.blocks_ = {}
end

function MainScene:flashBlocks()
    if not self:isValid() then
        scheduler:remove(self.schFlash_)
        return
    end

    local tm = os.time()
    local visible = tm%2==0
    for _, sprite in pairs(self.blocks_) do
        sprite:setVisible(visible)
    end
end

function MainScene:showBlocks(blocks)
    -- GridView():clearSelected()

    self:clearBlocks()

    for id, block in sortpairs(blocks:data()) do
        local rect = block:getRect()

        local sprite = cc.Sprite:create()
        sprite:setAnchorPoint(0,0)
        sprite:setColor(display.randomColor())
        sprite:setPosition(rect.x, rect.y)
        sprite:setTextureRect(cc.rect(0, 0, rect.width, rect.height))
        sprite:addTo(self, 1)

        self.blocks_[id] = sprite
    end
end

function MainScene:onCleanup()
    scheduler:remove(self.schFlash_)
    self:onDestroy()
end

return MainScene