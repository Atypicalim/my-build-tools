/**
 * html
 */

const { KEYS, TYPES, CONFIGS } = require("./constants.js");
const { js, files, tools, encryption } = require("./tools.js");
const { MyBuilderBase } = require("./builder_base.js");

let fs = require("fs");

class MyHtmlBuilder extends MyBuilderBase {

    constructor(...args) {
        super("html", ...args);
        this._lineArr = [];
        this._fileMap = {};
    }

    containScript(isOnlyLocal) {
        this._isContainScript = true;
        this._isScriptLocal = isOnlyLocal === true;
        return this;
    }

    containStyle(isOnlyLocal) {
        this._isContainStyle = true;
        this._isStyleLocal = isOnlyLocal === true;
        return this;
    }

    containImage(isOnlyLocal) {
        this._isContainImage = true;
        this._isImageLocal = isOnlyLocal === true;
        return this;
    }

    _processScript(line, path) {
        if (!this._isContainScript) return;
        this._print("process script:", path);
        const content = this._readFile(path, this._isScriptLocal);
        return `<script type="text/javascript" origin_file="${path}">\n${content}\n</script>\n`;
    }

    _processStyle(line, path) {
        if (!this._isContainStyle) return;
        this._print("process style:", path);
        const content = this._readFile(path, this._isScriptLocal);
        return `<style type="text/css" file="${path}">\n${content}\n</style>\n`;
    }


    _processImage(line, path) {
        if (!this._isContainImage) return;
        this._print("process image:", path);
        const content = this._readFile(path, this._isScriptLocal, null);
        const base64 = encryption.base64_encode(content);
        const data = `data:image/png;base64,${base64}`;
        return line.replace(path, data);
    }

    _processBuild() {
        this._print("contain script:", this._isContainScript === true);
        this._print("contain style:", this._isContainStyle === true);
        this._print("contain image:", this._isContainImage === true);
        this._assert(this._inputFiles.length >= 1, "input file not found");
        this._assert(this._inputFiles.length <= 1, "input file too much");
        const content = files.read(this._inputFiles[0]);
        this._assert(content.length > 0, "input file is empty");
        this._lineArr = content.split("\n");

        const urlRule = "[\'\"]([^\'\"]*)[\'\"]";
        for (let i = 0; i < this._lineArr.length; i++) {
            let newLine = null;

            if (!newLine) {
                const scriptPathMatch = this._lineArr[i].match(new RegExp("<script[^\n]*src=" + urlRule));
                if (scriptPathMatch) {
                    const scriptPath = scriptPathMatch[1];
                    newLine = this._processScript(this._lineArr[i], scriptPath);
                }
            }

            if (!newLine) {
                const stylePathMatch = this._lineArr[i].match(new RegExp("<link[^\n]*href=" + urlRule));
                if (stylePathMatch) {
                    const stylePath = stylePathMatch[1];
                    newLine = this._processStyle(this._lineArr[i], stylePath);
                }
            }

            if (!newLine) {
                const imagePathMatch = this._lineArr[i].match(new RegExp("<img[^\n]*src=" + urlRule));
                if (imagePathMatch) {
                    const imagePath = imagePathMatch[1];
                    newLine = this._processImage(this._lineArr[i], imagePath);
                }
            }

            if (newLine) {
                this._lineArr[i] = newLine;
            }
        }

        this._print("contain end.");
        this._print("creating target ...");
        const html = this._lineArr.join("\n");
        this._assert(this._outputFile !== undefined, "output path not found");
        files.write(this._outputFile, html);
        this._print("writing target succeeded!");
        return this;
    }

}

module.exports = {MyHtmlBuilder};
