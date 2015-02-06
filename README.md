# AHK-EXE-Swapper
A Utility to easily manage which version of AutoHotkey that uncompiled scripts use.

<table><tr><td rowspan="2" width="300px">
<img src="https://github.com/ahkscript/AHK-EXE-Swapper/blob/master/screenshot.png"/>
</td><td>
<h3>What?</h3>
This tool allows you to easily manage which *Version* (As in release - such as `1.1.19.011`) of Autohotkey.exe that scripts use.  
It is aware of the *full* version number of EXEs - as in `1.1.19.01-19+ga3104d4`)
It also allows easy swapping in and out of test builds. (Identified by the longer *version* as above)  
Furthermore, duplicates the AHK installer's functionality of swapping *Variants* (ANSI/Unicode, x86/x64).
</td></tr>
<tr><td>
<h3>Why?</h3>
Because whilst editors such as [SciTE4AutoHotkey](https://github.com/fincs/SciTE4AutoHotkey) allow you to choose which EXE to use when you run a script while editing them, there is no easy way to swap out EXE versions beyond the AHK installer, which only swaps *variants*, not *versions* (Apart from upgrading).
</td></tr>
</table>


##How?...
####...Do I get it?
If you are an end-user, simply download AHK-EXE-Swapper.exe from [here](https://github.com/evilC/AHK-EXE-Swapper/blob/master/AHK-EXE-Swapper.exe). You may place it anywhere.
####...Do I use it?
Double click the script to open the GUI.  
This script maintains a *Library* of versions which you have imported or backed up which it stores in the folder *AHK-EXE-Swapper* in your AutoHotkey folder (*C:\Program Files\AutoHotkey*).  

**Library Management**
To add a *Release* version (ie one from the main page of the [AHKScript Website](http://ahkscript.org)) , Install it using the regular AHK Installer and hit *Backup Version* in the script's GUI.  

To add a *Test* version (ie one Lexikos posted in a forum thread), download the zip from the link and place it in the *Import* folder in the *AHK-EXE-Swapper folder*. Then, click *Refresh* in the GUI, select the zip file from the list and click *Import*.  

**Swapping**
To swap *Version* (version number), Select a version from the Library and click *Replace with selected version*
To swap *Variant* (ANSI/Unicode, x86/x64), Click the buttons at the top.

####...Do I alter it?
The obvious caveat for a script like this is "How do you delete AutoHotkey.exe if you are running a script using it?"  
The obvious answer is "Compile the script", but this leaves you with how to debug or work on the script (either without a dubugger, or with) without having to compile it for each run.  
This project includes two methods to circumvent this issue:  
1. When run as uncompiled, the script will check to see if the used AHK EXE is the "Main" exe, and if so will try to copy an "Internal EXE" to a subfolder and relaunch using that. Simple solution for people without debuggers etc.  
2. A `SciTE.properties` file is included with the project which will redirect SciTE to use the "Internal EXE" when running or debugging the script.  
If you run the .ahk version of the script once outside of SciTE, the "Internal EXE" will be put in the correct folder for you. Then simply uncomment the contents of `SciTE.properties` and start debugging!  

