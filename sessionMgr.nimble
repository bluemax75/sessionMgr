# Package

version       = "0.1.0"
author        = "charly"
description   = "Session control app for openbox"
license       = "MIT"

# Dependencies

requires "nim >= 0.14.0"
requires "gtk2 >= 1.0"
requires "cairo >= 1.0"
requires "docopt >= 0.6.2"

bin = @["sessionMgr"]
