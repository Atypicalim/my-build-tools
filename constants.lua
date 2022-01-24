--[[
    constants
]]

MY_PRINT_TAG = "[LUA_C_BUILDER]:"
MY_LIBRARY_PATH = "./.builder/"
GIT_NEED_PULL = false
PURE_LUA_TOOLS = "git@github.com:kompasim/pure-lua-tools.git"

KEYS = {
    NAME = "NAME",
    TYPE = "TYPE",
    URL = "URL",
    EXT = "EXT",
    BRANCH = "BRANCH",
    DIR_I = "DIR_I", -- -I
    DIR_L = "DIR_L", -- -L
    LIB_L = "LIB_L", -- -l
}
TYPES = {
    GIT = "GIT",
    ZIP = "ZIP",
}
