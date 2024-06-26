import os
import subprocess
import yaml
from pathlib import Path
from builder_base import MyBuilderBase
from tools import py, files, tools
from constants import KEYS, TYPES

MY_RC_FILE_TEMPLATE = """
id ICON "%s"
"""

class MyCBuilder(MyBuilderBase):

    def __init__(self, *args):
        super().__init__("C", *args)
        self._includeDirs = []
        self._linkingDirs = []
        self._linkingTags = []
        self._extraFlags = []
        self._targetExecutable = None
        self.MY_RES_FILE_PATH = self._buildDir + ".lcb_resource.res"
        self.MY_RC_FILE_PATH = self._buildDir + ".lcb_resource.rc"
        files.write(self.MY_RES_FILE_PATH, "")
        files.write(self.MY_RC_FILE_PATH, "")

    def _initBuilder(self):
        pass

    def _downloadByGit(self, config):
        url = config[KEYS.URL]
        branch = config.get(KEYS.BRANCH, 'master')
        directory = self._libsDir + config[KEYS.NAME] + self._separator
        super()._downloadByGit(url, branch, directory)

    def _downloadByZip(self, config):
        name = config[KEYS.NAME]
        url = config[KEYS.URL]
        directory = self._libsDir + name + self._separator
        super()._downloadByZip(url, directory)

    def _downloadByGzip(self, config):
        name = config[KEYS.NAME]
        url = config[KEYS.URL]
        directory = self._libsDir + name + self._separator
        super()._downloadByGzip(url, directory)

    def _getConfig(self, name):
        with open('../src/origins.yml', 'r') as file:
            configs = yaml.safe_load(file)
        config = configs.get(name)
        self._assert(config is not None, f"lib [{name}] not found")
        if tools.is_windows():
            config.update(config.get(KEYS.WIN, {}))
        elif tools.is_mac():
            config.update(config.get(KEYS.MAC, {}))
        elif tools.is_linux():
            config.update(config.get(KEYS.LNX, {}))
        return config

    def _installLib(self, name):
        config = self._getConfig(name)
        self._assert(config is not None, f"lib [{name}] not found")
        parts = config[KEYS.URL].split(".")
        config[KEYS.EXT] = parts[-1].upper()
        config[KEYS.TYPE] = config[KEYS.EXT]
        config[KEYS.NAME] = name

        if config[KEYS.TYPE] == TYPES.GIT:
            self._downloadByGit(config)
        elif config[KEYS.TYPE] == TYPES.ZIP:
            self._downloadByZip(config)
        elif config[KEYS.TYPE] == TYPES.GZ:
            self._downloadByGzip(config)
        else:
            self._error(f"invalid lib type [{config[KEYS.TYPE]}]")

    def _containLib(self, name):
        config = self._getConfig(name)
        directory = self._libsDir + name + self._separator
        self._assert(config is not None, f"lib [{name}] not found")
        self._assert(files.is_folder(directory), f"lib [{name}] not installed")

        def insertInclude(dir):
            dir = directory + dir
            self._assert(files.is_folder(dir), f"include directory [{dir}] not found")
            self._includeDirs.append(dir)

        if py.is_string(config[KEYS.DIR_I]):
            insertInclude(config[KEYS.DIR_I])
        elif isinstance(config[KEYS.DIR_I], list):
            for v in config[KEYS.DIR_I]:
                insertInclude(v)

        def insertLinking(dir):
            dir = directory + dir
            self._assert(files.is_folder(dir), f"linking directory [{dir}] not found")
            self._linkingDirs.append(dir)

        if py.is_string(config[KEYS.DIR_L]):
            insertLinking(config[KEYS.DIR_L])
        elif isinstance(config[KEYS.DIR_L], list):
            for v in config[KEYS.DIR_L]:
                insertLinking(v)

        def insertTags(tag):
            self._linkingTags.append(tag)

        if py.is_string(config[KEYS.LIB_L]):
            insertTags(config[KEYS.LIB_L])
        elif isinstance(config[KEYS.LIB_L], list):
            for v in config[KEYS.LIB_L]:
                insertTags(v)

        if py.is_string(config[KEYS.FLAGS]):
            self._extraFlags.append(config[KEYS.FLAGS])

    def _containFiles(self, name):
        config = self._getConfig(name)
        self._assert(config is not None, f"lib [{name}] not found")
        directory = self._libsDir + name + self._separator
        arr = config.get(KEYS.FILES, [])

        for v in arr:
            path = v
            if not files.is_file(path):
                path = directory + config[KEYS.DIR_I] + v
            self._assert(files.is_file(path), f"input file not found: {v}")
            self._inputNames.append(v)
            self._inputFiles.append(path)

    def setLibs(self, *args):
        self._print('CONTAIN LIB START!')
        libs = list(args)
        if isinstance(libs[0], list):
            libs = libs[0]
        for lib in libs:
            self._print(f"contain:[{lib}]")
            self._installLib(lib)
            self._containLib(lib)
            self._containFiles(lib)
        self._print('CONTAIN LIB END!')
        return self

    def setIcon(self, iconPath):
        self._print('SET ICON START!')
        self._print('icon:', iconPath)
        if not tools.is_windows():
            self._print('SET ICON IGNORED!')
            return
        iconPath = self._projDir + iconPath
        myRcInfo = MY_RC_FILE_TEMPLATE % iconPath
        files.write(self.MY_RC_FILE_PATH, myRcInfo)
        command = f"windres {self.MY_RC_FILE_PATH} -O coff -o {self.MY_RES_FILE_PATH}"
        isOk, err = tools.execute(command)
        self._assert(isOk, f"resource compile failed, err: {str(err)}")
        self._print('SET ICON END!')
        return self

    def setOutput(self, path):
        super().setOutput(path)
        self._targetExecutable = f"{str(self._outputFile)}.exe" if tools.is_windows() else str(self._outputFile)
        return self

    def _processBuild(self):
        self._print('PROCESS GCC START!')
        self._assert(self._inputFiles[0] is not None, 'input files are not defined!')
        self._assert(self._outputFile is not None, 'output file is not defined!')

        includeDirCmd = ' '.join([f"-I {v}" for v in self._includeDirs])
        linkingDirCmd = ' '.join([f"-L {v}" for v in self._linkingDirs])
        linkingTagCmd = ' '.join([f"-l {v}" for v in self._linkingTags])
        extraFlagsCmd = ' '.join(self._extraFlags)

        resCmds = self.MY_RES_FILE_PATH if tools.is_windows() else ''
        icludeCmds = includeDirCmd
        linkCmds = f"{linkingDirCmd} {linkingTagCmd}"

        inputFiles = ' '.join(self._inputFiles)

        cc = 'gcc' if tools.is_windows() else 'clang'
        cmd = f"{cc} {inputFiles} -o {self._targetExecutable} {resCmds} {icludeCmds} {linkCmds} {extraFlagsCmd}"

        if self._isRelease:
            cmd += ' -O2 -mwindows'

        if self._isDebug:
            self._print(f"cmd:{cmd}")

        isOk, output = tools.execute(cmd)
        if not isOk:
            self._print('gcc process failed!')
            self._error(f"err:{output}")

        self._print('gcc process succeeded!')

        files.delete(self.MY_RES_FILE_PATH)
        files.delete(self.MY_RC_FILE_PATH)

        self._print('PROCESS GCC END!')

        return self

    def run(self, path=None):
        path = self._projDir + path if path else self._targetExecutable
        dir, name, _, nameWithExt = tools.parse_path(path)
        self._print(f"RUNNING:{path}")
        nam = nameWithExt if tools.is_windows() else name
        exe = f".{self._separator}{nam}"
        cmd = f"cmd cd {dir} ; {exe}"
        if self._isDebug:
            self._print(f"cmd:{cmd}")
        isOk, extra = tools.spawn(exe, [], cwd=dir)
        self._print(f"RUNNED:{isOk}", "" if isOk else extra)


