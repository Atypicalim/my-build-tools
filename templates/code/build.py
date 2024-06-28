
import sys
sys.path.append('../../')

from builder import Code

bldr = Code()

bldr.setInput("./origin.code", "./other.code")
bldr.setComment("//")
bldr.setOutput("./target.code")

# a line with unhandled macro
bldr.onMacro(lambda code, command, argument: "// ALPHABETS ..." if command == "ALPHABETS" else None)
# a line without any macro
bldr.onLine(lambda line: line)

bldr.start()

