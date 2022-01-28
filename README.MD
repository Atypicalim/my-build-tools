### Lua C Builder

> this is a personal c library management and build tool, just clone this repo and use like the example below. u can find some available libs in `./configs.lua`, and there is a template project in `./template/` directory.

```lua

local Builder = require('builder')
local builder = Builder(false)
builder:installLibs("tigr")
builder:containLibs("tigr")
builder:compile("test.c", false)
builder:execute()

```

---
