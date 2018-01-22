# Install a printer on Linux

If `system-config-printer` does not work, you will need to do it via CUPS
web interface. Go to http://localhost:631/admin, click on "Add printer". It
will ask for a username and password. Try "root" and your "root" password.
If is does not work, then edit the file "/etc/cups/cupsd.conf".
Instead of "Basic", put "None" at "DefaultAuthType". Also remove every
line containing "@SYSTEM". Restart CUPS with `sudo service cups restart`.
Go again on the web interface, click on "Add printer".

Download your printer's driver at www.support.xerox.com by choosing the
Generic PPD. It's an executable file (.exe) that you can open with
your archive manager on Linux. Extract the PPD file and use it in CUPS.

Should be good now, except it's considered a generic printer and will
mess up your with your fonts. Great.

---

- https://www.linuxquestions.org/questions/linux-software-2/cups-username-and-password-156986/
- http://forum.support.xerox.com/t5/Printing/CUPS-Driver-PPD-file-for-Xerox-3345-WorkCentre-printer-for-Linux/td-p/203672
- https://github.com/zdohnal/system-config-printer/issues/36

