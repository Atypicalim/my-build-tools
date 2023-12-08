
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"
local builder = require("builder")

files.watch(files.csd() .. 'test.c', function(path, newTime)
    print(path, os.date("modified at: %Y-%m-%d %H:%M:%S", newTime))
    local builder = builder.c {}
    builder:setInput('./test.c')
    builder:setOutput('test')
    builder:setIcon('./icon.ico')
    builder:start()
    builder:run()
end)
