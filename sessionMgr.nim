import logging
var log = newConsoleLogger(levelThreshold = lvlDebug, fmtStr = verboseFmtStr)
addHandler(log)

import os, gtk2, strutils
import sessionMgrWindow


import docopt
let doc = """Session Management gui (poweroff, reboot, suspend and hibernate

Usage: sessionMgr [--use-dbus-login] [--data-dir=<data-dir>]

Options:
  -h --help             Show this help
  --use-dbus-login      Use DBus login interface instead of systemd
  --data-dir=<data-dir> Location of the icons
"""

var power_api = "systemd"
let args = docopt(doc)
if args["--use-dbus-login"]:
  power_api = "dbus_login"

var data_dir = os.splitPath(os.expandSymlink("/proc/self/exe"))[0]
if args["--data-dir"]:
  data_dir = $args["--data-dir"]
debug("Using data_dir [$1]" % [data_dir])



nim_init()
let session_window = newSessionMgrWindow(power_api, data_dir)
session_window.show()
main()
  

