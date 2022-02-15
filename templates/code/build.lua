
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"
local Builder = require("./code_builder")

-- macro

-- fill line with data
-- when found a [M] after comment tag is regarded as a macro
-- template: [M[ command | argument ]M]

local builder = Builder(false)
builder:inputFiles("./test.c", "./test.html", "./test.js")
builder:printHeader("--", 1)
builder:handleMacro("//", "<!--", "#")
builder:outputFile("./target.any")
builder:start()

