
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";./?.lua"
package.path = package.path .. ";../../?.lua"
local builder = require("builder")

local task = builder.love {
    name = "loveTest",
    debug = true,
    release = false,
    input = "./",
    output = "./target",
} :start()
