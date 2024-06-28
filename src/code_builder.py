import os
import base64
from datetime import datetime

from tools import *
from builder_base import *

class MyCodeBuilder(MyBuilderBase):

    def __init__(self, *args):
        super().__init__("code", *args)
        self._lineArr = []
        self._macroStartTag = "[M["
        self._macroEndTag = "]M]"
        self._commentTag = "//"
        self._headFormat = '{0} {1}'

    def setComment(self, commentTag, headFormat=None):
        py.check(py.is_text(commentTag), 'invalid comment tag')
        self._commentTag = commentTag
        if headFormat is not None:
            self._headFormat = headFormat
        return self

    def onMacro(self, macroCallback):
        self._onMacroCallback = macroCallback
        return self

    def onLine(self, lineCallback):
        self._onLineCallback = lineCallback
        return self

    def _COMMAND_FILE_BASE64(self, code, args):
        filePath = args[0]
        self._assert(files.is_file(filePath), f"file not found, path: {filePath}")
        with open(filePath, 'rb') as f:
            content = base64.b64encode(f.read()).decode('utf-8')
        return code.format(content)

    def _COMMAND_FILE_PLAIN(self, code, args):
        filePath = args[0]
        self._assert(files.is_file(filePath), f"file not found, path: {filePath}")
        with open(filePath, 'r', encoding='utf-8') as f:
            content = f.read()
        return code.format(content)

    def _COMMAND_FILE_STRING(self, code, args):
        filePath = args[0]
        escapeTag = args[1] if len(args) > 1 else ""
        minimize = len(args) > 2 and args[2].lower() == "true"
        filePath = os.path.join(self._projDir, filePath)
        self._assert(files.is_file(filePath), f"file not found, path: {filePath}")
        with open(filePath, 'r') as f:
            fileContent = f.read()
        lineArr = fileContent.split("\n")
        for i in range(len(lineArr)):
            lineArr[i] = lineArr[i].replace("\n", " ").replace("\\", f"{escapeTag}\\{escapeTag}\\").replace('"', f'{escapeTag}\\"').replace("'", f"{escapeTag}\\{escapeTag}'")
        result = f" {escapeTag}\\n ".join(lineArr)
        if minimize:
            result = " ".join(result.split())
        return code.format(result)

    def _COMMAND_LINE_REFPLACE(self, code, args):
        return args[0]

    def _parseLine(self, index, line):
        commentPosition = line.find(self._commentTag)
        if commentPosition == -1:
            if self._onLineCallback:
                return self._onLineCallback(line)
            return line
        macroStartIndex = line.find(self._macroStartTag)
        macroEndIndex = line.find(self._macroEndTag)
        if macroStartIndex == -1 or macroEndIndex == -1 or macroStartIndex >= macroEndIndex:
            if self._onLineCallback:
                return self._onLineCallback(line)
            return line
        code = line[:commentPosition]
        macro = line[macroStartIndex + len(self._macroEndTag):macroEndIndex]
        body = macro.split("|")
        self._assert(len(body) >= 1, f"invalid macro, line: {line}")
        command = body[0].strip()
        args = [arg.strip() for arg in body[1:]]
        if hasattr(self, f'_COMMAND_{command}'):
            return getattr(self, f'_COMMAND_{command}')(code, args)
        elif self._onMacroCallback:
            return self._onMacroCallback(code, command, *args)
        else:
            return line

    def _processBuild(self):
        self._assert(isinstance(self._inputFiles, list) and len(self._inputFiles) > 0, "input files are not defined")
        self._assert(isinstance(self._commentTag, str), "comment tag is not defined")

        self._print("reading files ...")
        for i, path in enumerate(self._inputFiles):
            self._assert(files.is_file(path), f"file not found: {path}")
            with open(path, 'r') as f:
                content = f.read()
            self._assert(len(content) > 0, "input files are empty")
            lineArr = content.split("\n")
            if py.is_text(self._headFormat):
                currName = self._inputNames[i]
                currDate = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                headInfo = self._headFormat.format(currName, currDate)
                self._lineArr.append("")
                self._lineArr.append(f"{self._commentTag} {headInfo}")
                self._lineArr.append("")
            for index, line in enumerate(lineArr):
                newLine = self._parseLine(index, line)
                if isinstance(newLine, list):
                    self._lineArr.extend(newLine)
                elif isinstance(newLine, str):
                    self._lineArr.append(newLine)

        self._print("creating target ...")
        html = "\n".join(self._lineArr)
        self._assert(self._outputFile is not None, "output path not found")
        with open(self._outputFile, 'w') as f:
            f.write(html)
        self._print("writing target succeeded!")
        return self



