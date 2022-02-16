
pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
package.path = package.path .. ";./.my-build-tools/?.lua"
local Builder = require("c_builder")

local builder = Builder(false)
builder:installLibs("tigr")
builder:containLibs("tigr")
builder:containIcon('./icon.ico')
builder:compile("test.c", "test", false)
builder:execute()
