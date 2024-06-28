import re
import base64

from tools import *
from builder_base import *

class MyHtmlBuilder(MyBuilderBase):

    def __init__(self, args={}):
        super().__init__("html")
        self._lineArr = []
        self._fileMap = {}
        self._parse(args)

    def containScript(self, isOnlyLocal=False):
        self._isContainScript = True
        self._isScriptLocal = isOnlyLocal is True
        return self

    def containStyle(self, isOnlyLocal=False):
        self._isContainStyle = True
        self._isStyleLocal = isOnlyLocal is True
        return self

    def containImage(self, isOnlyLocal=False):
        self._isContainImage = True
        self._isImageLocal = isOnlyLocal is True
        return self

    def _processScript(self, line, path):
        if not self._isContainScript:
            return
        self._print("process script:", path)
        content = self._readFile(path, self._isScriptLocal, 'utf-8')
        return f'<script type="text/javascript" origin_file="{path}">\n{content}\n</script>\n'

    def _processStyle(self, line, path):
        if not self._isContainStyle:
            return
        self._print("process style:", path)
        content = self._readFile(path, self._isScriptLocal, 'utf-8')
        return f'<style type="text/css" file="{path}">\n{content}\n</style>\n'

    def _processImage(self, line, path):
        if not self._isContainImage:
            return
        self._print("process image:", path)
        content = self._readFile(path, self._isScriptLocal, None)
        base64_content = base64.b64encode(content).decode('utf-8')
        data = f'data:image/png;base64,{base64_content}'
        return line.replace(path, data)

    def _processBuild(self):
        self._print("contain script:", self._isContainScript is True)
        self._print("contain style:", self._isContainStyle is True)
        self._print("contain image:", self._isContainImage is True)
        self._assert(len(self._inputFiles) >= 1, "input file not found")
        self._assert(len(self._inputFiles) <= 1, "input file too much")
        content = files.read(self._inputFiles[0], 'utf-8')
        self._assert(len(content) > 0, "input file is empty")
        self._lineArr = content.split("\n")

        url_rule = r"[\'\"]([^\'\"]*)[\'\"]"
        for i in range(len(self._lineArr)):
            new_line = None

            if not new_line:
                script_path_match = re.search(rf"<script[^\n]*src={url_rule}", self._lineArr[i])
                if script_path_match:
                    script_path = script_path_match.group(1)
                    new_line = self._processScript(self._lineArr[i], script_path)

            if not new_line:
                style_path_match = re.search(rf"<link[^\n]*href={url_rule}", self._lineArr[i])
                if style_path_match:
                    style_path = style_path_match.group(1)
                    new_line = self._processStyle(self._lineArr[i], style_path)

            if not new_line:
                image_path_match = re.search(rf"<img[^\n]*src={url_rule}", self._lineArr[i])
                if image_path_match:
                    image_path = image_path_match.group(1)
                    new_line = self._processImage(self._lineArr[i], image_path)

            if new_line:
                self._lineArr[i] = new_line

        self._print("contain end.")
        self._print("creating target ...")
        html = "\n".join(self._lineArr)
        self._assert(self._outputFile is not None, "output path not found")
        files.write(self._outputFile, html, 'utf-8')
        self._print("writing target succeeded!")
        return self


