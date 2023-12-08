
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"
local builder = require("builder")

-- macro

-- handle macro
-- when found a [M] after comment tag is regarded as a macro
-- template: [M[ command | argument ]M]

local builder = builder.code {}
builder:setInput("./test.code", "./other.code")
builder:setComment("//")
builder:setOutput("./target.code")
-- a line with unhandled macro
builder:onMacro(function(code, command, argument)
    if command == "ALPHABETS" then
        return "// ALPHABETS ..."
    end
end)
-- a line without any macro
builder:onLine(function(line)
    return line
end)
builder:start()

