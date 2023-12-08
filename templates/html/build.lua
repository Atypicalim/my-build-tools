
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"
local builder = require("builder")

local builder = builder.html {}
builder:setInput("./test.html")
builder:containScript()
builder:containStyle()
builder:containImage()
builder:setOutput("./target.html")
builder:start()
