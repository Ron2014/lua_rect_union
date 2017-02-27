
trace = require "trace"

local function factorial(i)
    if i <= 1 then
        return 1
    end
    return factorial(i-1) * i
end

function foo(n)
    trace.trace("n i s", n)
    local s = factorial(100)
    return s
end

function hello()
    print "hello-----------------------------"
end

foo(3)
hello()
foo()