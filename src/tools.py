"""
tools
"""

import http.client as http
import os
import subprocess
import pathlib
import readline
import base64
import json

######################################################

# First, checks if it isn't implemented yet.
if not hasattr(str, 'format'):
    def format(self, *args):
        return self.replace(/{(\d+)}/g, lambda match, number: args[int(number)] if int(number) < len(args) else match)
    str.format = format

######################################################

js = {}

js['is_boolean'] = lambda value: isinstance(value, bool)
js['is_number'] = lambda value: isinstance(value, (int, float))
js['is_string'] = lambda value: isinstance(value, str)
js['is_text'] = lambda val: isinstance(val, str) and val.strip()
js['is_array'] = lambda value: isinstance(value, list)
js['is_object'] = lambda value: isinstance(value, dict)
js['is_function'] = lambda val: callable(val)
js['print'] = lambda *args: print(*args)
js['trace'] = lambda *args: (print(' '.join(args)), print(traceback.format_stack()))
js['assert'] = lambda val, *args: (_ for _ in ()).throw(AssertionError(' '.join(args))) if not val else None
js['error'] = lambda *args: (_ for _ in ()).throw(Exception(' '.join(args)))

######################################################

files = {}

files['delete'] = lambda path: os.remove(path) if os.path.exists(path) else None
files['mk_folder'] = lambda path: os.makedirs(path, exist_ok=True)
files['is_folder'] = lambda path: os.path.isdir(path)
files['is_file'] = lambda path: os.path.isfile(path)
files['is_exist'] = lambda path: os.path.exists(path)
files['write'] = lambda path, content, encoding='utf-8': open(path, 'w', encoding=encoding).write(content)
files['read'] = lambda path, encoding='utf-8': open(path, 'r', encoding=encoding).read()
files['copy'] = lambda _from, _to: shutil.copyfile(_from, _to)
files['size'] = lambda _path: os.path.getsize(_path) if os.path.exists(_path) else -1

######################################################

terminal = {}

async def read_line(msg="input:"):
    return input(msg)

terminal['read_line'] = read_line

async def read_selection(msg="select:", options=[]):
    print(msg, options)
    while True:
        txt = await read_line()
        if txt in options:
            return txt

terminal['read_selection'] = read_selection

######################################################

tools = {}

tools['is_windows'] = lambda: os.name == 'nt'
tools['is_mac'] = lambda: os.uname().sysname == 'Darwin'
tools['is_linux'] = lambda: os.uname().sysname == 'Linux'

tools['execute'] = lambda cmd: (True, subprocess.check_output(cmd, shell=True).decode()) if not subprocess.call(cmd, shell=True) else (False, '')

def spawn(cmd, args=[], options={}):
    _options = {
        'cwd': os.getcwd(),
        'env': os.environ,
        'stdio': (subprocess.PIPE, subprocess.PIPE, subprocess.PIPE),
        'encoding': 'utf-8',
        'shell': os.name == 'nt'
    }
    _options.update(options)
    result = subprocess.run([cmd] + args, **_options)
    return (True, result) if result.returncode == 0 else (False, result.stderr)

tools['spawn'] = spawn
tools['get_separator'] = lambda: "\\" if tools['is_windows']() else "/"
tools['parse_path'] = lambda _path: (pathlib.Path(_path).parent, pathlib.Path(_path).stem, pathlib.Path(_path).suffix.lstrip('.'), pathlib.Path(_path).name)

######################################################

encryption = {}

encryption['base64_encode'] = lambda content: base64.b64encode(content.encode()).decode()
encryption['base64_decode'] = lambda content: base64.b64decode(content).decode()

######################################################

httpy = {}

def httpy_curl(url, method, params=None, headers=None):
    js['assert'](js['is_text'](url))
    method = method.upper()
    js['assert'](method in ['POST', 'GET'])
    params = params or {}
    headers = headers or {}
    tempFile = './.js.http.log'
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

httpy['request'] = lambda url, method, params=None, headers=None: (lambda code, content: [code == 200, code, content])(*httpy_curl(url, method, params, headers))
httpy['get'] = lambda url, params=None, headers=None: httpy['request'](url, 'GET', params, headers)
httpy['post'] = lambda url, params=None, headers=None: httpy['request'](url, 'POST', params, headers)

def httpy_download(url, _path, withPrint=False):
    if not js['is_text'](url) or not js['is_text'](_path):
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

httpy['download'] = httpy_download

######################################################

tools_module = {'js': js, 'files': files, 'terminal': terminal, 'tools': tools, 'encryption': encryption, 'httpy': httpy}


