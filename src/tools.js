/**
 * tools
 */

const http = require('http'); 
var fs = require('fs');
const child_process = require('child_process');
const path = require('path');
const readline = require('readline');

//////////////////////////////////////////////////////

// First, checks if it isn't implemented yet.
if (!String.prototype.format) {
    String.prototype.format = function() {
      var args = arguments;
      return this.replace(/{(\d+)}/g, function(match, number) { 
        return typeof args[number] != 'undefined'
          ? args[number]
          : match
        ;
      });
    };
  }

//////////////////////////////////////////////////////

let js = {}

js.is_boolean = (value) => {
    return typeof value == 'boolean';
}

js.is_number = (value) => {
    return typeof value == 'number';
}

js.is_string = (value) => {
    return typeof value == 'string';
}

js.is_text = (val) => {
    return typeof val == 'string' && val.trim().length > 0;
}

js.is_array = (value) => {
    return Array.isArray(value);
}

js.is_object = (value) => {
    return !Array.isArray(value) && typeof value == 'object';
}

js.print = (...args) => {
    console.log(...args);
}

js.trace = (...args) => {
    console.log(args.join(' '));
    console.log(new Error().trace);
}

js.assert = (val, ...args) => {
    if (!val) throw new Error(args.join(' '));
}
js.error = (...args) => {
    throw new Error(args.join(' '));
}

//////////////////////////////////////////////////////

const files = {};

files.delete = (path) => {
    try { fs.unlinkSync(path); } catch (e) { }
}

files.mk_folder = (path) => {
    if (!fs.existsSync(path)){
        fs.mkdirSync(path, {recursive: true});
    }
}

files.is_folder = (path) => {
    try {
        return fs.lstatSync(path).isDirectory();
    } catch (e) {
        return false;
    }
}

files.is_file = (path) => {
    try {
        return fs.lstatSync(path).isFile(); 
    } catch (e) {
        return false;
    }
}

files.is_exist =(path) => {
    return fs.existsSync(path);
}

files.write = (path, content, encoding) => {
    fs.writeFileSync(path, content, {encoding: encoding});
}

files.read = (path, encoding = 'utf-8') => {
    return fs.readFileSync(path, {encoding: encoding});
}

files.copy = (_from, _to) => {
    fs.copyFileSync(_from, _to);
}

files.size = (_path) => {
    try {
        var stats = fs.statSync(_path);
        var bytes = stats.size;
        return bytes;
    } catch (e) {
        return -1;
    }
}

//////////////////////////////////////////////////////

const terminal = {}

async function read_line(msg) {
    let promise = new Promise((resolve, reject) => {
        const rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout
        });
        rl.question(msg || "input:", (answer) => {
            rl.close();
            resolve(answer);
        });
    })
    return promise;
}
terminal.read_line = read_line;

async function read_selection(msg, options) {
    console.log(msg || "select:", options);
    while(true) {
        let txt = await read_line();
        if (condition) {
            if (Array.find(options, txt)) {
                return txt
            }
        }
    }
}
terminal.read_selection = read_selection;

//////////////////////////////////////////////////////

const tools = {};

tools.is_windows = () => {
    return process.platform == "win32" || process.platform == "win64";
}

tools.is_mac = () => {
    return process.platform == "darwin";
}

tools.is_linux = () => {
    return process.platform == "linux";
}

tools.execute = (cmd) => {
    try {
        let options = {stdio : 'pipe' };
        const output = child_process.execSync(cmd, options);
        return [true, output.toString()];
    } catch (error) {
        return [false, `${error}`];
    }
}

tools.spawn = (cmd, args = [], options = {}) => {
    if (!options) {
        options = {};
    }
    let _options = {
        cwd: process.cwd(),
        env: process.env,
        stdio: [process.stdin, process.stdout, process.stderr],
        encoding: 'utf-8'
    }
    Object.assign(_options, options)
    var child = child_process.spawnSync(cmd, args, _options);
    return [child.error == null, child.error, child];
}

tools.get_separator = () => {
    return tools.is_windows() ? "\\" : "/";
}

tools.parse_path = (_path) => {
    let parsed = path.parse(_path);
    let dir = parsed.dir;
    let name = parsed.name;
    let ext = parsed.ext.split(".").pop();
    let nameWithExt = parsed.base;
    return [dir, name, ext, nameWithExt];
}

//////////////////////////////////////////////////////

let encryption = {}

encryption.base64_encode = (content) => {
    return Buffer.from(content).toString("base64");
}

encryption.base64_decode = (content) => {
    return Buffer.from(content, "base64").toString('ascii');
}

//////////////////////////////////////////////////////

let httpy = {}

function httpy_curl(url, method, params, headers) {
    //
    js.assert(js.is_text(url));
    method = method.toUpperCase();
    js.assert(method == 'POST' || method == 'GET');
    params = params || {};
    headers = headers || {};
    //
    const tempFile = './.js.http.log';
    files.delete(tempFile);
    //
    let h = '';
    for (const [k, v] of Object.entries(headers)) {
        assert(is_text(k));
        assert(is_string(v) || is_number(v));
        if (h !== '') {
            h += ';';
        }
        h += `-H '${String(k)}:${String(v)}'`;
    }
    //
    let b = '';
    if (method === 'GET') {
    for (const [k, v] of Object.entries(params)) {
        if (!url.includes('?')) {
            url += '?';
        }
        assert(is_text(k));
        assert(is_string(v) || is_number(v));
        url += `${String(k)}=${String(v)}`;
    }
    } else if (method === 'POST') {
        b = `-d '${JSON.stringify(params)}'`;
    }
    //
    const cmd = `curl "${url}" -i --silent  -X ${method} -o "${tempFile}" ${h} ${b}`;
    const [isOk, output] = tools.execute(cmd);
    const content = files.read(tempFile, 'utf8');
    files.delete(tempFile);
    if (!isOk) {
        return [-1, output];
    }
    //
    const [head, body] = content.split(/\r?\n\r?\n/g, 2);
    const codeMatch = head.match(/HTTP.+\s(\d{3})/);
    const code = codeMatch ? parseInt(codeMatch[1]) : -1;
    //
    if (code < 0) {
        return [-1, output];
    } else {
        return [code, body];
    }
}

httpy.request = (url, method, params, headers) => {
    const [code, content] = httpy_curl(url, method, params, headers);
    return [code == 200, code, content];
}
  
httpy.get = (url, params, headers) => {
    return httpy.request(url, 'GET', params, headers);
}
  
httpy.post = (url, params, headers) => {
    return httpy.request(url, 'POST', params, headers);
}

httpy.download = (url, _path, withPrint = false) => {
    if (!js.is_text(url) || !js.is_text(_path)) {
      throw new Error('Invalid URL or file path');
    }
    const folder = path.dirname(_path);
    fs.mkdirSync(folder, { recursive: true });
    let cmd = `curl -L "${url}" -o "${_path}" --max-redirs 3`;
    try {
        let options = {stdio : withPrint ? null : 'pipe' };
        const output = child_process.execSync(cmd, options);
        return [true, output.toString()];
    } catch (error) {
        return [false, `${error}`];
    }
}

//////////////////////////////////////////////////////

module.exports = {js, files, terminal, tools, encryption, httpy};
