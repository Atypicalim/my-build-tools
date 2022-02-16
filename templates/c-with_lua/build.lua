
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"
local CBuilder = require("c_builder")
local CodeBuilder = require("code_builder")

-- handle macro in c for including lua code
local codeBuilder = CodeBuilder(false)
codeBuilder:inputFiles("./test.c")
codeBuilder:handleMacro("//")
codeBuilder:outputFile("./target.c")
codeBuilder:start()

-- build the target file and generate executable
local cBuilder = CBuilder(false)
cBuilder:installLibs("minilua")
cBuilder:containLibs("minilua")
cBuilder:compile("./target.c", "test", false)
cBuilder:execute()
