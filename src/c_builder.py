import os
import subprocess
import yaml
from pathlib import Path

from tools import *
from builder_base import *

MY_RC_FILE_TEMPLATE = """
id ICON "%s"
"""

class MyCBuilder(MyBuilderBase):

    def __init__(self, args={}):
        super().__init__("C")
        self._resetLibs()
        self._targetExecutable = None
        self._hasIcon = False
        self._gccWarns = {}
        self._gccFlags = []
        self.MY_RES_FILE_PATH = tools.append_path(self._buildDir, ".lcb_resource.res")
        self.MY_RC_FILE_PATH = tools.append_path(self._buildDir, ".lcb_resource.rc")
        self.MY_RES_FILE_PATH = self.MY_RES_FILE_PATH.replace('\\', tools.get_separator())
        self.MY_RC_FILE_PATH = self.MY_RC_FILE_PATH.replace('\\', tools.get_separator())
        files.write(self.MY_RES_FILE_PATH, "", 'utf-8')
        files.write(self.MY_RC_FILE_PATH, "", 'utf-8')
        self._parse(args)

    def _resetLibs(self):
        self._print(f"RESET LIBS:")
        self._includeDirs = []
        self._linkingDirs = []
        self._linkingTags = []
        self._extraFlags = []

    def _downloadByGit(self, config):
        url = config[KEYS.URL]
        branch = config.get(KEYS.BRANCH, 'master')
        directory = tools.append_path(self._libsDir, config[KEYS.NAME]) + self._separator
        super()._downloadByGit(url, branch, directory)

    def _downloadByZip(self, config):
        name = config[KEYS.NAME]
        url = config[KEYS.URL]
        directory = tools.append_path(self._libsDir, name) + self._separator
        super()._downloadByZip(url, directory)

    def _downloadByGzip(self, config):
        name = config[KEYS.NAME]
        url = config[KEYS.URL]
        directory = tools.append_path(self._libsDir, name) + self._separator
        super()._downloadByGzip(url, directory)

    def _getConfig(self, name):
        with open(Globals.originsPath, 'r') as file:
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
        directory = tools.append_path(self._libsDir, name) + self._separator
        self._assert(config is not None, f"lib [{name}] not found")
        self._assert(files.is_folder(directory), f"lib [{name}] not installed")

        def insertInclude(dir):
            dir = tools.append_path(directory, dir)
            self._assert(files.is_folder(dir), f"include directory [{dir}] not found")
            self._includeDirs.append(dir)

        def insertLinking(dir):
            dir = tools.append_path(directory, dir)
            self._assert(files.is_folder(dir), f"linking directory [{dir}] not found")
            self._linkingDirs.append(dir)


        dirIncContent = config.get(KEYS.DIR_I)
        dirLibContent = config.get(KEYS.DIR_L)
        libContent = config.get(KEYS.LIB_L)
        flagContent = config.get(KEYS.FLAGS)

        if py.is_string(dirIncContent):
            insertInclude(dirIncContent)
        elif py.is_array(dirIncContent):
            for v in dirIncContent:
                insertInclude(v)

        if py.is_string(dirLibContent):
            insertLinking(dirLibContent)
        elif py.is_array(dirLibContent):
            for v in dirLibContent:
                insertLinking(v)

        if py.is_string(libContent):
            self._linkingTags.append(libContent)
        elif py.is_array(libContent):
            for v in libContent:
                self._linkingTags.append(v)

        if py.is_string(flagContent):
            self._extraFlags.append(flagContent)
        elif py.is_array(flagContent):
            for v in flagContent:
                self._extraFlags.append(v)

    def setLibs(self, *args):
        self._print(f"SET LIBS:")
        libs = list(args)
        if isinstance(libs[0], list):
            libs = libs[0]
        for lib in libs:
            self.addLib(lib)
        return self
    
    def addLibs(self, *args):
        self._print(f"ADD LIBS:")
        libs = list(args)
        if isinstance(libs[0], list):
            libs = libs[0]
        for lib in libs:
            self.addLib(lib)
        return self
    
    def addLib(self, name):
        self._print(f"ADD LIB:[{name}]")
        self._installLib(name)
        self._containLib(name)
        path = tools.append_path(self._libsDir, name)
        return path

    def setIcon(self, iconPath):
        self._print('SET ICON START!')
        self._print('icon:', iconPath)
        if not tools.is_windows():
            self._print('SET ICON IGNORED!')
            return
        iconPath = tools.append_path(self._projDir, iconPath)
        iconPath = iconPath.replace('\\', tools.get_separator())
        myRcInfo = MY_RC_FILE_TEMPLATE % iconPath
        files.write(self.MY_RC_FILE_PATH, myRcInfo, 'utf-8')
        command = f"windres {self.MY_RC_FILE_PATH} -O coff -o {self.MY_RES_FILE_PATH}"
        isOk, err = tools.execute(command)
        self._assert(isOk, f"resource compile failed, err: {str(err)}")
        self._print('SET ICON END!')
        self._hasIcon = True
        return self

    def setOutput(self, path):
        super().setOutput(path)
        self._targetExecutable = f"{str(self._outputFile)}.exe" if tools.is_windows() else str(self._outputFile)
        return self
    
    def addWarnings(self, isEnable, *args):
        self._print('ADD WARNINGS!')
        warnings = list(args)
        if isinstance(warnings[0], list):
            warnings = warnings[0]
        for warn in warnings:
            self._print(f"awrning:[{isEnable}][{warn}]")
            self._gccWarns[warn] = isEnable


    def addFlags(self, *args):
        self._print('ADD FLAGS!')
        flags = list(args)
        if isinstance(flags[0], list):
            flags = flags[0]
        for flag in flags:
            self._print(f"flags:[{flag}]")
            self._gccFlags.append(flag)


    def _processBuild(self):
        self._print('PROCESS GCC START!')
        self._assert(self._inputFiles[0] is not None, 'input files are not defined!')
        self._assert(self._outputFile is not None, 'output file is not defined!')
        #
        includeDirCmd = ' '.join([f"-I {v}" for v in self._includeDirs])
        linkingDirCmd = ' '.join([f"-L {v}" for v in self._linkingDirs])
        linkingTagCmd = ' '.join([f"-l {v}" for v in self._linkingTags])
        extraFlagsCmd = ' '.join(self._extraFlags)
        configCmds = f"{linkingTagCmd} {extraFlagsCmd} {includeDirCmd} {linkingDirCmd}".strip()

        #
        warnEnabled = []
        warnDisabled = []
        for key, value in self._gccWarns.items():
            if value == True:
                warnEnabled.append(key)
            elif value == False:
                warnDisabled.append(key)
        warnEnabled = ' '.join(["-W" + item for item in warnEnabled])
        warnDisabled = ' '.join(["-Wno-" + item for item in warnDisabled])
        flagsAdded = ' '.join(self._gccFlags)
        customCmds = f"{warnEnabled} {warnDisabled} {flagsAdded}".strip()
        #
        inputFiles = ' '.join(self._inputFiles)
        resCmds = self.MY_RES_FILE_PATH if self._hasIcon else ''
        #
        cc = 'gcc' if tools.is_windows() else 'clang'
        cmd = f"{cc} -o {self._targetExecutable} "
        cmd += f"-O2 -mwindows " if self._isRelease else "" # -Wall -Wextra -pedantic
        cmd += f"-s {inputFiles} {resCmds} "
        cmd += f"-s {customCmds} {configCmds} "
        cmd = ' '.join(cmd.split())

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
        isOk, extra = tools.spawn(self._targetExecutable, [], cwd=dir)
        self._print(f"RUNNED:{isOk}", "" if isOk else extra)


