"""
builder
"""

from src.builder_base import MyBuilderBase
from src.c_builder import MyCBuilder
from src.lua_builder import MyLuaBuilder
from src.html_builder import MyHtmlBuilder
from src.code_builder import MyCodeBuilder

from constants import Globals, KEYS, TYPES
from src.tools import py, files, terminal, tools

builder = {}
UI_LENGTH = 48
builders = ["c", "lua", "html", "code"]
tasks = []

MY_BUILDER_TEMPLATE = """
  const builder = require("builder");
  const task = builder.%s({
      name: "%s",
      debug: False,
      release: False,
      input: "./source.%s",
      output: "./target"
  }).start();
"""

def split_by_upper(word):
    import re
    res = []
    regex = re.compile(r'([A-Z][a-z]*)')
    match = regex.findall(word)
    if match:
        res.extend(match)
    return res

def string_padd_center(text, length, char):
    return text.center(length, char)

async def builder_init():
    print("-" + "-" * UI_LENGTH + "-")
    print("|" + string_padd_center("My Builder", UI_LENGTH, " ") + "|")
    print("-" + "-" * UI_LENGTH + "-")
    print("| build.lua not found, creating ...")
    print("| please enter task name:")
    task_name = await terminal.read_line()
    print("| please select task type:")
    task_type = await terminal.read_selection(builders)
    my_builder_text = MY_BUILDER_TEMPLATE % (task_type, task_name, task_type, task_type)
    files.write('./build.lua', my_builder_text)
    print("| created!")

def builder_help(obj):
    print("-" + "-" * UI_LENGTH + "-")
    print("|" + f"{obj.__name__} Help".center(UI_LENGTH, " ") + "|")
    print("-" + "-" * UI_LENGTH + "-")
    conf_keys = {}
    obj_funcs = {}
    arr = [obj.__class__, obj.__class__.__base__]
    for cls in arr:
        for key in dir(cls):
            val = getattr(cls, key)
            if callable(val) and key.startswith("set"):
                words = split_by_upper(key)
                name = "_".join(words).lower()
                conf_keys[name] = True
            if callable(val) and not key.startswith("_"):
                obj_funcs[key] = True
    print('| keys:')
    for key in conf_keys:
        print("| * " + key)
    print('| funs:')
    for key in obj_funcs:
        print("| * " + key)
    print("-" + "-" * UI_LENGTH + "-")

def create_func(obj, args=None):
    args = args or {}
    for k, v in args.items():
        py.assert_(py.is_text(k), 'Invalid argument key for builder: ' + str(k))
        wrds = k.lower().split("_")
        name = "".join(word.capitalize() for word in wrds)
        func = getattr(obj, 'set' + name, None)
        py.assert_(callable(func), 'Unknown argument key for builder: ' + str(k))
        func(v)
    obj.help = builder_help
    tasks.append(obj)
    return obj

Globals.createFunc = create_func


C = MyCBuilder
Lua = MyLuaBuilder
Html = MyHtmlBuilder
Code = MyCodeBuilder

c = lambda *args: MyCBuilder(*args)
lua = lambda *args: MyLuaBuilder(*args)
html = lambda *args: MyHtmlBuilder(*args)
code = lambda *args: MyCodeBuilder(*args)

def builder_help_func():
    print("-" + "-" * UI_LENGTH + "-")
    print("|" + "builder help".center(UI_LENGTH, " ") + "|")
    print("-" + "-" * UI_LENGTH + "-")
    print('| builders:')
    for v in builders:
        print('|', "*", v)
    print('| functions:')
    for k in builder:
        if k not in builders:
            print('|', "*", k)
    print("-" + "-" * UI_LENGTH + "-")

builder['help'] = builder_help_func

def builder_tasks():
    print("-" + "-" * UI_LENGTH + "-")
    print("|" + "builder list".center(UI_LENGTH, " ") + "|")
    print("-" + "-" * UI_LENGTH + "-")
    print('| tasks:')
    for i, obj in enumerate(tasks):
        print('|', f"{i + 1}.", obj.get_name())
    print("-" + "-" * UI_LENGTH + "-")

builder['tasks'] = builder_tasks

def builder_find(name):
    if not py.is_text(name):
        raise ValueError('Invalid task name for builder')
    for obj in tasks:
        if obj.get_name() == name:
            return obj

builder['find'] = builder_find

builder['tools'] = tools

if __name__ == "__main__":
    import asyncio
    asyncio.run(builder_init())
else:
    pass

