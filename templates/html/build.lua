
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"
local Builder = require("./html_builder")

local builder = Builder(false)
builder:inputFile("./test.html")
builder:containScript()
builder:containStyle()
builder:containImage()
builder:setOutput("./target.html")
builder:start()
