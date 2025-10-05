if you want to repair,

Boot into a disk for the windows OS you are using, go to repair your pc, and drop into a command line
```powershell
bootrec /Fixmbr
bootrec /RebuildBcd
```
And then boot into the OS. 
