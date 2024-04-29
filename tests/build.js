


const builder = require("../builder");

const bldr = builder.c({});
bldr.setDebug(false);
bldr.setInput('./test.c');
bldr.setLibs([
    "incbin",
    "thread",
    "md5",
    "base64",
    "microtar",
    "minicoro",
    "minilua", "luaauto",
    "tigr",
    "raylib",
    "webview",
    "stb",
    "bmp",
    "naett",
    "sandbird",
]);
bldr.setOutput('test');
bldr.start();
bldr.run();
