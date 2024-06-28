import os
import subprocess

from tools import *
from builder_base import *

class MyLuaBuilder(MyBuilderBase):

    def __init__(self, args={}):
        super().__init__("lua")
        self._targetExecutable = None
        self._parse(args)

    def setOutput(self, path):
        super().setOutput(path)
        self._targetExecutable = f"{self._outputFile}.exe" if tools.is_windows() else f"{self._outputFile}"
        return self

    def _processBuild(self):
        self._print('PROCESS PACKAGE START!')
        self._assert(self._inputFiles[0] is not None, "input files are not defined!")
        self._assert(self._outputFile is not None, "output file is not defined!")
        # https://web.archive.org/web/20130721014948if_/http://www.soongsoft.com/lhf/lua/5.1/srlua.tgz
        glue = os.path.join(self._rootDir, "resources/srlua/glue.exe")
        srlua = os.path.join(self._rootDir, "resources/srlua/srlua.exe")
        inputs = " ".join(self._inputFiles)
        self._print('packaging...')
        cmd = f"{glue} {srlua} {inputs} {self._outputFile}.exe"
        if self._isDebug:
            self._print(f"cmd:{cmd}")
        isOk, output = tools.execute(cmd)
        if not isOk:
            self._print("package process failed!")
            self._error(f"err:{output}")
        self._print('PROCESS PACKAGE END!')
        return self

    def run(self, path=None):
        path = os.path.join(self._projDir, path) if path else self._targetExecutable
        self._print(f"RUNNING:{path}")
        tools.spawn(path)
