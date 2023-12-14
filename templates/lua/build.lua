
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";./?.lua"
package.path = package.path .. ";../../?.lua"
local builder = require("builder")

local builder = builder.lua {}
builder:setInput('./example.lua')
builder:setOutput('example')
builder:start()
builder:run()

