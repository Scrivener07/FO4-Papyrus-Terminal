ScriptName PapyrusTerminal:Example03 extends PapyrusTerminal:BIOS
{The MS Command Line Interface}

; Menu Base
string TerminalHolotapeMenu = "TerminalHolotapeMenu" const

; Menu Code
string OS
string OS_Asset = "PapyrusTerminal_OS.swf" const
string COMMAND_TYPE_LoadCompleteEvent = "PapyrusTerminal:COMMAND_TYPE_LoadCompleteEvent" const

; Command Index
int CMD = 0 const
int CMD_ARG1 = 1 const
int CMD_ARG2 = 2 const
int CMD_ARG3 = 3 const

; Command Name
string COMMAND_EXIT = "EXIT" const
string COMMAND_VER = "VER" const
string COMMAND_HELP = "HELP" const
string COMMAND_CLS = "CLS" const
string COMMAND_CD = "CD" const
string COMMAND_DIR = "DIR" const
string COMMAND_TYPE = "TYPE" const
string COMMAND_TREE = "TREE" const
string COMMAND_DATE = "DATE" const
string COMMAND_TIME = "TIME" const

; Processing
bool Abort = false
bool Property Processing Hidden
	{Represents the abort condition for the command processor.}
	bool Function Get()
		return IsBoundGameObjectAvailable() && !Abort
	EndFunction
EndProperty


; Terminal
;---------------------------------------------

Event OnPapyrusTerminalInitialize(ObjectReference refTerminal)
	Debug.TraceSelf(self, "OnPapyrusTerminalInitialize", "refTerminal:"+refTerminal)
EndEvent

Event OnPapyrusTerminalReady()
	Debug.TraceSelf(self, "OnPapyrusTerminalReady", "Ready")
	PrintLine("The software is loading...")

	RegisterForExternalEvent(COMMAND_TYPE_LoadCompleteEvent, "TypeCallback")
	UI.Load(TerminalHolotapeMenu, "root1", OS_Asset, self, "BootCallback")
EndEvent

Function BootCallback(bool success, string menuName, string menuRoot, string assetInstance, string assetFile)
	Debug.TraceSelf(self, "BootCallback", "success:"+success+", menuName:"+menuName+", menuRoot:"+menuRoot+", assetInstance:"+assetInstance+", assetFile:"+assetFile)

	Abort = false
	OS = assetInstance
	Setup()

	ClearHome()
	VER()
	PrintLine("")
	While (Processing)
		Print(CD() + "> ")
		CursorEnabled = true
		string line = ReadLine()
		CursorEnabled = false
		PrintLine("")
		Interpret(line)
		PrintLine("")
	EndWhile

	; terminate
	End()
EndFunction


Function Setup()
	var[] arguments = new var[1]
	arguments[0] = PapyrusTerminal:KERNAL.GetDirectoryCurrent()
	UI.Invoke(TerminalHolotapeMenu, OS+".HOME", arguments)
	Debug.TraceSelf(self, "Setup", arguments)
EndFunction


Event OnPapyrusTerminalShutdown()
	Debug.TraceSelf(self, "OnPapyrusTerminalShutdown", "Shutdown")
	Abort = true
EndEvent


; CMD
;---------------------------------------------

Function Interpret(string line)
	Debug.TraceSelf(self, "Interpret", "line:"+line)

	; TODO: Handle quoted parameters.
	string[] command = StringSplit(line)
	If (!command)
		Debug.TraceSelf(self, "Interpret", "The 'command' argument cannot be empty or none.")
	ElseIf (command[CMD] == COMMAND_EXIT)
		EXIT(command)
	ElseIf (command[CMD] == COMMAND_CLS)
		CLS(command)
	ElseIf (command[CMD] == COMMAND_HELP)
		HELP(command)
	ElseIf (command[CMD] == COMMAND_DIR)
		DIR(command)
	ElseIf (command[CMD] == COMMAND_TYPE)
		TYPE(command)
	ElseIf (command[CMD] == COMMAND_CD)
		CD(command)
	ElseIf (command[CMD] == COMMAND_TREE)
		TREE(command)
	ElseIf (command[CMD] == COMMAND_DATE)
		DATE(command)
	ElseIf (command[CMD] == COMMAND_TIME)
		TIME(command)
	ElseIf (command[CMD] == COMMAND_VER)
		VER(command)
	Else
		PrintLine("'"+command[CMD]+"' is not recognized as an internal or external command, operable program or batch file.")
	EndIf
EndFunction


; Commands
;---------------------------------------------

; Quits the CMD.EXE program (command interpreter) or the current batch script.
Function EXIT(string[] command)
	Debug.TraceSelf(self, "EXIT", command)
	Abort = true
EndFunction


; Displays the Windows version.
Function VER(string[] command = none)
	Debug.TraceSelf(self, "VER", command)
	If (!command)
		PrintLine("Microsoft Windows [Version 10.0.19041.867]")
		PrintLine("(c) 2020 Microsoft Corporation. All rights reserved.")
	Else
		PrintLine("Microsoft Windows [Version 10.0.19041.867]")
	EndIf
EndFunction


; Clears the screen.
Function CLS(string[] command)
	Debug.TraceSelf(self, "CLS", command)
	ClearHome()
EndFunction


; Displays the name of or changes the current directory.
string Function CD(string[] command = none)
	Debug.TraceSelf(self, "CD", command)
	var[] arguments = new var[1]
	arguments[0] = "."
	If (command && command.Length >= 2)
		; Command takes the first parameter and ignores the rest.
		arguments[0] = command[CMD_ARG1]
	EndIf

	string value = UI.Invoke(TerminalHolotapeMenu, OS+".CD", arguments)

	If (command)
		PrintLine(value)
	EndIf

	return value
EndFunction


; Displays a list of files and subdirectories in a directory.
Function DIR(string[] command)
	Debug.TraceSelf(self, "DIR", command)
	var[] arguments = new var[1]
	arguments[0] = "."
	If (command && command.Length >= 2)
		; Command takes the first parameter and ignores the rest.
		arguments[0] = command[CMD_ARG1]
	EndIf

	var object = UI.Invoke(TerminalHolotapeMenu, OS+".DIR", arguments)
	string[] values = Utility.VarToVarArray(object) as string[]

	int index = 0
	While (index < values.Length)
		PrintLine(values[index])
		index += 1
	EndWhile
EndFunction


; Prints a text file.
Function TYPE(string[] command)
	Debug.TraceSelf(self, "TYPE", command)
	var[] arguments = new var[1]
	; arguments[0] = "."

	If (command && command.Length >= 2)
		; Command takes the first parameter and ignores the rest.
		arguments[0] = command[CMD_ARG1]
	EndIf

	string object = UI.Invoke(TerminalHolotapeMenu, OS+".TYPE", arguments)
	string[] values = Utility.VarToVarArray(object) as string[]

	int index = 0
	While (index < values.Length)
		PrintLine(values[index])
		index += 1
	EndWhile
EndFunction

Function TypeCallback(var[] lines)
	Debug.TraceSelf(self, "TypeCallback", "lines:"+lines)
EndFunction


Function TREE(string[] command)
	Debug.TraceSelf(self, "TREE", "")
	PrintLine("The TREE command is not implemented...")
EndFunction


Function DATE(string[] command)
	Debug.TraceSelf(self, "DATE", "")
	PrintLine("The DATE command is not implemented...")
EndFunction


Function TIME(string[] command)
	Debug.TraceSelf(self, "TIME", "")
	PrintLine("The TIME command is not implemented...")
EndFunction


Function HELP(string[] command)
	Debug.TraceSelf(self, "HELP", "")
	If (command.Length == 1)
		PrintLine("For more information on a specific command, type HELP command-name")
		PrintLine(COMMAND_HELP + "      Provides Help information for Windows commands.")
		PrintLine(COMMAND_EXIT + "      Quits the CMD.EXE program (command interpreter).")
		PrintLine(COMMAND_CLS  + "       Clears the screen.")
		PrintLine(COMMAND_CD   + "        Displays the name of or changes the current directory.")
		PrintLine(COMMAND_DIR  + "       Displays a list of files and subdirectories in a directory.")
		PrintLine(COMMAND_TREE + "      Graphically displays the directory structure of a drive or path.")
		PrintLine(COMMAND_TYPE + "      Displays the contents of a text file.")
		PrintLine(COMMAND_DATE + "      Displays or sets the date.")
		PrintLine(COMMAND_TIME + "      Displays or sets the system time.")
		PrintLine(COMMAND_VER  + "       Displays the Windows version.")

	ElseIf (command[CMD_ARG1] == COMMAND_HELP)
		PrintLine("Provides help information for Windows commands.")
		PrintLine("")
		PrintLine("HELP [command]")
		PrintLine("    command - displays help information on that command.")

	ElseIf (command[CMD_ARG1] == COMMAND_TREE)
		PrintLine("Graphically displays the folder structure of a drive or path.")
		PrintLine("TREE [drive:][path] [/F] [/A]")
		PrintLine("    /F   Display the names of the files in each folder.")
		PrintLine("    /A   Use ASCII instead of extended characters.")

	ElseIf (command[CMD_ARG1] == COMMAND_CD)
		PrintLine("Displays the name of or changes the current directory.")
		PrintLine("")
		PrintLine("CD [/D] [drive:][path]")
		PrintLine("CD [..]")
		PrintLine("  ..   Specifies that you want to change to the parent directory.")
		PrintLine("")
		PrintLine("Type CD drive: to display the current directory in the specified drive.")
		PrintLine("Type CD without parameters to display the current drive and directory.")
		PrintLine("Use the /D switch to change current drive in addition to changing current")
		PrintLine("directory for a drive.")

	ElseIf (command[CMD_ARG1] == COMMAND_CLS)
		PrintLine("Clears the screen.")
		PrintLine("")
		PrintLine("CLS")

	ElseIf (command[CMD_ARG1] == COMMAND_TYPE)
		PrintLine("Displays the contents of a text file or files.")
		PrintLine("")
		PrintLine("TYPE [drive:][path]filename")

	ElseIf (command[CMD_ARG1] == COMMAND_EXIT)
		PrintLine("Quits the CMD.EXE program (command interpreter) or the current batch")
		PrintLine("script.")
		PrintLine("")
		PrintLine("EXIT [/B] [exitCode]")
		PrintLine("")
		PrintLine("  /B          specifies to exit the current batch script instead of")
		PrintLine("              CMD.EXE.  If executed from outside a batch script, it")
		PrintLine("              will quit CMD.EXE")
		PrintLine("")
		PrintLine("  exitCode    specifies a numeric number.  if /B is specified, sets")
		PrintLine("              ERRORLEVEL that number.  If quitting CMD.EXE, sets the process")
		PrintLine("              exit code with that number.")

	ElseIf (command[CMD_ARG1] == COMMAND_DATE)
		PrintLine("Displays or sets the date.")
		PrintLine("")
		PrintLine("DATE [/T | date]")
		PrintLine("")
		PrintLine("Type DATE without parameters to display the current date setting and")
		PrintLine("a prompt for a new one.  Press ENTER to keep the same date.")
		PrintLine("")
		PrintLine("If Command Extensions are enabled the DATE command supports")
		PrintLine("the /T switch which tells the command to just output the")
		PrintLine("current date, without prompting for a new date.")

	ElseIf (command[CMD_ARG1] == COMMAND_TIME)
		PrintLine("Displays or sets the system time.")
		PrintLine("")
		PrintLine("TIME [/T | time]")
		PrintLine("Type TIME with no parameters to display the current time setting and a prompt")
		PrintLine("for a new one.  Press ENTER to keep the same time.")

	ElseIf (command[CMD_ARG1] == COMMAND_VER)
		PrintLine("Displays the Windows version.")
		PrintLine("")
		PrintLine("VER")

	ElseIf (command[CMD_ARG1] == COMMAND_DIR)
		PrintLine("Displays a list of files and subdirectories in a directory.")
		PrintLine("")
		PrintLine("DIR [drive:][path][filename] [/A[[:]attributes]] [/B] [/C] [/D] [/L] [/N]")
		PrintLine("  [/O[[:]sortorder]] [/P] [/Q] [/R] [/S] [/T[[:]timefield]] [/W] [/X] [/4]")
		PrintLine("")
		PrintLine("[drive:][path][filename]")
		PrintLine("    Specifies drive, directory, and/or files to list.")
		PrintLine("")
		PrintLine("/A          Displays files with specified attributes.")
		PrintLine(" attributes   D  Directories                H  Hidden files")
		PrintLine("              -  Prefix meaning not")
		PrintLine("")
		PrintLine("Switches may be preset in the DIRCMD environment variable.  Override")
		PrintLine("preset switches by prefixing any switch with - (hyphen)--for example, /-W.")

	Else
		PrintLine("The "+ command[CMD_ARG1] + " command is not supported by the help utility.")
	EndIf

	PrintLine("\n")
EndFunction
