import 
  glib2, gtk2, gdk2, os, cairo
import
  logging, strutils

# TODO Centrar botones
# TODO Dialogo de Confirmación

proc destroy(widget: PWidget, data: Pgpointer){.cdecl.} =
  debug("Exiting")
  main_quit()

proc keypressed(w: PWidget, event: PEventKey): bool {.cdecl.} =
  ## If not cursor or enter destroy window
  if event.keyval notin [65361, 65363, 65293]:
      destroy(w)
  # To stop event propagation return true
  return false

var log = newConsoleLogger(fmtStr = verboseFmtStr)
addHandler(log)

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

proc poweroffExec(w: PWidget) {.cdecl.} =
  debug("Executing [$1]" % [poweroffCmd])
  discard os.execShellCmd(poweroffCmd)
  destroy(w)

proc rebootExec(w: PWidget) {.cdecl.} =
  debug("Executing [$1]" % [rebootCmd])
  discard os.execShellCmd(rebootCmd)
  destroy(w)

proc suspendExec(w: PWidget) {.cdecl.} =
  debug("Executing [$1]" % [suspendCmd])
  discard os.execShellCmd(suspendCmd)
  destroy(w)

proc hibernateExec(w: PWidget) {.cdecl.} =
  discard os.execShellCmd(hibernateCmd)
  destroy(w)


proc expose_proc(widget: PWidget, event: PEventExpose): gboolean {.cdecl.} =
  let cr: PContext = widget.window.cairo_create()

  cr.set_source_rgba(0, 0, 0, 0.6)
  # Must apply this operator to use compositing (not shure why)
  cr.set_operator(OPERATOR_SOURCE)
  cr.paint()
  cr.destroy
  result=false

type
  sessionMgrWindow* = object
    window: gtk2.PWindow
    hbox: gtk2.PHBox
    panel: gtk2.PHButtonBox
    poweroff_button: gtk2.PButton
    reboot_button: gtk2.PButton
    suspend_button: gtk2.PButton
    hibernate_button: gtk2.PButton

proc newSessionMgrWindow*(): sessionMgrWindow =
  proc image_button_new(fname: string): PButton =
    ## Helper constructor of button with images
    var image = image_new_from_file(fname)
    result = button_new()
    result.set_relief(RELIEF_NONE)
    result.set_border_width(0)
    result.add(image)
    
  result = sessionMgrWindow()

  result.window = window_new(gtk2.WINDOW_TOPLEVEL)
  result.window.set_app_paintable(true) # Needed to paint directly on the window instead of using a drawing_area
  result.window.set_position(gtk2.WIN_POS_CENTER)
  #window.set_resizable(false)
  result.window.set_decorated(false)
  # Through this event we paint the transparent window
  discard signal_connect(result.window, "expose-event", SIGNAL_FUNC(expose_proc), nil)
  #window.set_border_width(5)
  # To use compositing we must get rgba colormap from screen
  let screen = result.window.get_screen()
  let colorm = screen.get_rgba_colormap()
  result.window.set_colormap(colorm)

  result.poweroff_button = image_button_new("data/system-shutdown.png")
  result.reboot_button = image_button_new("data/system-reboot.png")
  result.suspend_button = image_button_new("data/system-suspend.png")
  result.hibernate_button = image_button_new("data/system-suspend-hibernate.png")

  result.panel = hbutton_box_new()
  result.panel.add(result.poweroff_button)
  result.panel.add(result.reboot_button)
  result.panel.add(result.suspend_button)
  result.panel.add(result.hibernate_button)

  result.hbox = hbox_new(true, 0)
  result.hbox.add(vbox_new(true, 0))
  result.hbox.add(result.panel)
  result.hbox.add(vbox_new(true, 0))

  result.window.add(result.hbox)
  result.window.fullscreen()

  discard signal_connect(result.window, "destroy",
                         SIGNAL_FUNC(sessionMgr.destroy), nil)
  discard signal_connect(result.window, "key_press_event",
                         SIGNAL_FUNC(sessionMgr.keypressed), nil)
  # Al perder el foco cerrar la ventana
  discard signal_connect_object(result.window, "focus-out-event",
                                SIGNAL_FUNC(sessionMgr.destroy), nil)

  discard signal_connect_object(result.poweroff_button, "clicked",
                                SIGNAL_FUNC(poweroffExec),
                                result.window)
  discard signal_connect_object(result.reboot_button, "clicked",
                                SIGNAL_FUNC(rebootExec),
                                result.window)
  discard signal_connect_object(result.suspend_button, "clicked",
                                SIGNAL_FUNC(suspendExec),
                                result.window)
  discard signal_connect_object(result.hibernate_button, "clicked",
                                SIGNAL_FUNC(hibernateExec),
                                result.window)

proc show*(sessionmgr_window: sessionMgrWindow) =
  show_all(sessionmgr_window.window)

nim_init()
let session_window = newSessionMgrWindow()
session_window.show()
main()
  

