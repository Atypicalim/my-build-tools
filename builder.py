"""
builder
"""

import os
import sys

currentPath = os.path.dirname(__file__)
sourcePath = os.path.join(currentPath, "src")
sys.path.append(sourcePath)

################################################################

import tools as _tools
from tools import *

from c_builder import MyCBuilder
from lua_builder import MyLuaBuilder
from html_builder import MyHtmlBuilder
from code_builder import MyCodeBuilder

################################################################

C = MyCBuilder
Lua = MyLuaBuilder
Html = MyHtmlBuilder
Code = MyCodeBuilder

class builder:
    c = MyCBuilder
    lua = MyLuaBuilder
    html = MyHtmlBuilder
    code = MyCodeBuilder
    tools = _tools
    pass

################################################################

UI_LENGTH = 48
builders = ["c", "lua", "html", "code"]
tasks = []

MY_BUILDER_TEMPLATE = """
import builder
task = builder.{0}({{
    'name': "{1}",
    'debug': False,
    'input':"./test.{2}",
    'output':"test",
}})
task.setLibs([])
task.setIcon('../../resources/test.ico')
task.start()
task.run()
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
    print("| build.py not found, creating ...")
    print("| please enter task name:")
    task_name = await terminal.read_line()
    print("| please select task type:")
    task_type = await terminal.read_selection(builders)
    my_builder_text = MY_BUILDER_TEMPLATE.format(task_type.upper(), task_name, task_type)
    files.write('./build.py', my_builder_text, 'utf-8')
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

def create_func(obj, args={}):
    for k, v in args.items():
        py.check(py.is_text(k), 'Invalid argument key for builder: ' + str(k))
        wrds = k.lower().split("_")
        name = "".join(word.capitalize() for word in wrds)
        func = getattr(obj, 'set' + name, None)
        py.check(callable(func), 'Unknown argument key for builder: ' + str(k))
        func(v)
    obj.help = builder_help
    tasks.append(obj)
    return obj

Globals.createFunc = create_func

def _builder_help():
    print("-" + "-" * UI_LENGTH + "-")
    print("|" + "builder help".center(UI_LENGTH, " ") + "|")
    print("-" + "-" * UI_LENGTH + "-")
    methods = [attr for attr in dir(builder) if callable(getattr(builder, attr)) and not attr.startswith("_")]
    print('| builders:')
    for k in methods:
        if k in builders:
            print('|', "*", k)
    print('| functions:')
    for k in methods:
        if k not in builders:
            print('|', "*", k)
    print("-" + "-" * UI_LENGTH + "-")

def _builder_tasks():
    print("-" + "-" * UI_LENGTH + "-")
    print("|" + "builder list".center(UI_LENGTH, " ") + "|")
    print("-" + "-" * UI_LENGTH + "-")
    print('| tasks:')
    for i, obj in enumerate(tasks):
        print('|', f"{i + 1}.", obj.getName())
    print("-" + "-" * UI_LENGTH + "-")


def _builder_find(name):
    if not py.is_text(name):
        raise ValueError('Invalid task name for builder')
    for obj in tasks:
        if obj.getName() == name:
            return obj

################################################################

builder.help = _builder_help
builder.tasks = _builder_tasks
builder.find = _builder_find

################################################################

if __name__ == "__main__":
    import asyncio
    asyncio.run(builder_init())
else:
    pass

