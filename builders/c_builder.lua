--[[
    c
]]

-- add resources such as icon and version info
local MY_RC_FILE_TEMPLATE = [[
id ICON "%s"
]]

MyCBuilder, MyCSuper = class("MyCBuilder", MyBuilderBase)

function MyCBuilder:__init__()
    MyCSuper.__init__(self, "C")
    self._includeDirs = {}
    self._linkingDirs = {}
    self._linkingTags = {}
    self._extraFlags = {}
    self._targetExecutable = nil
    self.MY_RES_FILE_PATH = self._buildDir .. ".lcb_resource.res"
    self.MY_RC_FILE_PATH = self._buildDir .. ".lcb_resource.rc"
    files.write(self.MY_RES_FILE_PATH, "")
    files.write(self.MY_RC_FILE_PATH, "")
end

function MyCBuilder:_downloadByGit(config)
    local url = config[KEYS.URL]
    local branch = config[KEYS.BRANCH] or 'master'
    local directory = self._libsDir .. config[KEYS.NAME] .. "/"
    MyCSuper._downloadByGit(self, url, branch, directory)
end

function MyCBuilder:_downloadByZip(config)
    local name = config[KEYS.NAME]
    local url = config[KEYS.URL]
    local directory = self._libsDir .. name .. "/"
    MyCSuper._downloadByZip(self, url, directory)
end

function MyCBuilder:_downloadByGzip(config)
    local name = config[KEYS.NAME]
    local url = config[KEYS.URL]
    local directory = self._libsDir .. name .. "/"
    MyCSuper._downloadByGzip(self, url, directory)
end

function MyCBuilder:_getConfig(name)
    local config = CONFIGS[name]
    self:_assert(config ~= nil, string.format("lib [%s] not found", name))
    if tools.is_windows() then
        table.merge(config, config[KEYS.WIN] or {})
    elseif tools.is_mac() then
        table.merge(config, config[KEYS.MAC] or {})
    elseif tools.is_linux() then
        table.merge(config, config[KEYS.LNX] or {})
    end
    return config
end

function MyCBuilder:_installLib(name)
    local config = self:_getConfig(name)
    self:_assert(config ~= nil, string.format("lib [%s] not found", name))
    local parts = string.explode(config[KEYS.URL], "%.")
    config[KEYS.EXT] = string.upper(parts[#parts])
    config[KEYS.TYPE] = config[KEYS.EXT]
    config[KEYS.NAME] = name
    if config[KEYS.TYPE] == TYPES.GIT then
        self:_downloadByGit(config)
    elseif config[KEYS.TYPE] == TYPES.ZIP then
        self:_downloadByZip(config)
    elseif config[KEYS.TYPE] == TYPES.GZ then
        self:_downloadByGzip(config)
    else
        self:_error(string.format('invalid lib type [%s]', config[KEYS.TYPE]))
    end
end

function MyCBuilder:_containLib(name)
    local config = self:_getConfig(name)
    local directory = self._libsDir .. name .. "/"
    self:_assert(config ~= nil, string.format("lib [%s] not found", name))
    self:_assert(files.is_folder(directory), string.format("lib [%s] not installed", name))
    --
    local function insertInclue(dir)
        dir = directory .. dir
        self:_assert(files.is_folder(dir), string.format("include directory [%s] not found", dir))
        table.insert(self._includeDirs, dir)
    end
    if is_string(config[KEYS.DIR_I]) then
        insertInclue(config[KEYS.DIR_I])
    elseif is_table(config[KEYS.DIR_I]) then
        for _,v in ipairs(config[KEYS.DIR_I]) do
            insertInclue(v)
        end
    end
    --
    local function insertLinking(dir)
        dir = directory .. dir
        self:_assert(files.is_folder(dir), string.format("linking directory [%s] not found", dir))
        table.insert(self._linkingDirs, dir)
    end
    if is_string(config[KEYS.DIR_L]) then
        insertLinking(config[KEYS.DIR_L])
    elseif is_table(config[KEYS.DIR_L]) then
        for _,v in ipairs(config[KEYS.DIR_L]) do
            insertLinking(v)
        end
    end
    --
    local function insertTags(tag)
        table.insert(self._linkingTags, tag)
    end
    if is_string(config[KEYS.LIB_L]) then
        insertTags(config[KEYS.LIB_L])
    elseif is_table(config[KEYS.LIB_L]) then
        for _,v in ipairs(config[KEYS.LIB_L]) do
            insertTags(v)
        end
    end
    --
    if is_string(config[KEYS.FLAGS]) then
        table.insert(self._extraFlags, config[KEYS.FLAGS])
    end
end

function MyCBuilder:_containFiles(name)
    local config = self:_getConfig(name)
    self:_assert(config ~= nil, string.format("lib [%s] not found", name))
    local directory = self._libsDir .. name .. "/"
    local arr = config[KEYS.FILES] or {}
    for i,v in ipairs(arr) do
        local path = v
        if not files.is_file(path) then
            path = directory .. config[KEYS.DIR_I] .. v
        end
        self:_assert(files.is_file(path), "input file not found:" .. v)
        table.insert(self._inputNames, v)
        table.insert(self._inputFiles, path)
    end
end

function MyCBuilder:setLibs(...)
    self:_print('CONTAIN LIB START!')
    local libs = {...}
    if is_table(libs[1]) then
        libs = libs[1]
    end
    for i=1,#libs,1 do
        local lib = libs[i]
        self:_print(string.format("contain:[%s]", lib))
        self:_installLib(lib)
        self:_containLib(lib)
        self:_containFiles(lib)
    end
    self:_print('CONTAIN LIB END!')
    return self
end

function MyCBuilder:setIcon(iconPath)
    self:_print('SET ICON START!')
    self:_print('icon:', iconPath)
    if not tools.is_windows() then
        self:_print('SET ICON IGNORED!')
        return
    end
    iconPath = self._projDir .. iconPath
    local myRcInfo = string.format(MY_RC_FILE_TEMPLATE, iconPath)
    files.write(self.MY_RC_FILE_PATH, myRcInfo)
    local isOk, err = tools.execute(string.format("windres %s -O coff -o %s", self.MY_RC_FILE_PATH, self.MY_RES_FILE_PATH))
    self:_assert(isOk, "resource compile failed, err:" .. tostring(err))
    self:_print('SET ICON END!')
    return self
end

function MyCBuilder:setOutput(path)
    MyCSuper.setOutput(self, path)
    self._targetExecutable = tools.is_windows() and string.format( "%s.exe", tostring(self._outputFile)) or tostring(self._outputFile)
    return self
end

function MyCBuilder:_processBuild()
    self:_print('PROCESS GCC START!')
    self:_assert(self._inputFiles[1] ~= nil, "input files are not defined!")
    self:_assert(self._outputFile ~= nil, "output file is not defined!")
    --
    local includeDirCmd = ""
    for _,v in ipairs(self._includeDirs) do
        includeDirCmd = includeDirCmd .. " -I " .. v
    end
    --
    local linkingDirCmd = ""
    for _,v in ipairs(self._linkingDirs) do
        linkingDirCmd = linkingDirCmd .. " -L " .. v
    end
    --
    local linkingTagCmd = ""
    for _,v in ipairs(self._linkingTags) do
        linkingTagCmd = linkingTagCmd .. " -l " .. v
    end
    --
    local extraFlagsCmd = ""
    for _,v in ipairs(self._extraFlags) do
        extraFlagsCmd = extraFlagsCmd .. " " .. v
    end
    --
    local resCmds = tools.is_windows() and string.format("%s", self.MY_RES_FILE_PATH) or ""
    --
    local icludeCmds = string.format("%s", includeDirCmd)
    local linkCmds = string.format("%s %s", linkingDirCmd, linkingTagCmd)
    local inputFiles = ""
    for i,v in ipairs(self._inputFiles) do
        inputFiles = inputFiles .. " " .. v
    end
    local cc = tools.is_windows() and "gcc" or "clang"
    local cmd = string.format("%s %s -o %s %s %s %s %s", cc, inputFiles, self._targetExecutable, resCmds, icludeCmds, linkCmds, extraFlagsCmd)
    --
    if self._isRelease then
        cmd = cmd .. " -O2 -mwindows"
    end
    --
    if self._isDebug then
        self:_print(string.format("cmd:%s", cmd))
    end
    local isOk, output = tools.execute(cmd)
    if not isOk then
        self:_print("gcc process failed!")
        self:_error("err:" .. output)
    end
    self:_print("gcc process succeeded!")
    --
    files.delete(self.MY_RES_FILE_PATH)
    files.delete(self.MY_RC_FILE_PATH)
    self:_print('PROCESS GCC END!')
    return self
end

function MyCBuilder:run(path)
    path = path and (self._projDir .. path) or self._targetExecutable
    local _path = Path(path)
    local dir = _path:getDir()
    local nameWithExt, name, ext = _path:getNameWithExt()
    self:_print("RUNNING:" .. _path:get())
    local exe = tools.is_windows() and ".\\" .. nameWithExt or "./" .. name
    local cmd = string.format("cd %s && %s", dir, exe)
    if self._isDebug then
        self:_print("cmd:" .. cmd)
    end
    os.execute(cmd)
end
