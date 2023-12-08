
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"
local builder = require("builder")

-- handle macro in c for including lua code
local codeBuilder = builder.code {}
codeBuilder:setInput("./test.c")
codeBuilder:setComment("//")
codeBuilder:setOutput("./target.c")
codeBuilder:start()

-- build the target file and generate executable
local cBuilder = builder.c {}
cBuilder:setInput('./target.c')
cBuilder:setLibs("minilua")
cBuilder:setLibs("luaauto")
cBuilder:setOutput('test')
cBuilder:start()
cBuilder:run()
