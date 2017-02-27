
local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    MyApp.super.onCreate(self)
    math.randomseed(os.time())
end

return MyApp
