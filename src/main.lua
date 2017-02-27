
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"
require "util.init"

local function main()
    -- require("app.MyApp"):create():run()
    require("rect_union.MyApp"):create():run()
    cc.Director:getInstance():setDisplayStats(false)
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
