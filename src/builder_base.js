/**
 * base
 */

const { KEYS, TYPES, CONFIGS } = require("./constants.js");
const { js, files, tools, httpy } = require("./tools.js");
var path = require("path");

class MyBuilderBase {

    static createFunc = null;

    constructor(buildType, ...args) {
        buildType = buildType.toLowerCase();
        this._separator = tools.get_separator();
        this._printTag = "[build_" + buildType + "_tool]";
        this._projDir = process.cwd() + this._separator;
        this._rootDir = path.join(__dirname, "..") + this._separator;
        this._workDir = path.join(this._rootDir, "build") + this._separator;
        this._buildDir = path.join(this._workDir, buildType + "_dir") + this._separator;
        this._cacheDir = path.join(this._workDir, "cache") + this._separator;
        this._libsDir = path.join(this._workDir, buildType + "_libs") + this._separator;
        files.mk_folder(this._cacheDir);
        files.mk_folder(this._libsDir);
        this._needUpdate = false;
        this._name = "UNKNOWN";
        this._isDebug = false;
        this._isRelease = false;
        this._inputNames = [];
        this._inputFiles = [];
        this._outputFile = null;
        files.mk_folder(this._buildDir);
        //
        MyBuilderBase.createFunc(this, ...args);
        console.log(`\n-----------------[JS ${buildType} Builder]---------------------\n`);
        this._print("PROJ_DIR", this._projDir);
        this._print("ROOT_DIR", this._rootDir);
        this._print("WORK_DIR", this._workDir);
    }

    _print(...args) {
        console.log(this._printTag, this._name, ...args);
    }

    _assert(v, msg) {
        if (!v) {
            throw new Error(`${this._printTag} ${this._name} ${msg}`);
        }
    }

    _error(msg) {
        throw new Error(`${this._printTag} ${this._name} ${msg}`);
    }


    _downloadByGit(url, branch, directory) {
        if (!files.is_folder(directory)) {
            this._print('cloning...');
            const cmd = `git clone ${url} ${directory} --branch ${branch} --single-branch`;
            const [isOk, err] = tools.execute(cmd);
            this._assert(isOk, "git clone failed, err:" + String(err));
        } else if (this._needUpdate) {
            this._print('pulling...');
            const cmd = `cd ${directory} && git pull`;
            const [isOk, err] = tools.execute(cmd);
            this._assert(isOk, "git pull failed:" + String(err));
        }
    }

    _downloadByTar(url, directory) {
        if (files.is_folder(directory)) {
            this._print('downloaded!');
            return;
        }
        const cacheFile = this._downloadByUrl(url);
        this._print('untarring...');
        files.mk_folder(directory);
        const cmd = `tar -xvzf ${cacheFile} -C ${directory}`;
        const [isOk, err] = tools.execute(cmd);
        files.delete(cacheFile);
        this._assert(isOk, "untar failed, err:" + String(err));
    }

    _downloadByZip(url, directory) {
        if (files.is_folder(directory)) {
            this._print('downloaded!');
            return;
        }
        const cacheFile = this._downloadByUrl(url);
        this._print('unzipping...');
        files.mk_folder(directory);
        const cmd = `unzip ${cacheFile} -d ${directory}`;
        const [isOk, err] = tools.execute(cmd);
        files.delete(cacheFile);
        this._assert(isOk, "unzip failed, err:" + String(err));
    }

    _downloadByGzip(url, directory) {
        if (files.is_folder(directory)) {
            this._print('downloaded!');
            return;
        }
        const cacheFile = this._downloadByUrl(url);
        this._print('gunzipping...');
        files.mk_folder(directory);
        const cmd = `tar xzvf ${cacheFile} -C ${directory}`;
        const [isOk, err] = tools.execute(cmd);
        files.delete(cacheFile);
        this._assert(isOk, "gunzip failed, err:" + String(err));
    }

    _downloadByUrl(url, path) {
        const parts = url.split(".");
        const ext = parts[parts.length - 1];
        const cacheFile = path || this._cacheDir + "temp." + ext;
        files.delete(cacheFile);
        this._print('downloading ...');
        const [isOk, err] = httpy.download(url, cacheFile);
        if (!isOk || files.size(cacheFile) <= 0) {
            files.delete(cacheFile);
            this._error('download failed, err:' + String(err));
        }
        this._print('download succeeded.');
        return cacheFile;
    }

    _readFile(path, isOnlyLocal, encoding = "utf-8") {
        this._print("read file:" + path);
        const isRemote = path.startsWith("http");
        this._print("is remote:" + String(isRemote));
        if (isRemote) {
            if (isOnlyLocal) {
                this._print("skip remote.");
                return;
            }
            this._print("downloading remote ...");
            path = this._downloadByUrl(this, path);
        }
        this._assert(files.is_file(path), "file not found:" + path);
        this._print("reading file ...");
        const content = files.read(path, encoding);
        if (isRemote) {
            files.delete(path);
        }
        this._assert(content.length > 0, "read file failed!, path:" + path);
        this._print("read file succeeded!");
        return content;
    }

    setName(name) {
        js.assert(js.is_text(name), 'invalid task name for builder');
        this._name = name;
    }

    getName(name) {
        return this._name;
    }

    setDebug(value) {
        js.assert(typeof value === 'boolean', 'invalid task name for builder');
        this._isDebug = value;
    }

    setRelease(value) {
        js.assert(typeof value === 'boolean', 'invalid task name for builder');
        this._isRelease = value;
    }

    setInput(...args) {
        this._print("input files ...");
        this._assert(this._inputFiles.length == 0, "input files are already defined");
        const inputArr = [...args];
        for (let i = 0; i < inputArr.length; i++) {
            let v = inputArr[i];
            let path = v;
            if (!files.is_file(path)) {
                path = this._projDir + v;
            }
            this._assert(files.is_file(path) || files.is_folder(path), "input file not found:" + v);
            this._print("input path:" + v);
            this._inputNames.push(v);
            this._inputFiles.push(path);
        }
        return this;
    }

    setOutput(path) {
        this._print("output file ...");
        this._assert(this._outputFile == null, "output file is already defined");
        this._print("output file:" + path);
        this._outputFile = this._projDir + path;
        return this;
    }

    _processBuild() {
        this._error("please implement start func ...");
    }

    start() {
        this._print('BUILD START:');
        this._processBuild();
        this._print('BUILD END!\n');
        return this;
    }

}

module.exports = {MyBuilderBase};
