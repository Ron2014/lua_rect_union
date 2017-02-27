--[[
字典
用途：
	1. 在你需要知道元素个数的时候使用，不要用kc_common.GetTableSize接口（遍历的方式）来获取字典元素个数

		a = {}
		b = Dict()
		lim = 1000000
		seed = os.time()

		function GetTableSize(t)
		 	local n = 0
			for _ in pairs (t) do
				n = n + 1
			end
			return n
		end

		math.randomseed(seed)
		tm = os.clock()
		for i=1,lim do
			key = math.random(1, lim)
			val = math.random(1, lim)
			addOrDel = math.random(0,1)

			if addOrDel>0 then
				a[key] = nil
			else
				a[key] = val
			end
		end
		print("1 init", os.clock() - tm)		--1 init  1.326

		tm = os.clock()
		print(GetTableSize(a))					--315623
		print("1 length", os.clock() - tm)		--1 length        0.031

		print()

		math.randomseed(seed)
		tm = os.clock()
		for i=1,lim do
			key = math.random(1, lim)
			val = math.random(1, lim)
			addOrDel = math.random(0,1)

			if addOrDel>0 then
				-- b[key] = nil					--会走__newindex元方法，效率略低，还是不要这样赋值
				b:remove(key)
			else
				-- b[key] = val
				b:append(key, val)
			end
		end
		print("2 init", os.clock() - tm)		--2 init  0.904

		tm = os.clock()
		print(b:length())						--315623
		print("2 length", os.clock() - tm)		--2 length        0

--]]

Dict = class("Dict", Array)
regMetaMethod(Dict, "index",
function(ins, key)
    local cls = rawget(ins, "class")
    local val = cls[key]
    if val then return val end

    local attr = rawget(ins, key)
    if attr then return attr end

    local data = rawget(ins, "data_")
    local elem = data and data[key]
    if elem then return elem end
end)

regMetaMethod(Dict, "newindex",
function(ins, key, val)
    if key=="data_" or key=="length_" then
        rawset(ins, key, val)
        return
    end

    local data = ins.data_
    local old = data[key]
    data[key] = val

    local length = ins.length_
    if val == nil then
        if old ~= nil then
            ins.length_ = length - 1
        end
    else
        if old == nil then
            ins.length_ = length + 1
        end
    end
end)

-- 核心代码在此，不要在用kc_common.GetTableSize来获得字典的元素数量了！！！（因为继承了Array，所以无需再定义）
-- function Dict:length()
--     return self.length_
-- end

-- override
function Dict:_tostring()
    local data = self.data_
    local result = {}
    local count = 0

    for k, v in pairs(data) do
        count = count + 1
        result[count] = string.format("[%s:%s]", k, v)
    end

    return table.concat(result, "; ")
end

function Dict:init(data)
    self.data_ = data or {}
    
    self.length_ = 0
    for k, v in pairs(self.data_) do
        self.length_ = self.length_ + 1
    end
end

function Dict:set(key, value)
    local data = self.data_
    local old = data[key]
    data[key] = value

    local length = self.length_
    if value == nil then
        if old ~= nil then
            self.length_ = length - 1
        end
    else
        if old == nil then
            self.length_ = length + 1
        end
    end
end

function Dict:get(key)
	return self.data_[key]
end

function Dict:exist(key)
    return self:get(key) ~= nil
end

function Dict:append(key, value)
    assert(value~=nil, "value can't be nil for function append")
    self:set(key, value)
end

function Dict:remove(key)
    local length = self.length_
    local node = self.data_[key]

    if node~=nil then
        self.data_[key] = nil
        self.length_ = length - 1
    end
    
    return node
end