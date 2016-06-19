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

nim_init()

proc expose_proc(widget: PWidget, event: PEventExpose): gboolean {.cdecl.} =
  let cr: PContext = widget.window.cairo_create()

  cr.set_source_rgba(0, 0, 0, 0.6)
  # Must apply this operator to use compositing (not shure why)
  cr.set_operator(OPERATOR_SOURCE)
  cr.paint()
  cr.destroy
  result=false

var window = window_new(gtk2.WINDOW_TOPLEVEL)
window.set_app_paintable(true) # Needed to paint directly on the window instead of using a drawing_area
window.set_position(gtk2.WIN_POS_CENTER)
#window.set_resizable(false)
window.set_decorated(false)
# Through this event we paint the transparent window
discard signal_connect(window, "expose-event", SIGNAL_FUNC(expose_proc), nil)
#window.set_border_width(5)
# To use compositing we must get rgba colormap from screen
let screen = window.get_screen()
let colorm = screen.get_rgba_colormap()
window.set_colormap(colorm)

proc image_button_new(fname: string): PButton =
  ## Helper constructor of button with images
  var image = image_new_from_file(fname)
  result = button_new()
  result.set_relief(RELIEF_NONE)
  result.set_border_width(0)
  result.add(image)

var poweroff_button = image_button_new("system-shutdown.png")
var reboot_button = image_button_new("system-reboot.png")
var suspend_button = image_button_new("system-suspend.png")
var hibernate_button = image_button_new("system-suspend-hibernate.png")

var panel = hbutton_box_new()
panel.add(poweroff_button)
panel.add(reboot_button)
panel.add(suspend_button)
panel.add(hibernate_button)

var hbox = hbox_new(true, 0)
hbox.add(vbox_new(true, 0))
hbox.add(panel)
hbox.add(vbox_new(true, 0))

window.add(hbox)
window.fullscreen()

discard signal_connect(window, "destroy",
                       SIGNAL_FUNC(sessionMgr.destroy), nil)
discard signal_connect(window, "key_press_event",
                       SIGNAL_FUNC(sessionMgr.keypressed), nil)
# Al perder el foco cerrar la ventana
discard signal_connect_object(window, "focus-out-event",
                              SIGNAL_FUNC(sessionMgr.destroy), nil)

discard signal_connect_object(poweroff_button, "clicked",
                              SIGNAL_FUNC(poweroffExec),
                              window)
discard signal_connect_object(reboot_button, "clicked",
                              SIGNAL_FUNC(rebootExec),
                              window)
discard signal_connect_object(suspend_button, "clicked",
                              SIGNAL_FUNC(suspendExec),
                              window)
discard signal_connect_object(hibernate_button, "clicked",
                              SIGNAL_FUNC(hibernateExec),
                              window)



show_all(window)
main()
