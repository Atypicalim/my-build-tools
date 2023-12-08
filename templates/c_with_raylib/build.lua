
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"
local builder = require("builder")

local builder = builder.c {}
builder:setInput('./test.c')
builder:setLibs("raylib")
builder:setOutput('test')
builder:start()
builder:run()
