
-- pcall(os.execute, "git clone git@github.com:kompasim/my-build-tools.git ./.my-build-tools")
-- package.path = package.path .. ";./.my-build-tools/?.lua"
package.path = package.path .. ";../../?.lua"
local Builder = require("./code_builder")

-- macro

-- replace all line with template and data
-- double comment is ignored by builder
-- when found a [M] after comment tag is regarded as a macro
-- template: [M[ command | input_file | output_template ]M]

local builder = Builder(false)
builder:inputFiles("./test.c", "./test.html", "./test.js", "./test.py")
builder:printHeader("--", 3)
builder:handleMacro("//", "<!--", "#")
builder:outputFile("./target.any")
builder:start()
