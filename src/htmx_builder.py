import re
import sys
import base64

from tools import *
from builder_base import *


from c_builder import MyCBuilder

class MyHtmxBuilder(MyBuilderBase):

    def __init__(self, args={}):
        super().__init__("htmx")
        self._title = "Unknown..."
        self._width = 500
        self._height = 500
        self._resizable = False
        self._parse(args)

    def setTitle(self, title):
        self._title = title

    def setSize(self, width = None, height = None):
        if width != None:
            self._width = width
        if height != None:
            self._height = height

    def setResizable(self, resizable):
        self._resizable = resizable

    def _processBuild(self):
        self._print("prepare xtml")
        self._print("prepare excutable")
        
        self._assert(len(self._inputFiles) >= 1, "input file not found")
        self._assert(len(self._inputFiles) <= 1, "input file too much")
        inputFile = self._inputFiles[0]
        content = files.read(inputFile, 'utf-8')
        self._assert(len(content) > 0, "input file is empty")
        #
        files.copy(inputFile, "temporary.html")
        self._assert(self._outputFile is not None, "output path not found")
        self._print("building target ...")
        # 
        # tools.disable_print()
        bldr = MyCBuilder()
        bldr.setDebug(self._isDebug)
        bldr.setRelease(self._isRelease)
        bldr.setName(self._name)
        bldr.setInput(self._rootDir + '/resources/browser.c')
        bldr.setOutput(self._outputFile)
        bldr.setLibs([
            "std",
            "incbin",
            "webview",
        ])
        bldr.addWarnings(False, [
            "unused-result",
            "discarded-qualifiers",
            "attributes",
            "IID_ICoreWebView2_14"
        ])
        bldr.addFlags([
            f"-D WINDOW_TITLE='{self._title}'",
            f"-D WINDOW_WIDTH={self._width}",
            f"-D WINDOW_HEIGHT={self._height}",
            f"-D WINDOW_RESIZABLE={1 if self._resizable else 0}",
        ])
        bldr.start()
        tools.enable_print()
        #
        files.delete("temporary.html")
        self._print("pack excutable succeeded!")
        return self


