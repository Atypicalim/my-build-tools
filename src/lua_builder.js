/**
 * lua
 */

const { KEYS, TYPES, CONFIGS } = require("./constants.js");
const { js, files, tools } = require("./tools.js");
const { MyBuilderBase } = require("./builder_base.js");

const child_process = require('child_process');

class MyLuaBuilder extends MyBuilderBase {

    constructor() {
        super("lua");
        this._targetExecutable = null;
    }

    setOutput(path) {
        super.setOutput(path);
        this._targetExecutable = tools.is_windows()
            ? `${this._outputFile}.exe`
            : `${this._outputFile}`;
        return this;
    }

    _processBuild() {
        this._print('PROCESS PACKAGE START!');
        this._assert(this._inputFiles[0] !== undefined, "input files are not defined!");
        this._assert(this._outputFile !== undefined, "output file is not defined!");
        // https://web.archive.org/web/20130721014948if_/http://www.soongsoft.com/lhf/lua/5.1/srlua.tgz
        const glue = this._rootDir + "tools/srlua/glue.exe";
        const srlua = this._rootDir + "tools/srlua/srlua.exe";
        let inputs = "";
        for (let i = 0; i < this._inputFiles.length; i++) {
            inputs += this._inputFiles[i] + " ";
        }
        this._print('packaging...');
        const cmd = `${glue} ${srlua} ${inputs}${this._outputFile}.exe`;
        if (this._isDebug) {
            this._print(`cmd:${cmd}`);
        }
        const [isOk, output] = tools.execute(cmd);
        if (!isOk) {
            this._print("package process failed!");
            this._error("err:" + output);
        }
        this._print('PROCESS PACKAGE END!');
        return this;
    }

    run(path) {
        path = path ? this._projDir + path : this._targetExecutable;
        this._print("RUNNING:" + path);
        tools.spawn(path);
    }

}

module.exports = {MyLuaBuilder};
