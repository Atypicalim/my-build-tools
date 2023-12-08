
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"

local builder = require("builder")

local codeBuilder = builder.code {}
codeBuilder:setInput("./test.c")
codeBuilder:setComment("//")
codeBuilder:setOutput("./target.c")
codeBuilder:start()

local cBuilder = builder.c {}
cBuilder:setInput('./target.c')
cBuilder:setLibs("webview")
cBuilder:setOutput('test')
cBuilder:start()
cBuilder:run()
