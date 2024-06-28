
import sys
sys.path.append('../')

from builder import builder, C

builder.help()

bldr = C()
bldr.setDebug(False)
bldr.setInput('./test.c')
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
])
bldr.setOutput('test')
bldr.start()
bldr.run()
