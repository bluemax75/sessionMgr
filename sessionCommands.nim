import os
import logging, strutils
import gtk2

const power_api = "dbus_login"
info("Using [$1] power API" % [power_api])
when power_api=="systemd":
    const poweroffCmd = "systemctl poweroff"
    const rebootCmd = "systemctl reboot"
    const suspendCmd = "systemctl suspend"
    const hibernateCmd = "systemctl hibernate"
elif power_api=="dbus_login":
    const poweroffCmd = "dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 \"org.freedesktop.login1.Manager.PowerOff\" boolean:true"
    const rebootCmd = "dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 \"org.freedesktop.login1.Manager.Reboot\" boolean:true"
    const suspendCmd = "dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 \"org.freedesktop.login1.Manager.Suspend\" boolean:true"
    const hibernateCmd = "dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 \"org.freedesktop.login1.Manager.Hibernate\" boolean:true"
else:
    echo "No valid power API"
    quit(1)

proc poweroffExec*(w: PWidget) {.cdecl.} =
  debug("Executing [$1]" % [poweroffCmd])
  discard os.execShellCmd(poweroffCmd)
  destroy(w)

proc rebootExec*(w: PWidget) {.cdecl.} =
  debug("Executing [$1]" % [rebootCmd])
  discard os.execShellCmd(rebootCmd)
  destroy(w)

proc suspendExec*(w: PWidget) {.cdecl.} =
  debug("Executing [$1]" % [suspendCmd])
  discard os.execShellCmd(suspendCmd)
  destroy(w)

proc hibernateExec*(w: PWidget) {.cdecl.} =
  discard os.execShellCmd(hibernateCmd)
  destroy(w)

