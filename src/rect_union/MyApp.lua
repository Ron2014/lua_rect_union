
local MyApp = class("MyApp", cc.load("mvc").AppBase)
MyApp.configs_ = {
    viewsRoot  = "rect_union.views",
    modelsRoot = "rect_union.models",
    defaultSceneName = "MainScene",
}

function MyApp:onCreate()
    MyApp.super.onCreate(self)
    math.randomseed(os.time())
end

return MyApp
