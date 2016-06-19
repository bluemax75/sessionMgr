# sessionMgr
Session Manager for simple window managers like openbox

Written to learn Nim language and get an app to poweroff, reboot, suspendor hibernate from openbox.

It's based on Oblogout (https://launchpad.net/oblogout)
It's in its early stages and configurable in the code ;)

To build (just for the brave):
- Get Nim compiler (https://github.com/nim-lang/Nim).
- Build with: 
  - Using the compiler directly: nim c -d:release
  - Using the package manager: nimble build

Needs to changes to the gtk2 wrapper to support Alpha channel and fullscreen windows.
