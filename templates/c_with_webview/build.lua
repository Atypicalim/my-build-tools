
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"
local CBuilder = require("c_builder")
local CodeBuilder = require("code_builder")

local codeBuilder = CodeBuilder(false)
codeBuilder:setInput("./test.c")
codeBuilder:handleMacro("//")
codeBuilder:setOutput("./target.c")
codeBuilder:start()

local cBuilder = CBuilder(false)
cBuilder:setInput('./target.c')
cBuilder:setLibs("webview")
cBuilder:setOutput('test')
cBuilder:start(true)

os.execute("start ./test.exe")
