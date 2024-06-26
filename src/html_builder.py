import re
import base64
from constants import KEYS, TYPES
from tools import py, files, tools, encryption
from builder_base import MyBuilderBase

class MyHtmlBuilder(MyBuilderBase):

    def __init__(self, *args):
        super().__init__("html", *args)
        self._lineArr = []
        self._fileMap = {}

    def contain_script(self, is_only_local):
        self._isContainScript = True
        self._isScriptLocal = is_only_local is True
        return self

    def contain_style(self, is_only_local):
        self._isContainStyle = True
        self._isStyleLocal = is_only_local is True
        return self

    def contain_image(self, is_only_local):
        self._isContainImage = True
        self._isImageLocal = is_only_local is True
        return self

    def _process_script(self, line, path):
        if not self._isContainScript:
            return
        self._print("process script:", path)
        content = self._read_file(path, self._isScriptLocal)
        return f'<script type="text/javascript" origin_file="{path}">\n{content}\n</script>\n'

    def _process_style(self, line, path):
        if not self._isContainStyle:
            return
        self._print("process style:", path)
        content = self._read_file(path, self._isScriptLocal)
        return f'<style type="text/css" file="{path}">\n{content}\n</style>\n'

    def _process_image(self, line, path):
        if not self._isContainImage:
            return
        self._print("process image:", path)
        content = self._read_file(path, self._isScriptLocal, None)
        base64_content = base64.b64encode(content).decode('utf-8')
        data = f'data:image/png;base64,{base64_content}'
        return line.replace(path, data)

    def _process_build(self):
        self._print("contain script:", self._isContainScript is True)
        self._print("contain style:", self._isContainStyle is True)
        self._print("contain image:", self._isContainImage is True)
        self._assert(len(self._inputFiles) >= 1, "input file not found")
        self._assert(len(self._inputFiles) <= 1, "input file too much")
        content = files.read(self._inputFiles[0])
        self._assert(len(content) > 0, "input file is empty")
        self._lineArr = content.split("\n")

        url_rule = r"[\'\"]([^\'\"]*)[\'\"]"
        for i in range(len(self._lineArr)):
            new_line = None

            if not new_line:
                script_path_match = re.search(rf"<script[^\n]*src={url_rule}", self._lineArr[i])
                if script_path_match:
                    script_path = script_path_match.group(1)
                    new_line = self._process_script(self._lineArr[i], script_path)

            if not new_line:
                style_path_match = re.search(rf"<link[^\n]*href={url_rule}", self._lineArr[i])
                if style_path_match:
                    style_path = style_path_match.group(1)
                    new_line = self._process_style(self._lineArr[i], style_path)

            if not new_line:
                image_path_match = re.search(rf"<img[^\n]*src={url_rule}", self._lineArr[i])
                if image_path_match:
                    image_path = image_path_match.group(1)
                    new_line = self._process_image(self._lineArr[i], image_path)

            if new_line:
                self._lineArr[i] = new_line

        self._print("contain end.")
        self._print("creating target ...")
        html = "\n".join(self._lineArr)
        self._assert(self._outputFile is not None, "output path not found")
        files.write(self._outputFile, html)
        self._print("writing target succeeded!")
        return self


