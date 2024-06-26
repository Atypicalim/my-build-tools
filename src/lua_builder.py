import os
import subprocess
from constants import KEYS, TYPES
from tools import js, files, tools
from builder_base import MyBuilderBase

class MyLuaBuilder(MyBuilderBase):

    def __init__(self, *args):
        super().__init__("lua", *args)
        self._target_executable = None

    def set_output(self, path):
        super().set_output(path)
        self._target_executable = f"{self._output_file}.exe" if tools.is_windows() else f"{self._output_file}"
        return self

    def _process_build(self):
        self._print('PROCESS PACKAGE START!')
        self._assert(self._input_files[0] is not None, "input files are not defined!")
        self._assert(self._output_file is not None, "output file is not defined!")
        # https://web.archive.org/web/20130721014948if_/http://www.soongsoft.com/lhf/lua/5.1/srlua.tgz
        glue = os.path.join(self._root_dir, "resources/srlua/glue.exe")
        srlua = os.path.join(self._root_dir, "resources/srlua/srlua.exe")
        inputs = " ".join(self._input_files)
        self._print('packaging...')
        cmd = f"{glue} {srlua} {inputs} {self._output_file}.exe"
        if self._is_debug:
            self._print(f"cmd:{cmd}")
        is_ok, output = tools.execute(cmd)
        if not is_ok:
            self._print("package process failed!")
            self._error(f"err:{output}")
        self._print('PROCESS PACKAGE END!')
        return self

    def run(self, path=None):
        path = os.path.join(self._proj_dir, path) if path else self._target_executable
        self._print(f"RUNNING:{path}")
        tools.spawn(path)

if __name__ == "__main__":
    builder = MyLuaBuilder()
    builder.set_output("output_path")
    builder._process_build()
    builder.run()


