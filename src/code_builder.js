/**
 * code
 */

const { KEYS, TYPES, CONFIGS } = require("./constants.js");
const { js, files, tools, encryption } = require("./tools.js");
const { MyBuilderBase } = require("./builder_base.js");

class MyCodeBuilder extends MyBuilderBase {

    constructor() {
        super("code");
        this._lineArr = [];
        this._macroStartTag = "[M[";
        this._macroEndTag = "]M]";
        this._commentTag = "//";
        this._headFormat = '{0} {1}';
    }

    setComment(commentTag, headFormat) {
        js.assert(js.is_text(commentTag), 'invalid comment tag');
        this._commentTag = commentTag;
        console.log("\n\n\n-->", "comment", commentTag, headFormat);
        if (headFormat !== undefined) {
            this._headFormat = headFormat;
        }
        return this;
    }

    onMacro(macroCallback) {
        this._onMacroCallback = macroCallback;
        return this;
    }

    onLine(lineCallback) {
        this._onLineCallback = lineCallback;
        return this;
    }

    _COMMAND_FILE_BASE64(code, args) {
        const filePath = args[0];
        this._assert(files.is_file(filePath), `file not found, path: ${filePath}`);
        const content = files.read(filePath, 'base64');
        return code.format(content);
    }

    _COMMAND_FILE_PLAIN(code, args) {
        const filePath = args[0];
        this._assert(files.is_file(filePath), `file not found, path: ${filePath}`);
        const content = files.read(filePath, 'utf8');
        return code.format(content);
    }

    _COMMAND_FILE_STRING(code, args) {
        let filePath = args[0];
        const escapeTag = args[1] || "";
        const minimize = args[2] !== undefined && args[2].toLowerCase() === "true";
        filePath = this._projDir + filePath;
        this._assert(files.is_file(filePath), `file not found, path: ${filePath}`);
        let fileContent = files.read(filePath);
        let lineArr = fileContent.split("\n");
        for (let i = 0; i < lineArr.length; i++) {
            lineArr[i] = lineArr[i]
                .replace(/[\n\r]+$/, " ")
                .replace(/\\/g, `${escapeTag}\\${escapeTag}\\`)
                .replace(/"/g, `${escapeTag}\\${escapeTag}"`)
                .replace(/'/g, `${escapeTag}\\${escapeTag}'`);
        }
        let result = lineArr.join(` ${escapeTag}\\n `);
        if (minimize) {
            result = result.replace(/\s+/g, " ");
        }
        js.print("\n\n\n--->", result);
        return code.format(result);
    }


    _COMMAND_LINE_REFPLACE(code, args) {
        return args[0];
    }

    _parseLine(index, line) {
        const commentPosition = line.indexOf(this._commentTag);
        if (commentPosition === -1) {
            if (this._onLineCallback) {
                return this._onLineCallback(line);
            }
            return line;
        }
        const macroStartIndex = line.indexOf(this._macroStartTag);
        const macroEndIndex = line.indexOf(this._macroEndTag);
        if (macroStartIndex === -1 || macroEndIndex === -1 || macroStartIndex >= macroEndIndex) {
            if (this._onLineCallback) {
                return this._onLineCallback(line);
            }
            return line;
        }
        const code = line.substring(0, commentPosition);
        const macro = line.substring(macroStartIndex + this._macroEndTag.length, macroEndIndex);
        const body = macro.split("|");
        this._assert(body.length >= 1, "invalid macro, line: " + line);
        const command = body[0].trim();
        const args = body.slice(1).map(arg => arg.trim());
        if (this['_COMMAND_' + command]) {
            return this['_COMMAND_' + command](code, args);
        } else if (this._onMacroCallback) {
            return this._onMacroCallback(code, command, ...args);
        } else {
            return line;
        }
    }

    _processBuild() {
        this._assert(!Array.isArray(this._inputFiles) || this._inputFiles.length > 0, "input files are not defined");
        this._assert(typeof this._commentTag === "string", "comment tag is not defined");

        this._print("reading files ...");
        for (let i = 0; i < this._inputFiles.length; i++) {
            const path = this._inputFiles[i];
            this._assert(files.is_file(path), "file not found: " + path);
            const content = files.read(path);
            this._assert(content.length > 0, "input files are empty");
            const lineArr = content.split("\n");
            //
            if (js.is_text(this._headFormat)) {
                const currName = this._inputNames[i];
                const currDate = new Date().toLocaleString();
                const headInfo = this._headFormat.format(currName, currDate);
                this._lineArr.push("");
                this._lineArr.push(this._commentTag + " " + headInfo);
                this._lineArr.push("");
            }
            //
            for (let index = 0; index < lineArr.length; index++) {
                const line = lineArr[index];
                const newLine = this._parseLine(index, line);
                if (Array.isArray(newLine)) {
                    for (let i = 0; i < newLine.length; i++) {
                        this._lineArr.push(newLine[i]);
                    }
                } else if (typeof newLine === "string") {
                    this._lineArr.push(newLine);
                }
            }
        }

        this._print("creating target ...");
        const html = this._lineArr.join("\n");
        this._assert(this._outputFile !== undefined, "output path not found");
        files.write(this._outputFile, html);
        this._print("writing target succeeded!");
        return this;
    }

}

module.exports = {MyCodeBuilder};
