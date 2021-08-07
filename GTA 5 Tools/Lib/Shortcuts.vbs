Set sh = CreateObject("WScript.Shell")
Set lk = sh.CreateShortcut(wscript.arguments(0)&".lnk")
lk.TargetPath = wscript.arguments(1)
lk.IconLocation = wscript.arguments(2)
lk.Save