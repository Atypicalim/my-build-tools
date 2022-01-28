
pcall(os.execute, "git clone git@github.com:kompasim/lua-c-builder.git ./.lua-c-builder")
package.path = package.path .. ";./.lua-c-builder/?.lua"
local Builder = require("builder")

local builder = Builder(false)
builder:installLibs("tigr")
builder:containLibs("tigr")
builder:containFile("./test.txt")
builder:containIcon('./icon.ico')
builder:compile("test.c", "test", false)
builder:execute()
