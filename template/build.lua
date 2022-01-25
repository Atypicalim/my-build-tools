
package.path = package.path .. ";../?.lua"
local Builder = require('../builder')

local builder = Builder(false)
builder:installLibs("tigr")
builder:containLibs("tigr")
builder:processGcc("test.c", true)
builder:programRun()
