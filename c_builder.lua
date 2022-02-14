--[[
    c
]]

local Base = require("builder_base")

-- include a text file with `containFile("test.txt")` to c, and read with `LCB_FILE("test.txt")` in c code
local MY_CONTAIN_FILE_PATH = "./.lcb_contain_code.c"
local MY_CONTAIN_FILE_TEMPLATE = [[
struct KeyValue
{
    char* key;
    char* value;
};
int size = @@MY_CONTAIN_FILE_COUNT_HOLDER@@;
struct KeyValue keyValues[@@MY_CONTAIN_FILE_COUNT_HOLDER@@] = {
@@MY_CONTAIN_FILE_ITEMS_HOLDER@@
{"xx", "xx"}
};

char *lcbRead(char *name)
{
    for (int i = 0; i < size; i ++) {
        struct KeyValue keyValue = keyValues[i];
        if (strcmp(keyValue.key, name) == 0) return keyValue.value;
    }
    return name;
}
#define LCB_FILE(NAME) lcbRead(NAME)
]]
local MY_CONTAIN_FILE_ITEM_TEMPLATE = [[{"%s", "%s"},]]
local MY_CONTAIN_FILE_ITEMS_HOLDER = [[MY_CONTAIN_FILE_ITEMS_HOLDER]]
local MY_CONTAIN_FILE_COUNT_HOLDER = [[MY_CONTAIN_FILE_COUNT_HOLDER]]

-- add resources such as icon and version info
local MY_RES_FILE_PATH = "./.lcb_resource.res"
local MY_RC_FILE_PATH = "./.lcb_resource.rc"
local MY_RC_FILE_TEMPLATE = [[
id ICON "%s"
]]

KEYS = {
    NAME = "NAME",
    TYPE = "TYPE",
    URL = "URL",
    EXT = "EXT",
    BRANCH = "BRANCH",
    DIR_I = "DIR_I", -- -I
    DIR_L = "DIR_L", -- -L
    LIB_L = "LIB_L", -- -l
    FLAGS = "FLAGS", -- flags
}
TYPES = {
    GIT = "GIT",
    ZIP = "ZIP",
}
require("c_configs")

local Builder, Super = class("Builder", Base)

function Builder:__init__(isDebug)
    Super.__init__(self, "C")
    self._isDebug = isDebug == true
    self._includeDirs = {}
    self._linkingDirs = {}
    self._linkingTags = {}
    self._extraFlags = {}
    self._executableFile = nil
    self._libPath = self._buildDir .. "libs/"
    self:_prepareEnv()
end

function Builder:_prepareEnv()
    Super._prepareEnv(self)
    if not files.is_folder(self._libPath) then
        files.mk_folder(self._libPath)
    end
    files.write(MY_CONTAIN_FILE_PATH, "")
    files.write(MY_RES_FILE_PATH, "")
end

function Builder:_downloadByGit(config)
    local url = config[KEYS.URL]
    local branch = config[KEYS.BRANCH] or 'master'
    local directory = self._libPath .. config[KEYS.NAME] .. "/"
    Super._downloadByGit(self, url, branch, directory)
end

function Builder:_downloadByZip(config)
    local name = config[KEYS.NAME]
    local url = config[KEYS.URL]
    local directory = self._libPath .. name .. "/"
    Super._downloadByZip(self, url, directory)
end

function Builder:_installLib(name)
    local config = CONFIGS[name]
    self:assert(config ~= nil, string.format("lib [%s] not found", name))
    local parts = string.explode(config[KEYS.URL], "%.")
    config[KEYS.EXT] = string.upper(parts[#parts])
    config[KEYS.TYPE] = config[KEYS.EXT]
    config[KEYS.NAME] = name
    if config[KEYS.TYPE] == TYPES.GIT then
        self:_downloadByGit(config)
    elseif config[KEYS.TYPE] == TYPES.ZIP then
        self:_downloadByZip(config)
    else
        self:error(string.format('invalid lib type [%s]', config[KEYS.TYPE]))
    end
end

function Builder:installLibs(...)
    self:print('INSTALL LIB START!')
    local libs = {...}
    for i=1,#libs,1 do
        local lib = libs[i]
        self:print('start:', lib)
        self:_installLib(lib)
        self:print('finish:', lib)
    end
    self:print('INSTALL LIB END!\n')
end

function Builder:_containLib(name)
    local config = CONFIGS[name]
    local directory = self._libPath .. name .. "/"
    self:assert(config ~= nil, string.format("lib [%s] not found", name))
    self:assert(files.is_folder(directory), string.format("lib [%s] not installed", name))
    --
    local function insertInclue(dir)
        dir = directory .. dir
        self:assert(files.is_folder(dir), string.format("include directory [%s] not found", dir))
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
        self:assert(files.is_folder(dir), string.format("linking directory [%s] not found", dir))
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

function Builder:containLibs(...)
    self:print('CONTAIN LIB START!')
    local libs = {...}
    for i=1,#libs,1 do
        local lib = libs[i]
        self:print(string.format("contain:[%s]", lib))
        self:_containLib(lib)
    end
    self:print('CONTAIN LIB END!\n')
end

function Builder:containFile(...)
    self:print('CONTIAN FILE START!')
    local names = {}
    local contents = {}
    for _,name in ipairs({...}) do
        self:assert(files.size(name) > 0, string.format("file [%s] not found!", name))
        table.insert(names, name)
        table.insert(contents, files.read(name))
    end
    local items = nil
    for index,name in ipairs(names) do
        self:print("file:", name)
        local content = contents[index]
        local item = string.format(MY_CONTAIN_FILE_ITEM_TEMPLATE, name, content)
        items = items == nil and item or items .. "\n" .. item
    end
    local code = string.format("// %s contained files:\n\n%s", MY_PRINT_TAG, MY_CONTAIN_FILE_TEMPLATE)
    code = string.gsub(code, string.format( "@@%s@@", MY_CONTAIN_FILE_ITEMS_HOLDER), items)
    code = string.gsub(code, string.format( "@@%s@@", MY_CONTAIN_FILE_COUNT_HOLDER), tostring(#names))
    files.write(MY_CONTAIN_FILE_PATH, code)

    self:print('CONTIAN FILE END!\n')
end

function Builder:containIcon(iconPath)
    self:print('CONTIAN INFO START!')
    self:print('icon:', iconPath)
    local myRcInfo = string.format(MY_RC_FILE_TEMPLATE, iconPath)
    files.write(MY_RC_FILE_PATH, myRcInfo)
    local isOk, err = tools.execute(string.format("windres %s -O coff -o %s", MY_RC_FILE_PATH, MY_RES_FILE_PATH))
    self:assert(isOk, "resource compile failed, err:" .. tostring(err))
    self:print('CONTIAN INFO END!\n')
end

function Builder:compile(mainFile, targetName, isRelease)
    self:print('PROCESS GCC START!')
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
    local target = tools.is_windows() and string.format( "%s.exe", tostring(targetName)) or tostring(targetName)
    local compileCmds = string.format("%s", MY_RES_FILE_PATH)
    --
    local icludeCmds = string.format("-include %s %s", MY_CONTAIN_FILE_PATH, includeDirCmd)
    local linkCmds = string.format("%s %s", linkingDirCmd, linkingTagCmd)
    local cmd = string.format("gcc %s -o %s %s %s %s %s", mainFile, target, compileCmds, icludeCmds, linkCmds, extraFlagsCmd)
    --
    if isRelease then
        cmd = cmd .. " -O2 -mwindows"
    end
    --
    if self._isDebug then
        self:print(string.format("cmd:%s", cmd))
    end
    local isOk, output = tools.execute(cmd)
    if not isOk then
        self:print("gcc process failed!")
        self:error("err:" .. output)
    end
    if files.is_file(target) then
        self._executableFile = "." .. files.delimiter() .. target
    end
    self:print("gcc process succeeded!")
    --
    files.delete(MY_CONTAIN_FILE_PATH)
    files.delete(MY_RES_FILE_PATH)
    files.delete(MY_RC_FILE_PATH)
    self:print('PROCESS GCC END!\n')
end

function Builder:execute(argumentString)
    self:assert(self._executableFile ~= nil, 'executable file not found!')
    argumentString = argumentString or ""
    os.execute(self._executableFile .. argumentString)
end

return Builder