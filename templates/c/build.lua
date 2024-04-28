
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"
local builder = require("builder")

local bldr = builder.c {}
bldr:setInput('./client.c')
bldr:setLibs("dyad")
bldr:setOutput('client')
bldr:start()

local bldr = builder.c {}
bldr:setInput('./server.c')
bldr:setLibs("dyad")
bldr:setOutput('server')
bldr:start()

os.execute("Start " .. files.csd() .. "./server.exe")
os.execute("Start " .. files.csd() .. "./client.exe")
