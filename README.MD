### My Build Tools

> this is a personal package management repository for c, we can merge codes and build single executable programs with it, there are some template projects in `./template/` directory showing how to use it.

1. usage:

```lua
local builder = require("builder").c {
    input = "./test.c",
    output = "test",
    libs = {},
} :start():run()
```

2. libs: 

* lua
* raylib
* webview
* base64
* dyad
* thread
* ...
