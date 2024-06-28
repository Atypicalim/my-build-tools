# constant

import os

class Globals:
    pass

Globals.createFunc = None
Globals.originsPath = os.path.join(os.path.dirname(__file__), "origins.yml")

class KEYS:
    NAME = "NAME"
    TYPE = "TYPE"
    URL = "URL"
    EXT = "EXT"
    BRANCH = "BRANCH"
    DIR_I = "DIR_I"  # -I
    DIR_L = "DIR_L"  # -L
    LIB_L = "LIB_L"  # -l
    FLAGS = "FLAGS"  # flags
    FILES = "FILES"  # include source files in lib
    WIN = "WIN"
    LNX = "LNX"
    MAC = "MAC"
    pass


class TYPES:
    GIT = "GIT"
    ZIP = "ZIP"
    GZ = "GZ"
    pass
