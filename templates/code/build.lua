
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"
local Builder = require("./code_builder")

-- macro

-- handle macro
-- when found a [M] after comment tag is regarded as a macro
-- template: [M[ command | argument ]M]

local builder = Builder(false)
builder:setInput("./test.code", "./other.code")
builder:setComment("//")
builder:addHeader()
builder:handleMacro()
builder:setOutput("./target.code")
builder:setCallback(function(code, firsArg)
    if firsArg == "ALPHABETS" then
        return "// ALPHABETS ..."
    end
end)
builder:start()

