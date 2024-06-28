
import sys
sys.path.append('../../')

from builder import Lua

bldr = Lua()
bldr.setInput('./example.lua')
bldr.setOutput("example")
bldr.start()
bldr.run()

