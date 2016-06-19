import 
  glib2, gtk2, gdk2, os, cairo
import
  logging, strutils
import sessionMgrWindow


var log = newConsoleLogger(fmtStr = verboseFmtStr)
addHandler(log)

nim_init()
let session_window = newSessionMgrWindow()
session_window.show()
main()
  

