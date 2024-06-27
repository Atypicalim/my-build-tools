"""
tools
"""

import http.client as http
import os
import subprocess
import pathlib
import base64
import json
import platform

######################################################

class py:
    is_boolean = lambda value: isinstance(value, bool)
    is_number = lambda value: isinstance(value, (int, float))
    is_string = lambda value: isinstance(value, str)
    is_text = lambda val: isinstance(val, str) and val.strip()
    is_array = lambda value: isinstance(value, list)
    is_object = lambda value: isinstance(value, dict)
    is_function = lambda val: callable(val)
    print = lambda *args: print(*args)
    trace = lambda *args: (print(' '.join(args)), print(traceback.format_stack()))
    check = lambda val, *args: (_ for _ in ()).throw(AssertionError(' '.join(args))) if not val else None
    error = lambda *args: (_ for _ in ()).throw(Exception(' '.join(args)))
    pass


######################################################

class files:
    delete = lambda path: os.remove(path) if os.path.exists(path) else None
    mk_folder = lambda path: os.makedirs(path, exist_ok=True)
    is_folder = lambda path: os.path.isdir(path)
    is_file = lambda path: os.path.isfile(path)
    is_exist = lambda path: os.path.exists(path)
    write = lambda path, content, encoding='utf-8': open(path, 'w', encoding=encoding).write(content)
    read = lambda path, encoding='utf-8': open(path, 'r', encoding=encoding).read()
    copy = lambda _from, _to: shutil.copyfile(_from, _to)
    size = lambda _path: os.path.getsize(_path) if os.path.exists(_path) else -1


######################################################

async def read_line(msg="input:"):
    return input(msg)

async def read_selection(msg="select:", options=[]):
    print(msg, options)
    while True:
        txt = await read_line()
        if txt in options:
            return txt

class terminal:
    read_line = read_line
    read_selection = read_selection
    pass

######################################################

def tools_execute(cmd, args=[], cwd=None, encoding='gbk'):
    try:
        r = subprocess.check_output(
            cmd,
            shell = True,
            cwd = cwd,
            encoding = encoding,
            stderr = subprocess.STDOUT
        )
        return (True, r)
    except subprocess.CalledProcessError as e:
        return (False, "cmd:<{}> code:({}) msg:{}".format(e.cmd, e.returncode, e.output))
    
def tools_spawn(cmd, args, cwd=None, encoding='gbk'):
    try:
        result = subprocess.Popen(
            [cmd] + args,
            encoding = encoding,
            cwd = cwd
        )
        return (True, result)
    except Exception as e:
        return (False, "cmd:<{}> code:({}) msg:{}".format(e.cmd, e.returncode, e.output))

class tools:
    is_windows = lambda: platform.system() == 'Windows'
    is_mac = lambda: platform.system() == 'Darwin'
    is_linux = lambda: platform.system() == 'Linux'
    execute = tools_execute
    spawn = tools_spawn
    get_separator = lambda: "\\" if tools.is_windows() else "/"
    parse_path = lambda _path: (pathlib.Path(_path).parent, pathlib.Path(_path).stem, pathlib.Path(_path).suffix.lstrip('.'), pathlib.Path(_path).name)
    pass



######################################################

class encryption:
    base64_encode = lambda content: base64.b64encode(content.encode()).decode()
    base64_decode = lambda content: base64.b64decode(content).decode()
    pass


######################################################

def httpy_curl(url, method, params=None, headers=None):
    py['assert'](py['is_text'](url))
    method = method.upper()
    py['assert'](method in ['POST', 'GET'])
    params = params or {}
    headers = headers or {}
    tempFile = './.py.http.log'
    files['delete'](tempFile)
    h = ' '.join([f"-H '{k}:{v}'" for k, v in headers.items()])
    b = ''
    if method == 'GET':
        url += '?' + '&'.join([f"{k}={v}" for k, v in params.items()])
    elif method == 'POST':
        b = f"-d '{json.dumps(params)}'"
    cmd = f'curl "{url}" -i --silent -X {method} -o "{tempFile}" {h} {b}'
    isOk, output = tools['execute'](cmd)
    content = files['read'](tempFile, 'utf8')
    files['delete'](tempFile)
    if not isOk:
        return [-1, output]
    head, body = content.split('\r\n\r\n', 1)
    codeMatch = re.search(r'HTTP.+\s(\d{3})', head)
    code = int(codeMatch.group(1)) if codeMatch else -1
    return [code, body] if code >= 0 else [-1, output]

def httpy_request(url, method, params=None, headers=None):
    [code, content] = httpy_curl(url, method, params, headers)
    return [code == 200, code, content]


def httpy_download(url, _path, withPrint=False):
    if not py['is_text'](url) or not py['is_text'](_path):
        raise ValueError('Invalid URL or file path')
    folder = os.path.dirname(_path)
    os.makedirs(folder, exist_ok=True)
    cmd = f'curl -L "{url}" -o "{_path}" --max-redirs 3'
    try:
        options = {'stdio': None} if withPrint else {'stdio': subprocess.PIPE}
        output = subprocess.check_output(cmd, shell=True, **options)
        return [True, output.decode()]
    except subprocess.CalledProcessError as error:
        return [False, str(error)]

class httpy:
    request = httpy_request
    get = lambda url, params=None, headers=None: httpy_request(url, 'GET', params, headers)
    post = lambda url, params=None, headers=None: httpy_request(url, 'POST', params, headers)
    download = httpy_download
    pass

######################################################

tools_module = {'py': py, 'files': files, 'terminal': terminal, 'tools': tools, 'encryption': encryption, 'httpy': httpy}


