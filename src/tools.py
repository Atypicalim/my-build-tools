"""
tools
"""

import http
import os
import subprocess
import pathlib
import base64
import json
import platform
import urllib
import urllib.request
import traceback
import shutil

######################################################

class Globals:
    pass

Globals.createFunc = None
Globals.originsPath = os.path.join(os.path.dirname(__file__), "../resources/origins.yaml")

class KEYS:
    NAME = "NAME"
    TYPE = "TYPE"
    URL = "URL"
    EXT = "EXT"
    BRANCH = "BRANCH"
    DIR_I = "DIR_I"  # -I
    DIR_L = "DIR_L"  # -L
    LIB_L = "LIB_L"  # -l
    FLAGS = "FLAGS"  # flags
    FILES = "FILES"  # include source files in lib
    WIN = "WIN"
    LNX = "LNX"
    MAC = "MAC"
    pass

class TYPES:
    GIT = "GIT"
    ZIP = "ZIP"
    GZ = "GZ"
    pass

######################################################

def py_implode(args, separator=" "):
    return separator.join(map(str, args))

def py_explode(text, separator=" "):
    return text.split(separator, -1)

class py:
    is_boolean = lambda value: isinstance(value, bool)
    is_number = lambda value: isinstance(value, (int, float))
    is_string = lambda value: isinstance(value, str)
    is_text = lambda val: isinstance(val, str) and val.strip()
    is_array = lambda value: isinstance(value, list)
    is_object = lambda value: isinstance(value, dict)
    is_function = lambda val: callable(val)
    implode = lambda separator, *args: py_implode(args, separator)
    explode = lambda separator, text: py_explode(text, separator)
    print = lambda *args: print(*args)
    trace = lambda *args: (print(py_implode(args)), traceback.print_stack())
    check = lambda val, *args: (_ for _ in ()).throw(AssertionError(py_implode(args))) if not val else None
    error = lambda *args: (_ for _ in ()).throw(Exception(py_implode(args)))
    pass

######################################################

def files_write(path, content, encoding=None):
    return open(path, 'w' if encoding != None else "wb", encoding=encoding).write(content)


def files_read(path, encoding=None):
    return open(path, 'r' if encoding != None else "rb", encoding=encoding).read()

class files:
    delete = lambda path: os.remove(path) if os.path.exists(path) else None
    mk_folder = lambda path: os.makedirs(path, exist_ok=True)
    is_folder = lambda path: os.path.isdir(path)
    is_file = lambda path: os.path.isfile(path)
    is_exist = lambda path: os.path.exists(path)
    write = files_write 
    read = files_read
    copy = lambda _from, _to: shutil.copyfile(_from, _to)
    size = lambda _path: os.path.getsize(_path) if os.path.exists(_path) else -1

######################################################

async def read_line(msg="input:"):
    return input(msg)

async def read_selection(options, msg="select:"):
    print(msg, options)
    while True:
        txt = await read_line()
        if txt in options:
            return txt
        else:
            print("invalid!")

class terminal:
    read_line = read_line
    read_selection = read_selection
    pass

######################################################

def tools_execute(cmd, args=[], cwd=None, encoding='gbk'):
    try:
        p = subprocess.check_output(
            cmd,
            shell = True,
            cwd = cwd,
            encoding = encoding,
            stderr = subprocess.STDOUT
        )
        return [True, p]
    except subprocess.CalledProcessError as e:
        return [False, "cmd:<{}> code:({}) msg:{}".format(e.cmd, e.returncode, e.output)]
    except Exception as e:
        return [False, e]
    
def tools_spawn(cmd, args=[], cwd=None, encoding='gbk'):
    try:
        p = subprocess.Popen(
            [cmd] + args,
            encoding = encoding,
            cwd = cwd
        )
        p.wait()
        return [True, p.returncode]
    except subprocess.CalledProcessError as e:
        return [False, "cmd:<{}> code:{} msg:{}".format(e.cmd, e.returncode, e.output)]
    except Exception as e:
        return [False, e]
        

def tools_parse_path(_path):
    _path = pathlib.Path(_path)
    return (_path.parent, _path.stem, _path.suffix.lstrip('.'), _path.name)

class tools:
    is_windows = lambda: platform.system() == 'Windows'
    is_mac = lambda: platform.system() == 'Darwin'
    is_linux = lambda: platform.system() == 'Linux'
    execute = tools_execute
    spawn = tools_spawn
    get_separator = lambda: "/" if tools.is_windows() else "\\"
    parse_path = tools_parse_path
    validate_path = lambda path: path.replace("/", tools.get_separator()).replace("\\", tools.get_separator())
    pass

######################################################

class encryption:
    base64_encode = lambda content: base64.b64encode(content.encode()).decode()
    base64_decode = lambda content: base64.b64decode(content).decode()
    pass

######################################################

def httpy_request(url, isPost, params={}, headers={}):
    _method = "POST" if isPost else "GET"
    _params = urllib.parse.urlencode(params)
    _url = url if isPost else f"{url}?{_params}"
    _data = _params.encode() if isPost else None
    _request = urllib.request.Request(_url, data=_data, method=_method)
    try:
        _response = urllib.request.urlopen(_request)
        code = _response.status
        isOk = code >= 200 and code < 300
        data = _response.read()
        return [isOk, code, data]
    except urllib.error.HTTPError as e:
        return [False, e.code, "url:<{}> msg:{}".format(e.filename, e.msg)]
    except Exception as e:
        return [False, -1, e]

def httpy_download(url, _path):
    try:
        _response = urllib.request.urlopen(url)
        _code = _response.getcode()
        if _code != 200:
            return [False, _code, _response.msg]
        file_contents = _response.read()
        file = open(_path, "wb")
        file.write(file_contents)
        return [True, _code, _response.msg]
    except urllib.error.URLError as e:
        return [False, e.code, "url:<{}> msg:{}".format(e.filename, e.msg)]
    except PermissionError as e:
        return [False, e.errno, "url:<{}> msg:{}".format(e.filename, e.strerror)]
    except Exception as e:
        return [False, -1, e]

class httpy:
    get = lambda url, params={}, headers={}: httpy_request(url, False, params, headers)
    post = lambda url, params={}, headers={}: httpy_request(url, True, params, headers)
    download = httpy_download
    pass

######################################################
