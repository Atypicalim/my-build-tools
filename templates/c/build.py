import os
import subprocess


import sys
sys.path.append('../../')

from builder import C

bldr1 = C()
bldr1.setInput('./client.c')
bldr1.setLibs("dyad")
bldr1.setOutput('client')
bldr1.start()

bldr2 = C()
bldr2.setInput('./server.c')
bldr2.setLibs("dyad")
bldr2.setOutput('server')
bldr2.start()

server_path = os.path.join(os.path.dirname(__file__), "server.exe")
client_path = os.path.join(os.path.dirname(__file__), "client.exe")

subprocess.Popen(["start", server_path], shell=True)
subprocess.Popen(["start", client_path], shell=True)

