
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"
local Builder = require("c_builder")

files.watch('test.c', function(path, newTime)
    print(path, os.date("modified at: %Y-%m-%d %H:%M:%S", newTime))
    local builder = Builder(false)
    builder:setInput('./test.c')
    builder:setOutput('test')
    builder:setIcon('./icon.ico')
    builder:start(false)
    builder:run()
end)
