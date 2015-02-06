; Used to get information from a specific AHK EXE
; Currently supports long version number, bit depth and ANSI / Unicode
#SingleInstance force
#NoEnv

if 0 = 2 
{
	file = %1%
	mode = %2%
	FileDelete, % file

	if (mode = "version"){
		FileAppend, % A_AhkVersion, % file
	} else if (mode = "variant"){
		str := ""
		if (A_IsUnicode){
			str .= "U"
		} else {
			str .= "A"
		}
		if (A_PtrSize = 4){
			str .= "32"
		} else {
			str .= "64"
		}
		FileAppend, % str, % file
	}
}