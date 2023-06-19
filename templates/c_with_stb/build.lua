
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"
local Builder = require("c_builder")

local builder = Builder(false)
builder:setInput('./test.c')
builder:setLibs("stb")
builder:setOutput('test')
builder:start(false)

os.execute("start " .. files.csd() .. "./test.exe test.jpg test.png")
