/*
ToDo:
* More Error Checking

* Test with UAC on (No Admin Mode). Probably does not work.

*/
#NoEnv
#SingleInstance force

;MsgBox % "Starting with " A_AhkPath

MismatchWarning := 0		; Is there a version mismatch between A32/U32/U64 versions and / or AutoHotkey.exe?
CurrentVersion := 0			; Current version of AutoHotkey.exe in Program Files
CurrentVariant := 0			; Current variant of Autohotkey.exe in Program Files
InternalExe := 0			; Path to the internal EXE, or 0 if unavailable

EnvGet, AhkFolder, ProgramW6432
AhkFolder .= "\AutoHotkey"
AhkExe := AhkFolder "\AutoHotkey.exe"
SwapFolder := AhkFolder . "\AHK-EXE-Swapper"
ImportFolder := SwapFolder . "\Import"
VersionFolder := SwapFolder . "\Versions"
GetInternalExe() ; Set InternalExe

if (!A_IsCompiled){
	if (A_AhkPath = AhkExe){
		; Run as un-compiled using normal EXE
		if (InternalExe != 0){
			Run, % InternalExe " " A_ScriptFullPath
			ExitApp
		} else {
			MsgBox % "Cannot run as uncompiled without an Internal Exe. quitting..."
			ExitApp
		}
	}
}

GUI_WIDTH := 300
GROUPBOX_WIDTH := GUI_WIDTH - 10
GUI_HALF_WIDTH := (GUI_WIDTH / 2) - 10
GUI_THIRD_WIDTH := (GUI_WIDTH / 3) - 10

; Current AHK Version
;Gui, Add, Text, w%GUI_WIDTH% Center, Main AHK folder
Gui, Add, GroupBox, xm ym w%GUI_WIDTH% R2 Section Center, Current AutoHotkey.exe 
Gui, Add, Text, xm+10 yp+20 Section, Version: 
Gui, Add, Text, x100 ys w190 hwndhCurrentVersion, 
Gui, Add, Text, xm+10 yp+20 Section, Variant: 
Gui, Add, Text, x100 ys w190 hwndhCurrentVariant,

; Backup versions
Gui, Add, GroupBox, xm yp+30 w%GUI_WIDTH% R2 Section Center, Swap AutoHotkey.exe for different Variant
Gui, Add, Text, xs+5 ys+12 w%GROUPBOX_WIDTH% HwndhMismatchWarning Center R3 Cred Hidden, Warning!`nBackup Versions do not match main AHK Version,`nor files are missing! Variant Swap Disabled.
Gui, Add, Button, xs+5 ys+20 w%GUI_THIRD_WIDTH% Center Section hwndVariantButtonA32 gSwapVariantA32, ANSI 32
Gui, Add, Button, ys w%GUI_THIRD_WIDTH% Center Section gSwapVariantU32 hwndVariantButtonU32, Unicode 32
Gui, Add, Button, ys w%GUI_THIRD_WIDTH% Center gSwapVariantU64 hwndVariantButtonU64, Unicode 64

; Available versions
Gui, Add, Text, xm yp+50 w%GUI_WIDTH% Center, Available Versions for Swapping
Gui, Add, Button, xm w%GUI_WIDTH% Center gBackupVersion, Backup Current Version
Gui, Add, ListView, hwndLVSwapFolder w%GUI_WIDTH% h200 AltSubmit +Grid, Version
LV_ModifyCol(1, 275)	; Try and avoid horiz scrollbar

Gui, Add, Button, xm w%GUI_WIDTH% Center gSwapVersion, Replace with selected version

; Import
Gui, Add, Text, xm yp+40 w%GUI_WIDTH% Center, Import folder - Place test release zips in here
Gui, Add, ListView, hwndLVImportList AltSubmit w%GUI_WIDTH% h100 +Grid, Filename
LV_ModifyCol(1, 275)	; Try and avoid horiz scrollbar
;LV_ModifyCol(2, 95)
Gui, Add, Button, xm w%GUI_WIDTH% Center Section gImportFile, Import selected zip

Gui, Add, Button, xm yp+40 w%GUI_WIDTH% Center gRefresh, Refresh All
;LV_ModifyCol(1, 100)
Gui, Show, ,AHK-EXE-Swapper

; Start Up
CheckCurrentVersion()
BuildSwapList()
BuildImportList()

return

Esc::
	GuiClose:
	ExitApp

ImportFile:
	Gui, ListView, % LVImportList
	LV_GetText(selected_import, LV_GetNext())
	if (selected_import != "filename"){
		ImportFile(selected_import)
	}
	return

Refresh:
	CheckCurrentVersion()
	BuildSwapList()
	BuildImportList()
	return

SwapVersion:
	Gui, ListView, % LVSwapFolder
	LV_GetText(swap_version, LV_GetNext())
	if (swap_version != "version"){
		; ToDo: Why does it default to title row - "version" ?
		SwapVersion(swap_version)
	}
	return

BackupVersion:
	if (BackupVersion()){
		HighBeep()
	} else {
		LowBeep()
	}
	return

SwapVariantA32:
	SwapVariant("A32")
	return
	
SwapVariantU32:
	SwapVariant("U32")
	return

SwapVariantU64:
	SwapVariant("U64")
	return

; Makes a backup copy of the EXE so we can always execute code
GetInternalExe(){
	global AhkExe, AhkFolder, SwapFolder, InternalExe
	internal_folder := SwapFolder "\Internal Exe"
	if (!FileExist(internal_folder)){
		FileCreateDir, % internal_folder
	}
	internal_exe := internal_folder "\AutoHotkey.exe"
	If (!FileExist(internal_exe)){
		; We do not have an Internal EXE
		if (FileExist(AhkExe)){
			FileCopy, % AhkExe, % internal_folder
			; Set global var
		} else {
			if(!A_IsCompiled && (A_AhkPath = AhkExe)){
				; Running uncompiled and using main EXE - exit
				MsgBox % "Cannot acquire Internal EXE. Please place an AHK EXE at " AhkFolder
				ExitApp
			}
			return 0
		}
	}
	InternalExe := internal_exe
	return 1
}

; Reads the SwapFolder for available versions
CheckCurrentVersion(){
	global AhkExe, AhkFolder, SwapFolder, VersionFolder
	global LVSwapFolder
	global hCurrentVersion, hCurrentVariant
	global CurrentVersion, CurrentVariant
	global hMismatchWarning, MismatchWarning
	global VariantButtonA32, VariantButtonU32, VariantButtonU64
	; Scan base AHK folder
	ahk_version := GetInfo(AhkExe, "version")
	if (ahk_version = 0){
		ahk_variant := 0
		GuiControl, +Cred, % hCurrentVersion
		GuiControl, , % hCurrentVersion, % "None."
		GuiControl, +Cred, % hCurrentVariant
		GuiControl, , % hCurrentVariant, % "None."
	} else {
		GuiControl, +CBlack, % hCurrentVersion
		GuiControl, , % hCurrentVersion, % ahk_version
		ahk_variant := GetInfo(AhkExe, "variant")
		GuiControl, +CBlack, % hCurrentVariant
		GuiControl, , % hCurrentVariant, % ahk_variant
	}
	; Set Global vars
	CurrentVersion := ahk_version
	CurrentVariant := ahk_variant
	

	backup_versions := CheckVersionsMatch(AhkFolder)
	if (ahk_version != 0 && ahk_version != backup_versions){
		GuiControl, -Hidden, % hMismatchWarning
		GuiControl, +Hidden +Disabled, % VariantButtonA32
		GuiControl, +Hidden +Disabled, % VariantButtonU32
		GuiControl, +Hidden +Disabled, % VariantButtonU64
		MismatchWarning := 1
	} else {
		GuiControl, +Hidden -Disabled, % hMismatchWarning
		GuiControl, -Hidden -Disabled, % VariantButtonA32
		GuiControl, -Hidden -Disabled, % VariantButtonU32
		GuiControl, -Hidden -Disabled, % VariantButtonU64
		MismatchWarning := 0
	}
}

; Refreshes the LV with the list of available versions
BuildSwapList(){
	global LVSwapFolder, VersionFolder
	
	Gui, ListView, % LVSwapFolder
	LV_Delete()
	if (FileExist(VersionFolder)){
		; Find folders in the SwapFolder
		Loop, % VersionFolder "\*.*", 2 
		{
			LV_Add("", A_LoopFileName)
		}
	} else {
		FileCreateDir, % VersionFolder
	}	
}

; Swaps to different AHK version. Keeps current variant (Ansi/Unicode, x86/x64)
SwapVersion(version){
	global AhkExe, AhkFolder, SwapFolder, VersionFolder
	global CurrentVersion, CurrentVariant
	
	current_variant := CurrentVariant
	if (current_variant = 0){
		current_variant := "A32"
	}
	
	if (CurrentVersion != 0){
		; Current version installed, check if it is in the library before deleting it.
		BackupVersion()
	}
	
	;MsgBox % "Swapping to " version " / " current_variant
	if (DeleteFile(AhkExe)){
		alternate_exes := [AhkFolder "\AutoHotkeyA32.exe", AhkFolder "\AutoHotkeyU32.exe", AhkFolder "\AutoHotkeyU64.exe"]
		if (DeleteFiles(alternate_exes)){
			; Old AHK Deleted, copy files
			FileCopy, % VersionFolder "\" Version "\*.*", % AhkFolder
			
			; Put back current Variant as AutoHotkey.exe
			src := VersionFolder "\" Version "\Autohotkey" current_variant ".exe"
			FileCopy, % src, % AhkExe
			
			CheckCurrentVersion()
			HighBeep()
			return 1
		} else {
			MsgBox % "Warning!`n`nCould not delete the Alternate Exes!"
			CheckCurrentVersion()
			return 0
		}
	} else {
		AhkExeLockedWarning()
		return 0
	}
}

; Swaps variant (ie x86/x64, Ansi/Unicode)
SwapVariant(Variant){
	global MismatchWarning, AhkExe, AhkFolder
	
	if (!MismatchWarning){
		if (DeleteFile(AhkExe)){
			FileCopy, % AhkFolder "\AutoHotkey" Variant ".exe", % AhkExe
			CheckCurrentVersion()
			HighBeep()
			return 1
		} else {
			AhkExeLockedWarning()
			return 0
		}
	}
}

; Backs up the current version, if it needs to be
BackupVersion(){
	global AhkFolder, CurrentVersion, VersionFolder
	
	if (FileExist(VersionFolder)){
		; Find folders in the SwapFolder
		found := 0
		Loop, % VersionFolder "\*.*", 2 
		{
			if (CurrentVersion = A_LoopFileName){
				found := 1
				break
			}
		}
	} else {
		FileCreateDir, % VersionFolder
	}
	new_folder := VersionFolder "\" CurrentVersion
	if (!found){
		FileCreateDir, % new_folder
	}
	FileCopy, % AhkFolder "\AutoHotkeyA32.exe", % new_folder
	FileCopy, % AhkFolder "\AutoHotkeyU32.exe", % new_folder
	FileCopy, % AhkFolder "\AutoHotkeyU64.exe", % new_folder
	BuildSwapList()
	return 1
}

; Deletes an array of files.
; Returns 1 if deleted or any given file did not exist, otherwise 0
DeleteFiles(files){
	Loop % files.MaxIndex() {
		if (!DeleteFile(files[A_Index])){
			return 0
		}
	}
	return 1
}

; Displays a standard warning if AHK EXE is locked
AhkExeLockedWarning(){
	MsgBox % "Could not delete AutoHotkey.exe.`n`nDo you have any scripts running? If so, stop them and try again"
}

; Deletes a single file. Return 1 is good, 0 bad
DeleteFile(file){
	if (FileExist(file)){
		FileDelete, % file
		if (ErrorLevel){
			return 0
		}
	}
	return 1
}

; Unpacks a beta release zip, renames files etc
ImportFile(file){
	global SwapFolder, ImportFolder, VersionFolder
	zip := ImportFolder "\" file
	file := ImportFolder "\" file
	working_folder := ImportFolder "\Working"
	; Delete any files in working folder
	FileDelete, % working_folder "\*.*"
	; Unzip to working folder
	SmartZip(zip, working_folder)
	; Wait? ToDo: What if disk is not spun up etc?
	Sleep 100
	ConformTestBuildFileNames(working_folder)
	ver := CheckVersionsMatch(working_folder)
	if (ver != 0){
		; All good, move to new home
		ver_folder := VersionFolder "\" ver
		if (FileExist(ver_folder)){
			; Folder for that version already exists
		} else {
			FileCreateDir, % ver_folder
		}
		; Move the files to their new home
		FileMove, % working_folder "\*.*", %  ver_folder
		HighBeep()
		BuildSwapList()
	}
}

; Scans the import folder for zips to import
BuildImportList(){
	global LVImportList
	global ImportFolder
	
	Gui, ListView, % LVImportList
	LV_Delete()
	if (!FileExist(ImportFolder)){
		FileCreateDir, % ImportFolder
	}
	Loop % ImportFolder "\*.zip"
	{
		;FormatTime, TimeString, A_LoopFileTimeModified, ShortDate
		LV_Add("", A_LoopFileName)
	}
}

; Checks that A32/U64 etc variants are all the same AHK version
CheckVersionsMatch(folder){
	Types_checked := BuildVariantObj()
	Count := 0
	found_version := 0
	Loop % folder "\AutoHotkey???.exe"
	{
		file := StripExtension(StripAutoHotkeyPrefix(A_LoopFileName))
		if (file = "a32" || file = "u32" || file = "u64"){
			if (!Types_checked[file]){
				this_version := GetInfo(A_LoopFileFullPath, "version")
				;type not already checked
				if (!found Version){
					; Checking first file
					found_version := this_version
				}
				Types_checked[file] := 1
				if (this_version = found_version){
					; all good so far
					Count++
				}
			}
		}
	}
	if (Count = 3){
		return found_version
	}
	return 0
}

; Converts file names of a test build to normal AHK naming format.
ConformTestBuildFileNames(folder){
	Count := 0
	Count += RenameWild(folder, "\*_a.exe", "AutoHotkeyA32.exe")
	Count += RenameWild(folder, "\*_w.exe", "AutoHotkeyU32.exe")
	Count += RenameWild(folder, "\*_x64.exe", "AutoHotkeyU64.exe")
	return
	Loop, % folder "\*_a.exe"
	{
		Count++
		name := A_LoopFileName
	}
	if (Count = 1){
		src := folder "\" name
		dest := folder "\AutoHotkeyA32.exe"
		FileMove, % src , % dest
		Total++
	}
	
}

; Tries to rename ONE file using a wildcard (eg _a.exe to AutoHotkeyA32.exe)
RenameWild(folder, wild, dest){
	Count := 0
	Loop, % folder "\" wild
	{
		Count++
		name := A_LoopFileName
	}
	if (Count = 1){
		src := folder "\" name
		dest := folder "\" dest
		FileMove, % src , % dest
		return 1
	}
	return 0
}

GetAHKVariant(file){
	name := StripExtension(file)
	v := StripAutoHotkeyPrefix(name)
	return v
}

; Strips "AutoHotkey" from the start of a string
StripAutoHotkeyPrefix(str){
	str := StrSplit(str, "AutoHotkey")[2]
	return str
}

; Strips \ (or anything) from end
StripTrailingSlash(str){
	return SubStr(str,1,(StrLen(str)-1))
}

; Strips extension from file
StripExtension(file){
	SplitPath, file, ,,, file
	return file
}

; Builds a standard object for variants
BuildVariantObj(){
		return {A32: 0, U32: 0, U64: 0}
}

; Gets Info about an AutoHotkey EXE
; eg FULL AHK version (not just the base version like 1.1.19.02, but full like 1.1.19.02-17+gcd46158)
GetInfo(path, mode){
	if (!FileExist(path)){
		return 0
	}
	script_path := A_ScriptDir "\get_info.ahk"
	temp_file := "AHK-EXE-Swapper.info.txt"
	command := path " " script_path " " temp_file " " mode
	RunWait, % command
	FileRead, ret, % temp_file
	FileDelete, % temp_file
	return ret
}

; Asynch Beeps
LowBeep(){
	SetTimer, LowBeep, -0
}

HighBeep(){
	SetTimer, HighBeep, -0
}

LowBeep:
	SoundBeep, 500, 250
	return

HighBeep:
	SoundBeep, 1000, 250
	return

;; ---------    THE FUNCTION    ------------------------------------
/*
SmartZip()
   Smart ZIP/UnZIP files
Parameters:
   s, o   When compressing, s is the dir/files of the source and o is ZIP filename of object. When unpressing, they are the reverse.
   t      The options used by CopyHere method. For availble values, please refer to: http://msdn.microsoft.com/en-us/library/windows/desktop/bb787866
Link:
http://www.autohotkey.com/forum/viewtopic.php?p=523649#523649
*/

SmartZip(s, o, t = 4)
{
	IfNotExist, %s%
		return, -1        ; The souce is not exist. There may be misspelling.
	
	oShell := ComObjCreate("Shell.Application")
	
	if (SubStr(o, -3) = ".zip")	; Zip
	{
		IfNotExist, %o%        ; Create the object ZIP file if it's not exist.
			CreateZip(o)
		
		Loop, %o%, 1
			sObjectLongName := A_LoopFileLongPath

		oObject := oShell.NameSpace(sObjectLongName)
		
		Loop, %s%, 1
		{
			if (sObjectLongName = A_LoopFileLongPath)
			{
				continue
			}
			ToolTip, Zipping %A_LoopFileName% ..
			oObject.CopyHere(A_LoopFileLongPath, t)
			SplitPath, A_LoopFileLongPath, OutFileName
			Loop
			{
				oObject := "", oObject := oShell.NameSpace(sObjectLongName)	; This doesn't affect the copyhere above.
				if oObject.ParseName(OutFileName)
					break
			}
		}
		ToolTip
	}
	else if InStr(FileExist(o), "D") or (!FileExist(o) and (SubStr(s, -3) = ".zip"))	; Unzip
	{
		if !o
			o := A_ScriptDir        ; Use the working dir instead if the object is null.
		else IfNotExist, %o%
			FileCreateDir, %o%
		
		Loop, %o%, 1
			sObjectLongName := A_LoopFileLongPath
		
		oObject := oShell.NameSpace(sObjectLongName)
		
		Loop, %s%, 1
		{
			oSource := oShell.NameSpace(A_LoopFileLongPath)
			oObject.CopyHere(oSource.Items, t)
		}
	}
}

CreateZip(n)	; Create empty Zip file
{
	ZIPHeader1 := "PK" . Chr(5) . Chr(6)
	VarSetCapacity(ZIPHeader2, 18, 0)
	ZIPFile := FileOpen(n, "w")
	ZIPFile.Write(ZIPHeader1)
	ZIPFile.RawWrite(ZIPHeader2, 18)
	ZIPFile.close()
}
;; ---------    FUNCTION END   ------------------------------------