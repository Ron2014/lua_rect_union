--- 指令方法集
local gm_cmd = gm_cmd or {}

function gm_cmd:execute(chunk)
    local func, err = loadstring(chunk)
    if err then
        print(err)
    else
        func()
    end
end

function gm_cmd:reload(filepath, moduleName)
    local length = #filepath
    local s, e = string.find(filepath, ".lua")
    if not (s and e and e==length) then
        filepath = string.format("%s.lua", filepath)
    end

    local fullpath = cc.FileUtils:getInstance():fullPathForFilename(filepath)
    local func, err = loadfile(fullpath)
    if err then
        print(err)
    else
        func()
        print(string.format("reload %s success", fullpath))
    end
end

function gm_cmd:print(chunk)
    if string.sub(chunk, #chunk) == ")" then
        chunk = string.format("_v = %s", chunk)

        local func, err = loadstring(chunk)
        if err then
            print(err)
        else
            func()
            dump(_v)
        end
    else
        local args = string.split(chunk, ".")
        local v = _G
        for _, name in pairs(args) do
            if v==nil then
                print("can't find value", chunk)
                return
            end

            v = v[name]
        end
        dump(v)
    end
end

function gm_cmd:trace(filepath, line)
end

-- function gm_cmd:breakpoint(filepath, line)
-- end

gm_cmd.e = gm_cmd.execute
gm_cmd.r = gm_cmd.reload
gm_cmd.p = gm_cmd.print
gm_cmd.t = gm_cmd.trace
-- commands.b = commands.breakpoint


local gm = gm or {}

-- console
local console = cc.Director:getInstance():getConsole()

function gm:init()
    scheduler:create(functor(self.mainLoop, self), 0.1)
end

function gm:mainLoop(dt)
    local cmd = console:getCommandLine()
    if cmd then
        cmd = string.trim(cmd)
        if #cmd>0 then
            console:setCommandLine("")
            self:parseCmd(cmd)
        end
    end
end

function gm:consoleListenOnTCP(port)
    return console:listenOnTCP(port)
end

function gm:addConsoleCommand(name, help, callBack)
    return console:addCommand({name=name, help=help}, callBack)
end

function gm:parseCmd(cmd)
    local args = string.split(cmd, " ")
    local funcName = table.remove(args, 1)

    local func = gm_cmd[funcName]
    if func then
        xpcall(functor(func, self, unpack(args)), __G__TRACKBACK__)
    else
        xpcall(functor(gm_cmd.execute, self, cmd), __G__TRACKBACK__)
    end
end

return gm