## My Build Tools

### 0. Description

> this is a personal package management and building tool for c, we can merge codes and build single executable programs with it, there are some template projects in `./template/` directory showing how to use it.

### 1. Installing

> just clone this repository to your workspace.

### 2. Usage

```js
let builder = require("my-build-tools")
let task = builder.c({
    input = "./test.c",
    output = "test",
}).setLibs([]):setIcon('./test.ico'):start():run()
```

### 3. Builders

* c
* lua
* code
* html

### 4. Libs

* lua
* raylib
* webview
* base64
* dyad
* thread
* ...

### 3. More

> for more information please visit [github](https://github.com/kompasim/my-build-tools).
