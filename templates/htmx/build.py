import os


import sys
sys.path.append('../../')

from builder import Htmx
from builder import tools

bldr = Htmx()
bldr.setInput('./test.html')
bldr.setTitle("htmx...")
bldr.setIcon('../../resources/test.ico')
bldr.setSize(300, 600)
bldr.setResizable(True)
bldr.setOutput('test')
bldr.setRelease(True)
bldr.start()

tools.spawn("test")
