/**
 * c
 */

const { KEYS, TYPES, CONFIGS } = require("./constants.js");
const { js, files, tools } = require("./tools.js");
const { MyBuilderBase } = require("./builder_base.js");

const child_process = require('child_process');

const MY_RC_FILE_TEMPLATE = `
id ICON "%s"
`;

class MyCBuilder extends MyBuilderBase {

    constructor(...args) {
        super("C", ...args);
        this._includeDirs = [];
        this._linkingDirs = [];
        this._linkingTags = [];
        this._extraFlags = [];
        this._targetExecutable = null;
        this.MY_RES_FILE_PATH = this._buildDir + ".lcb_resource.res";
        this.MY_RC_FILE_PATH = this._buildDir + ".lcb_resource.rc";
        files.write(this.MY_RES_FILE_PATH, "");
        files.write(this.MY_RC_FILE_PATH, "");
    }

    _initBuilder() {
        
    }

    _downloadByGit(config) {
        const url = config[KEYS.URL];
        const branch = config[KEYS.BRANCH] || 'master';
        const directory = this._libsDir + config[KEYS.NAME] + this._separator;
        super._downloadByGit(url, branch, directory);
    }

    _downloadByZip(config) {
        const name = config[KEYS.NAME];
        const url = config[KEYS.URL];
        const directory = this._libsDir + name + this._separator;
        super._downloadByZip(url, directory);
    }

    _downloadByGzip(config) {
        const name = config[KEYS.NAME];
        const url = config[KEYS.URL];
        const directory = this._libsDir + name + this._separator;
        super._downloadByGzip(url, directory);
    }

    _getConfig(name) {
        const config = CONFIGS[name];
        this._assert(config !== undefined, `lib [${name}] not found`);
        if (tools.is_windows()) {
            Object.assign(config, config[KEYS.WIN] || {});
        } else if (tools.is_mac()) {
            Object.assign(config, config[KEYS.MAC] || {});
        } else if (tools.is_linux()) {
            Object.assign(config, config[KEYS.LNX] || {});
        }
        return config;
    }

    _installLib(name) {
        const config = this._getConfig(name);
        this._assert(config !== null, `lib [${name}] not found`);
        const parts = config[KEYS.URL].split(".");
        config[KEYS.EXT] = parts[parts.length - 1].toUpperCase();
        config[KEYS.TYPE] = config[KEYS.EXT];
        config[KEYS.NAME] = name;

        if (config[KEYS.TYPE] === TYPES.GIT) {
            this._downloadByGit(config);
        } else if (config[KEYS.TYPE] === TYPES.ZIP) {
            this._downloadByZip(config);
        } else if (config[KEYS.TYPE] === TYPES.GZ) {
            this._downloadByGzip(config);
        } else {
            this._error(`invalid lib type [${config[KEYS.TYPE]}]`);
        }
    }

    _containLib(name) {
        const config = this._getConfig(name);
        const directory = this._libsDir + name + this._separator;
        this._assert(config !== null, `lib [${name}] not found`);
        this._assert(files.is_folder(directory), `lib [${name}] not installed`);

        const insertInclue = (dir) => {
            dir = directory + dir;
            this._assert(files.is_folder(dir), `include directory [${dir}] not found`);
            this._includeDirs.push(dir);
        };

        if (js.is_string(config[KEYS.DIR_I])) {
            insertInclue(config[KEYS.DIR_I]);
        } else if (Array.isArray(config[KEYS.DIR_I])) {
            for (const v of config[KEYS.DIR_I]) {
                insertInclue(v);
            }
        }

        const insertLinking = (dir) => {
            dir = directory + dir;
            this._assert(files.is_folder(dir), `linking directory [${dir}] not found`);
            this._linkingDirs.push(dir);
        };

        if (js.is_string(config[KEYS.DIR_L])) {
            insertLinking(config[KEYS.DIR_L]);
        } else if (Array.isArray(config[KEYS.DIR_L])) {
            for (const v of config[KEYS.DIR_L]) {
                insertLinking(v);
            }
        }

        const insertTags = (tag) => {
            this._linkingTags.push(tag);
        };

        if (js.is_string(config[KEYS.LIB_L])) {
            insertTags(config[KEYS.LIB_L]);
        } else if (Array.isArray(config[KEYS.LIB_L])) {
            for (const v of config[KEYS.LIB_L]) {
                insertTags(v);
            }
        }

        if (js.is_string(config[KEYS.FLAGS])) {
            this._extraFlags.push(config[KEYS.FLAGS]);
        }
    }

    _containFiles(name) {
        const config = this._getConfig(name);
        this._assert(config !== null, `lib [${name}] not found`);
        const directory = this._libsDir + name + this._separator;
        const arr = config[KEYS.FILES] || [];

        for (let i = 0; i < arr.length; i++) {
            let v = arr[i];
            let path = v;
            if (!files.is_file(path)) {
                path = directory + config[KEYS.DIR_I] + v;
            }
            this._assert(files.is_file(path), `input file not found: ${v}`);
            this._inputNames.push(v);
            this._inputFiles.push(path);
        }
    }

    setLibs(...args) {
        this._print('CONTAIN LIB START!');
        let libs = [...args];
        if (Array.isArray(libs[0])) {
            libs = libs[0];
        }
        for (let i = 0; i < libs.length; i++) {
            const lib = libs[i];
            this._print(`contain:[${lib}]`);
            this._installLib(lib);
            this._containLib(lib);
            this._containFiles(lib);
        }
        this._print('CONTAIN LIB END!');
        return this;
    }

    setIcon(iconPath) {
        this._print('SET ICON START!');
        this._print('icon:', iconPath);
        if (!tools.is_windows()) {
            this._print('SET ICON IGNORED!');
            return;
        }
        iconPath = this._projDir + iconPath;
        const myRcInfo = MY_RC_FILE_TEMPLATE.replace('%s', iconPath);
        files.write(this.MY_RC_FILE_PATH, myRcInfo);
        const command = `windres ${this.MY_RC_FILE_PATH} -O coff -o ${this.MY_RES_FILE_PATH}`;
        const [isOk, err] = tools.execute(command);
        this._assert(isOk, `resource compile failed, err: ${String(err)}`);
        this._print('SET ICON END!');
        return this;
    }

    setOutput(path) {
        super.setOutput(path);
        this._targetExecutable = tools.is_windows() ? `${String(this._outputFile)}.exe` : String(this._outputFile);
        return this;
    }

    _processBuild() {
        this._print('PROCESS GCC START!');
        this._assert(this._inputFiles[0] !== undefined, 'input files are not defined!');
        this._assert(this._outputFile !== undefined, 'output file is not defined!');

        let includeDirCmd = '';
        for (const v of this._includeDirs) {
            includeDirCmd += ` -I ${v}`;
        }

        let linkingDirCmd = '';
        for (const v of this._linkingDirs) {
            linkingDirCmd += ` -L ${v}`;
        }

        let linkingTagCmd = '';
        for (const v of this._linkingTags) {
            linkingTagCmd += ` -l ${v}`;
        }

        let extraFlagsCmd = '';
        for (const v of this._extraFlags) {
            extraFlagsCmd += ` ${v}`;
        }

        const resCmds = tools.is_windows() ? `${this.MY_RES_FILE_PATH}` : '';
        const icludeCmds = `${includeDirCmd}`;
        const linkCmds = `${linkingDirCmd} ${linkingTagCmd}`;

        let inputFiles = '';
        for (const v of this._inputFiles) {
            inputFiles += ` ${v}`;
        }

        const cc = tools.is_windows() ? 'gcc' : 'clang';
        let cmd = `${cc} ${inputFiles} -o ${this._targetExecutable} ${resCmds} ${icludeCmds} ${linkCmds} ${extraFlagsCmd}`;

        if (this._isRelease) {
            cmd += ' -O2 -mwindows';
        }

        if (this._isDebug) {
            this._print(`cmd:${cmd}`);
        }

        const [isOk, output] = tools.execute(cmd);
        if (!isOk) {
            this._print('gcc process failed!');
            this._error(`err:${output}`);
        }

        this._print('gcc process succeeded!');

        files.delete(this.MY_RES_FILE_PATH);
        files.delete(this.MY_RC_FILE_PATH);

        this._print('PROCESS GCC END!');

        return this;
    }

    run(path) {
        path = path ? this._projDir + path : this._targetExecutable;
        const [dir, name, _, nameWithExt] = tools.parse_path(path);
        this._print(`RUNNING:${path}`);
        const nam = tools.is_windows() ? nameWithExt : name;
        const exe = `.${this._separator}${nam}`
        const cmd = `cmd cd ${dir} ; ${exe}`;
        if (this._isDebug) {
            this._print(`cmd:${cmd}`);
        }
        let [isOk, extra] = tools.spawn(exe, [], {cwd: dir});
        this._print(`RUNNED:${isOk}`, isOk ? "" : extra);
    }
}

module.exports = {MyCBuilder};
