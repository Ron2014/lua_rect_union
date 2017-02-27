--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

function printLog(tag, fmt, ...)
    local t = {
        "[",
        string.upper(tostring(tag)),
        "] ",
        string.format(tostring(fmt), ...)
    }
    print(table.concat(t))
end

function printError(fmt, ...)
    printLog("ERR", fmt, ...)
    print(debug.traceback("", 2))
end

function printInfo(fmt, ...)
    if type(DEBUG) ~= "number" or DEBUG < 2 then return end
    printLog("INFO", fmt, ...)
end

local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

function dump(value, desciption, nesting)
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    -- local traceback = string.split(debug.traceback("", 2), "\n")
    -- print("dump from: " .. string.trim(traceback[3]))

    local max_nest = 64

    local function dump_(value, desciption, indent, nest, keylen)
        if nest > max_nest then
            return "..."
        end

        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
        end
        -- print("=====", value, type(value), tostring(value))
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, desciption, "- ", 1)

    for i, line in ipairs(result) do
        print(line)
    end
end

function printf(fmt, ...)
    print(string.format(tostring(fmt), ...))
end

function checknumber(value, base)
    return tonumber(value, base) or 0
end

function checkint(value)
    return math.round(checknumber(value))
end

function checkbool(value)
    return (value ~= nil and value ~= false)
end

function checktable(value)
    if type(value) ~= "table" then value = {} end
    return value
end

function isset(hashtable, key)
    local t = type(hashtable)
    return (t == "table" or t == "userdata") and hashtable[key] ~= nil
end

local setmetatableindex_
setmetatableindex_ = function(t, index)
    -- if type(t) == "userdata" then        -- 让userdata继承table，这他妈就是一个坑啊
    --     local peer = tolua.getpeer(t)
    --     if not peer then
    --         peer = {}
    --         tolua.setpeer(t, peer)
    --     end
    --     setmetatableindex_(peer, index)
    -- else
    --     local mt = getmetatable(t)
    --     if not mt then mt = {} end
    --     if not mt.__index then
    --         mt.__index = index
    --         setmetatable(t, mt)
    --     elseif mt.__index ~= index then
    --         print("wtf")
    --         setmetatableindex_(mt, index)
    --     end
    -- end

    local mt = getmetatable(t)
    setmetatable(t, index)
end
setmetatableindex = setmetatableindex_

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local newObject = {}
        lookup_table[object] = newObject
        for key, value in pairs(object) do
            newObject[_copy(key)] = _copy(value)
        end
        return setmetatable(newObject, getmetatable(object))
    end
    return _copy(object)
end

function _tostring_class(cls)
    return string.format("Class:%s", cls._NAME or cls.__cname)
end

function _index_in_supers(cls, key)
    local supers = rawget(cls, "__supers")
    if not supers then return end
    for _, super in ipairs(supers) do
        if super[key] then return super[key] end
    end
end

function _index_in_instance(obj, key)
    local cls = rawget(obj, "class")

    local val = cls[key]
    if val~=nil then return val end

    local core = rawget(obj, "__core")  -- 如果有userdata
    if not core then return end

    val = core[key]

    if type(val) ~= "function" then
        return val
    end

    if iscfunction(val) then
        return function(_, ...)         --返回一个匿名函数对象
            return val(core, ...)
        end
    end
    return val
end

function _tostring_instance(obj)
    return string.format("InstanceOf:%s", obj._NAME or obj.__cname)
end

function _core(obj)
    return rawget(obj, "__core")
end

function _ctor(obj, ...)
end

function _isValid(obj, ...)
    local core = _core(obj)
    if core then
        return not tolua.isnull(core)
    end
    return not obj.__invalid
end

local _mt4class = {
    __tostring = _tostring_class,
    __index = _index_in_supers,
}

gClassDict = gClassDict or {}

function class(classname, ...)
    local cls = gClassDict[classname] or {__cname=classname}
    gClassDict[classname] = cls
    
    local supers = {...}
    for _, super in ipairs(supers) do
        local superType = type(super)
        assert(superType == "nil" or superType == "table" or superType == "function",
            string.format("class() - create class \"%s\" with invalid super class type \"%s\"",
                classname, superType))

        if superType == "function" then
            -- assert(cls.__create == nil,
            --     string.format("class() - create class \"%s\" with more than one creating function",
            --         classname));
            -- if super is function, set it to __create
            cls.__create = cls.__create or super
        elseif superType == "table" then
            if super[".isclass"] then       -- C++类
                -- super is native class
                -- assert(cls.__create == nil,
                --     string.format("class() - create class \"%s\" with more than one creating function or native class",
                --         classname));
                cls.__create = cls.__create or function() return super:create() end
            else
                -- super is pure lua class
                cls.__supers = cls.__supers or {}
                cls.__supers[#cls.__supers + 1] = super
                if not cls.super then
                    -- set first super pure lua class as class.super
                    cls.super = super
                end
            end
        else
            error(string.format("class() - create class \"%s\" with invalid super type",
                        classname), 0)
        end
    end
    --[[
        子类-父类 可以只用{__index=xxx}来设置，
        但是 实例-类 可以扩展：
        原来的方式只关心__index, 但是元表其实是个元方法集（包括__newindex、__tostring等等）
        而且__index不只是表索引机制，还可以是函数
        所以这里增加可以自定义的方式__mt4child，在class(xxx)调用之后，对其再赋值即可
    ]] 

    -- cls.__index = cls
    local _mt4child = {__index=_index_in_instance, __tostring=_tostring_instance}

    if #supers==1 and cls.super then
        for k, v in pairs(cls.super.__mt4child) do
            _mt4child[k] = v
        end
    end

    cls.__mt4child = cls.__mt4child or _mt4child
    setmetatable(cls, _mt4class)

    -- if not cls.__supers or #cls.__supers == 1 then
    --     setmetatable(cls, {__index = cls.super})
    -- else
    --     setmetatable(cls, {__index = function(_, key)
    --         local supers = cls.__supers
    --         for i = 1, #supers do
    --             local super = supers[i]
    --             if super[key] then return super[key] end
    --         end
    --     end})
    -- end


    -- add default constructor
    cls.ctor = cls.ctor or _ctor

    -- add default core
    cls.core = cls.core or _core

    -- add default isValid
    cls.isValid = cls.isValid or _isValid

    -- 不要直接调用new函数，统一用create
    cls._new = function(cls, ...)
        local instance = {}

        -- 继承关系 MainScene->viewBase->cc.Node 实例化时要创建一个Node实例，不能用rawget
        -- local _create = rawget(cls, "__create")
        local _create = cls.__create
        if _create then
            instance.__core = _create(...)
        end

        instance.class = cls

        -- setmetatableindex(instance, cls)
        local _mt4child = rawget(cls, "__mt4child")
        setmetatableindex(instance, _mt4child)
        
        instance:ctor(...)

        return instance
    end

    cls.onDestroy = function(obj)
        obj.__invalid = true
    end

    cls.create = function(cls, ...)
        return cls:_new(...)
    end

    return cls
end

function singletonClass(classname, ...)
    local cls = class(classname, ...)

    cls.create = function(cls, ...)
        local instance = rawget(cls, "__instance")
        if instance then
            return instance
        end

        instance = cls:_new(...)

        rawset(cls, "__instance", instance)
        return instance
    end

    cls.onDestroy = function(obj)
        local cls = obj.class
        rawset(cls, "__instance", nil)
        obj.__invalid = true
    end

    cls.getInstance = function(cls)
        return rawget(cls, "__instance")
    end

    local mt = clone(getmetatable(cls))
    mt.__call = function(cls)
        return cls:getInstance()
    end
    setmetatable( cls, mt )

    return cls
end

function sortpairs(t, inc)
    local inc = inc
    if inc==nil then inc=true end

    local arrayt = {}
    local i=1
    for k,v in pairs(t) do
        arrayt[i]={k,v}
        i=i+1
    end
    table.sort( arrayt, function( a, b )
        local w1, w2 = 0, 0
        local rate = (inc and 1) or -1
        if a[1]<b[1] then
            w1 = w1 + rate
        end
        if a[1]>b[1] then
            w2 = w2 + rate
        end
        return w1 > w2
    end )

    i=0
    return function()
        i=i+1
        local e=arrayt[i]
        if e then
            return e[1],e[2]
        else
            return nil,nil
        end
    end
end

function regMetaMethod(cls, name, method)
    local _mt4child = rawget(cls, "__mt4child")
    if not _mt4child then return end

    if string.sub(name, 1, 2) ~= "__" then
        name = string.format("__%s", name)
    end

    _mt4child[name] = method
end

function iskindof_(cls, name)
    if gClassDict[name] == cls then return true end

    if rawget(cls, "__cname") == name then return true end

    local __supers = rawget(cls, "__supers")
    if not __supers then return false end
    for _, super in ipairs(__supers) do
        if iskindof_(super, name) then return true end
    end
    return false
end

function iskindof(obj, classname)
    local t = type(obj)
    if t ~= "table" and t ~= "userdata" then return false end

    local mt
    if t == "userdata" then
        if tolua.iskindof(obj, classname) then return true end
        mt = tolua.getpeer(obj)
    else
        if rawget(obj, "__mt4child") then
            -- is class
            mt = obj
        else
            -- is instance
            mt = obj.class
        end
    end
    if mt then
        return iskindof_(mt, classname)
    end
    return false
end

function import(moduleName, currentModuleName)
    local currentModuleNameParts
    local moduleFullName = moduleName
    local offset = 1

    while true do
        if string.byte(moduleName, offset) ~= 46 then -- .
            moduleFullName = string.sub(moduleName, offset)
            if currentModuleNameParts and #currentModuleNameParts > 0 then
                moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
            end
            break
        end
        offset = offset + 1

        if not currentModuleNameParts then
            if not currentModuleName then
                local n,v = debug.getlocal(3, 1)
                currentModuleName = v
            end

            currentModuleNameParts = string.split(currentModuleName, ".")
        end
        table.remove(currentModuleNameParts, #currentModuleNameParts)
    end

    return require(moduleFullName)
end

function functor(method, ...)
    local args = {...}
    return function()
        return method(unpack(args))
    end
end

function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

function math.newrandomseed()
    local ok, socket = pcall(function()
        return require("socket")
    end)

    if ok then
        math.randomseed(socket.gettime() * 1000)
    else
        math.randomseed(os.time())
    end
    math.random()
    math.random()
    math.random()
    math.random()
end

function math.round(value)
    value = checknumber(value)
    return math.floor(value + 0.5)
end

local pi_div_180 = math.pi / 180
function math.angle2radian(angle)
    return angle * pi_div_180
end

local pi_mul_180 = math.pi * 180
function math.radian2angle(radian)
    return radian / pi_mul_180
end

function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

function io.readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

function io.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

function io.pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

function io.filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end

function table.nums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.keys(hashtable)
    local keys = {}
    for k, v in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end

function table.values(hashtable)
    local values = {}
    for k, v in pairs(hashtable) do
        values[#values + 1] = v
    end
    return values
end

function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

function table.insertto(dest, src, begin)
    begin = checkint(begin)
    if begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

function table.indexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then return i end
    end
    return false
end

function table.keyof(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then return k end
    end
    return nil
end

function table.removebyvalue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then break end
        end
        i = i + 1
    end
    return c
end

function table.map(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(v, k)
    end
end

function table.walk(t, fn)
    for k,v in pairs(t) do
        fn(v, k)
    end
end

function table.filter(t, fn)
    for k, v in pairs(t) do
        if not fn(v, k) then t[k] = nil end
    end
end

function table.unique(t, bArray)
    local check = {}
    local n = {}
    local idx = 1
    for k, v in pairs(t) do
        if not check[v] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[v] = true
        end
    end
    return n
end

string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end

function string.restorehtmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, v, k)
    end
    return input
end

function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function string.ltrim(input)
    return string.gsub(input, "^[ \t\n\r]+", "")
end

function string.rtrim(input)
    return string.gsub(input, "[ \t\n\r]+$", "")
end

function string.trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

function string.ucfirst(input)
    return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

local function urlencodechar(char)
    return "%" .. string.format("%02X", string.byte(char))
end
function string.urlencode(input)
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end

function string.urldecode(input)
    input = string.gsub (input, "+", " ")
    input = string.gsub (input, "%%(%x%x)", function(h) return string.char(checknumber(h,16)) end)
    input = string.gsub (input, "\r\n", "\n")
    return input
end

function string.utf8len(input)
    local len  = string.len(input)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function string.formatnumberthousands(num)
    local formatted = tostring(checknumber(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end
