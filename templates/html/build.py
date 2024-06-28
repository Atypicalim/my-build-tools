
import sys
sys.path.append('../../')

from builder import Html

bldr = Html()
bldr.setDebug(True)
bldr.setInput("./test.html")
bldr.containScript()
bldr.containStyle()
bldr.containImage()
bldr.setOutput("./target.html")
bldr.start()

