import os
import logging, strutils
import gtk2
import tables

var power_api* = "dbus_login"

var systemd_cmds = toTable([("poweroff","systemctl poweroff"),
      ("reboot", "systemctl reboot"), ("suspend","systemctl suspend"),
      ("hibernate", "systemctl hibernate")])
var dbus_cmds = toTable([("poweroff","dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 \"org.freedesktop.login1.Manager.PowerOff\" boolean:true"),
      ("reboot","dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 \"org.freedesktop.login1.Manager.Reboot\" boolean:true"),
      ("suspend","dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 \"org.freedesktop.login1.Manager.Suspend\" boolean:true"),
      ("hibernate","dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 \"org.freedesktop.login1.Manager.Hibernate\" boolean:true")])
var cmds = toTable([("systemd", systemd_cmds), ("dbus_login", dbus_cmds)])

proc poweroffExec*(w: PWidget) {.cdecl.} =
  let cmd = cmds[power_api]["poweroff"]
  info("Poweroff")
  debug("Executing [$1]" % [cmd])
  discard os.execShellCmd(cmd)
  destroy(w)

proc rebootExec*(w: PWidget) {.cdecl.} =
  let cmd = cmds[power_api]["reboot"]
  info("Reboot")
  debug("Executing [$1]" % [cmd])
  discard os.execShellCmd(cmd)
  destroy(w)

proc suspendExec*(w: PWidget) {.cdecl.} =
  let cmd = cmds[power_api]["suspend"]
  info("Suspend")
  debug("Executing [$1]" % [cmd])
  discard os.execShellCmd(cmd)
  destroy(w)

proc hibernateExec*(w: PWidget) {.cdecl.} =
  let cmd = cmds[power_api]["hibernate"]
  info("Hibernate")
  debug("Executing [$1]" % [cmd])
  discard os.execShellCmd(cmd)
  destroy(w)

