Scriptname PapyrusTerminal:BIOS extends PapyrusTerminal:KERNAL Hidden

; Papyrus Terminal BIOS
; This is the code layer that allows your Papyrus Scripts to interact with the Papyrus Terminal Flash application
; Derive from this base class to implement your Terminal scripts. See Example Holotapes for, well, examples :)

; custom scripting by niston & Scrivener07


Actor Player

; Holotape
string IDENTIFIER_VALUE = "PapyrusTerminal:Identifier" const

; Menus
string TERMINAL_MENUNAME = "TerminalHolotapeMenu" const
string PIPBOY_MENUNAME = "PipboyHolotapeMenu" const

; Menu Target
string Property FlashMenu Hidden
	{Returns the current menu name which supports either Terminals or Pipboys.
	When neither menu is open, an empty string is returned.}
	string Function Get()
		If (UI.IsMenuOpen(TERMINAL_MENUNAME))
			return TERMINAL_MENUNAME
		ElseIf (UI.IsMenuOpen(PIPBOY_MENUNAME))
			return PIPBOY_MENUNAME
		Else
			return ""
		EndIf
	EndFunction
EndProperty


; Fields
;---------------------------------------------

; internal constants, do not mess with
string TerminalReadyEvent = "PapyrusTerminal:ReadyEvent" const
string TerminalShutdownEvent = "PapyrusTerminal:ShutdownEvent" const
string ReadAsyncCancelledEvent = "PapyrusTerminal:ReadAsyncCancelledEvent" const
string ReadAsyncResultEvent = "PapyrusTerminal:ReadAsyncResultEvent" const

; read mode
int READMODE_NONE = 0 const
int READMODE_LINE_SYNC = 1 const
int READMODE_LINE_ASYN = 2 const
int READMODE_KEY_SYNC = 3 const
int READMODE_KEY_ASYN = 4 const

; alignment
int Property ALIGNMENT_LEFT = 0 Auto Const Hidden
int Property ALIGNMENT_CENTER = 1 Auto Const Hidden
int Property ALIGNMENT_RIGHT = 2 Auto Const Hidden

; ReadLine related vars
float SYNCREAD_WAIT_INTERVAL = 0.2 const
int readMode = 0
bool readSyncCompleteFlag = false
string readAsyncBuffer = ""

; get or set to true upon receiving OnTerminalShutdown event.
bool isShuttingDown = false


bool Property TerminalShutdown Hidden
	bool Function Get()
		return isShuttingDown
	EndFunction
EndProperty


; Events
;---------------------------------------------

; Lifecycle management

Event OnInit()
	Debug.TraceSelf(self, "OnInit", "ctor")
	Player = Game.GetPlayer()
	RegisterForMenuOpenCloseEvent(PIPBOY_MENUNAME)
EndEvent


Event OnMenuOpenCloseEvent(string menuName, bool opening)
	Debug.TraceSelf(self, "OnMenuOpenCloseEvent", "menuName:"+menuName + ", opening:"+opening)

	If (menuName == PIPBOY_MENUNAME)
		If (opening)

			string id = UI.Get(menuName, "root1.Identifier")

			If (id == IDENTIFIER_VALUE)
				OnHolotapePlay(Player) ; <-- Player == Terminal
			EndIf
		EndIf
	EndIf
EndEvent


Event OnHolotapePlay(ObjectReference refTerminal)
	Debug.TraceSelf(self, "OnHolotapePlay", "refTerminal:"+refTerminal)

	; initialize internal vars
	readMode = READMODE_NONE
	readSyncCompleteFlag = false;
	readAsyncBuffer = "";
	isShuttingDown = false

	; register for terminal ready and shutdown events
	RegisterForExternalEvent(TerminalReadyEvent, "OnTerminalReady")
	RegisterForExternalEvent(TerminalShutdownEvent, "OnTerminalShutdown")

	; ready for text replacement tokens to be set, notify derived class
	OnPapyrusTerminalInitialize(refTerminal)

	; vanilla menus
	RegisterForMenuOpenCloseEvent(TERMINAL_MENUNAME) ; TODO: This is not needed beyond debug for now.
	RegisterForMenuOpenCloseEvent(PIPBOY_MENUNAME)
EndEvent


Function OnPipboyReady()
	Debug.Trace(self + ": OnPipBoyReady() event received.")
EndFunction


Function OnTerminalReady()
	Debug.Trace(self + ": DEBUG - OnTerminalReady event received.")

	; unregister OnTerminalReady events
	UnRegisterForExternalEvent(TerminalReadyEvent)

	; notify derived class that terminal is ready for interaction
	OnPapyrusTerminalReady()
EndFunction


Function OnTerminalShutdown()
	Debug.Trace(self + ": DEBUG - OnTerminalShutdown event received.")

	; set shutdown flag
	isShuttingDown = true

	; unregister for all events
	UnregisterForAllEvents()

	If (readMode == READMODE_LINE_SYNC || readMode == READMODE_KEY_SYNC)
		readSyncCompleteFlag = false

	ElseIf (readMode == READMODE_LINE_ASYN || readMode == READMODE_KEY_ASYN)
		; send async read cancel to derived class
		OnPapyrusTerminalReadAsyncCancelled()

	EndIf

	; clear readmode
	readMode = READMODE_NONE

	; notify derived class that terminal has shut down
	OnPapyrusTerminalShutdown()
EndFunction















; terminal related functions
;---------------------------------------------

int Property TerminalRows
	{Number of text rows in the current Terminal display mode}
	int Function Get()
		If (!isShuttingDown)
			return UI.Get(FlashMenu, "root1.TerminalLines") as int
		Else
			return 0
		EndIf
	EndFunction
EndProperty

int Property TerminalColumns
	{Number of text columns in the current Terminal display mode}
	int Function Get()
		If (!isShuttingDown)
			return UI.Get(FlashMenu, "root1.TerminalColumns") as int
		Else
			return 0
		EndIf
	EndFunction
EndProperty


bool Property QuitOnTABEnabled Hidden
	{Enable or disable leaving Terminal by pressing TAB key.
	 This is useful for making menus with submenus, or when you want to react to TAB.}
	Function Set(bool value)
		If (!isShuttingDown)
			UI.Set(FlashMenu, "root1.QuitOnTABEnable", value)
		EndIf
	EndFunction
	bool Function Get()
		If (!isShuttingDown)
			return UI.Get(FlashMenu, "root1.QuitOnTABEnable") as bool
		Else
			return false
		EndIf
	EndFunction
EndProperty


; End the terminal session (exit holotape)
Function End()
	If (!isShuttingDown)
		var[] args = new var[1]
		args[0] = true
		UI.Invoke(FlashMenu, "root1.End", args)
	EndIf
EndFunction



; screen functions

; Print aligned fixed-width field (no LF appended)
Function PrintField(string fieldText, int fieldSize, int alignmentType, string paddingChar = " ", bool noElipsis = false)
	If (!isShuttingDown)
		If ((fieldSize + CursorPositionColumn) > TerminalColumns)
			; field size may not exceed terminal width
			fieldSize = TerminalColumns - (CursorPositionColumn - 1)
		EndIf
		var[] args = new var[5]
		args[0] = fieldText
		args[1] = fieldSize
		args[2] = alignmentType
		args[3] = paddingChar
		args[4] = noElipsis
		UI.Invoke(FlashMenu, "root1.PrintFieldPapyrus", args)
	EndIf
EndFunction

; Print line to screen (appends LF at the end)
Function PrintLine(string lineToPrint = "")
	If (!isShuttingDown)
		var[] args = new var[1]
		args[0] = lineToPrint
		UI.Invoke(FlashMenu, "root1.PrintLinePapyrus", args)
	EndIf
EndFunction

; Print characters to screen
Function Print(string charsToPrint)
	If (!isShuttingDown)
		var[] args = new var[1]
		args[0] = charsToPrint
		UI.Invoke(FlashMenu, "root1.PrintPapyrus", args)
	EndIf
EndFunction

; Clear the screen
Function Clear()
	If (!isShuttingDown)
		var[] args = new var[1]
		args[0] = false
		UI.Invoke(FlashMenu, "root1.ClearScreenPapyrus", args)
	EndIf
EndFunction

; Clear the screen and move cursor to home position (1, 1)
Function ClearHome()
	If (!isShuttingDown)
		var[] args = new var[1]
		args[0] = true
		UI.Invoke(FlashMenu, "root1.ClearScreenPapyrus", args)
	EndIf
EndFunction



; Enable/disable reverse (inverse) text mode
bool Property ReverseMode Hidden
	Function Set(bool value)
		If (!isShuttingDown)
			UI.Set(FlashMenu, "root1.ReverseMode", value)
		EndIf
	EndFunction
	bool Function Get()
		If (!isShuttingDown)
			return UI.Get(FlashMenu, "root1.ReverseMode") as bool
		Else
			return false
		EndIf
	EndFunction
EndProperty

; Enable/disable insert mode (insert key toggle)
bool Property InsertMode Hidden
	Function Set(bool value)
		If (!isShuttingDown)
			UI.Set(FlashMenu, "root1.InsertMode", value)
		EndIf
	EndFunction
	bool Function Get()
		If (!isShuttingDown)
			return UI.Get(FlashMenu, "root1.InsertMode") as bool
		Else
			return false
		EndIf
	EndFunction
EndProperty

; Enable/disable Terminal local echo (print typed keys to screen)
bool Property LocalEcho Hidden
	Function Set(bool value)
		If (!isShuttingDown)
			UI.Set(FlashMenu, "root1.ScreenEchoEnable", value)
		EndIf
	EndFunction
	bool Function Get()
		If (!isShuttingDown)
			return UI.Get(FlashMenu, "root1.ScreenEchoEnable") as bool
		Else
			return false
		EndIf
	EndFunction
EndProperty

string Property PapyrusStringEscapeSequence Hidden
	Function Set(string value)
		If (!isShuttingDown)
			UI.Set(FlashMenu, "root1.PapyrusStringEscapeSequence", value)
		EndIf
	EndFunction
	string Function Get()
		If (!isShuttingDown)
			return UI.Get(FlashMenu, "root1.PapyrusStringEscapeSequence") as string
		Else
			return ""
		EndIf
	EndFunction
EndProperty


; cursor functions

; Move the cursor by row and column number (top left is 1,1)
Function CursorMove(int row, int column)
	If (isShuttingDown)
		return
	EndIf

	var[] args = new var[2]
	args[0] = row
	args[1] = column
	UI.Invoke(FlashMenu, "root1.CursorMovePapyrus", args)
EndFunction

; Move the cursor by character index (zero based "screen memory" address, top left is 0)
Function CursorMoveByIndex(int index)
	If (isShuttingDown)
		var[] args = new var[1]
		args[0] = index
		UI.Invoke(FlashMenu, "root1.CursorMoveByIndex", args)
	EndIf
EndFunction

; Number of screen row the cursor is currently positioned at (first row is 1)
int Property CursorPositionRow
	int Function Get()
		If (!isShuttingDown)
			return UI.Get(FlashMenu, "root1.CursorCurrentLine") as int
		Else
			return 0
		EndIf
	EndFunction
EndProperty

; Number of screen column the cursor is currently positioned at (first column is 1)
int Property CursorPositionColumn
	int Function Get()
		If (!isShuttingDown)
			return UI.Get(FlashMenu, "root1.CursorCurrentColumn") as int
		Else
			return 0
		EndIf
	EndFunction
EndProperty

; Character index of current cursor position (zero based "screen memory" address, top left is 0)
int Property CursorPositionIndex
	int Function Get()
		If (!isShuttingDown)
			return UI.Get(FlashMenu, "root1.CursorCurrentIndex") as int
		Else
			return 0
		EndIf
	EndFunction
EndProperty

; Enable/disable visible cursor rectangle on Terminal screen
bool Property CursorEnabled Hidden
	Function Set(bool value)
		If (!isShuttingDown)
			UI.Set(FlashMenu, "root1.CursorEnabled", value)
		EndIf
	EndFunction
	bool Function Get()
		If (!isShuttingDown)
			return UI.Get(FlashMenu, "root1.CursorEnabled") as bool
		EndIf
	EndFunction
EndProperty



; keyboard functions

; Begin asynchronous ReadLine operation. Completes on ENTER keypress by user. Cancellable by calling ReadAsyncCancel().
; Operation will generate OnPapyrusTerminalReadAsyncCompleted event callback on completion.
bool Function ReadLineAsyncBegin(int maxLength = 0)
	If (isShuttingDown)
		return false
	EndIf
	If (readMode == READMODE_NONE)

		; set async readline mode
		readMode = READMODE_LINE_ASYN

		; clear async read buffer
		readAsyncBuffer = ""

		; register for terminal async read result and cancel events
		RegisterForExternalEvent(ReadAsyncResultEvent, "OnReadAsyncResult")

		; invoke async ReadLine on Terminal
		var[] args = new var[1]
		args[0] = maxLength
		return UI.Invoke(FlashMenu, "root1.ReadLineAsyncBeginPapyrus", args) as bool

	Else
		; read operation in progress
		Debug.Trace(self + ": ERROR - ReadLineAsyncBegin() called, but a Read operation is already in progress.")
		return false;

	EndIf
EndFunction

; Begin asynchronous ReadKey operation. Completes as user depresses a key. Cancellable by calling ReadAsyncCancel().
bool Function ReadKeyAsyncBegin()
	If (isShuttingDown)
		return false
	EndIf

	If (readMode == READMODE_NONE)

		; set readmode KEY ASYNC
		readMode = READMODE_KEY_ASYN

		; clear async read buffer
		readAsyncBuffer = ""

		; register for readasyncresult event
		RegisterForExternalEvent(ReadAsyncResultEvent, "OnReadAsyncResult")

		; invoke on Terminal
		var[] args = new var[1]
		args[0] = ""
		return UI.Invoke(FlashMenu, "root1.ReadKeyAsyncBegin", args) as bool

	Else
		; read operation in progress
		Debug.Trace(self + ": ERROR - ReadKeyAsyncBegin() called, but a Read operation is already in progres.")
		return false;

	EndIf
EndFunction

; Cancel a pending asynchronous Read operation
Function ReadAsyncCancel()
	If (isShuttingDown)
		return
	EndIf

	If (readMode == READMODE_LINE_ASYN || readMode == READMODE_KEY_ASYN)
		; unregister for terminal async read result event
		UnRegisterForExternalEvent(ReadAsyncResultEvent)

		; register for terminal async read cancelled event
		RegisterForExternalEvent(ReadAsyncCancelledEvent, "OnReadAsyncCancelled")

		; invoke ReadLineAsyncCancel on Terminal
		var[] args = new var[1]
		args[0] = ""
		UI.Invoke(FlashMenu, "root1.ReadAsyncCancel", args)

	Else
		Debug.Trace(self + ": WARNING - ReadAsyncCancel() called, but no async Read operation was in progress.")

	EndIf
EndFunction

; Synchronously read a line (ends in ENTER keypress) from the Terminal
string Function ReadLine(int maxLength = 0)
	If (isShuttingDown)
		return "";
	EndIf

	If (readMode == READMODE_NONE)

		; set read mode synchronous line
		readMode = READMODE_LINE_SYNC

		; clear readAsync input buffer and sync read complete flag
		readSyncCompleteFlag = false
		readAsyncBuffer = ""

		; register for async result event
		RegisterForExternalEvent(ReadAsyncResultEvent, "OnReadAsyncResult");

		; invoke ReadLineAsync on Terminal
		var[] args = new var[1]
		args[0] = maxLength
		UI.Invoke(FlashMenu, "root1.ReadLineAsyncBeginPapyrus", args)

		; wait for async result
		While (IsBoundGameObjectAvailable() &&  readMode == READMODE_LINE_SYNC && !readSyncCompleteFlag && !isShuttingDown)
			;Debug.Trace(self + ": DEBUG - [ReadLine] Waiting for OnReadAsyncResult")

			; WARNING: DO NOT use Utility.Wait() in your Papyrus Terminal scripts!
			; Doing so will suspend execution of your script, because the Terminal Menu is open.
			; Use Utility.WaitMenuMode() instead.

			Utility.WaitMenuMode(SYNCREAD_WAIT_INTERVAL)
		EndWhile

		; return async input buffer contents
		return readAsyncBuffer
	Else
		Debug.Trace(self + ": ERROR - ReadLine() called, but a Read operation is already in progress.")
		return ""
	EndIf
EndFunction

string Function ReadKey()
	If (isShuttingDown)
		return "";
	EndIf
	If (readMode == READMODE_NONE)
		; set read mode synchronous key
		readMode = READMODE_KEY_SYNC

		; clear readAsync input buffer and sync read complete flag
		readSyncCompleteFlag = false
		readAsyncBuffer = ""

		; register for async result event
		RegisterForExternalEvent(ReadAsyncResultEvent, "OnReadAsyncResult");

		; invoke ReadLineAsync on Terminal
		var[] args = new var[1]
		args[0] = ""
		bool readAsyncBeginResult = UI.Invoke(FlashMenu, "root1.ReadKeyAsyncBegin", args) as bool
		If (readAsyncBeginResult)
			; wait for read async result
			While (IsBoundGameObjectAvailable() &&  readMode == READMODE_KEY_SYNC && !readSyncCompleteFlag && !isShuttingDown)
				;Debug.Trace(self + ": DEBUG - [ReadKey] Waiting for OnReadAsyncResult")

				; ##### WARNING: DO NOT use Utility.Wait() in your Papyrus Terminal scripts! #####
				; Doing so will suspend execution of your script, because the Terminal Menu is open.
				; Use Utility.WaitMenuMode() instead.

				Utility.WaitMenuMode(SYNCREAD_WAIT_INTERVAL)
			EndWhile

			If (readSyncCompleteFlag)
				; completed, return async input buffer contents
				return readAsyncBuffer
			Else
				; aborted, return empty string
				return ""
			EndIf
		Else
			Debug.Trace(self + ": ERROR - ReadKeyAsyncBegin call failed.")
			return ""
		EndIf
	Else
		Debug.Trace(self + ": ERROR - ReadKey() called, but a Read operation is already in progress.")
		return ""
	EndIf
EndFunction

; Result event handler for Terminal ReadLine operations
; The Fash Terminal itself can only do async Reads, but the API provides synchronous wrappers ReadKey() and ReadLine()
Function OnReadAsyncResult(string readLineBuffer)
	Debug.Trace(self + ": DEBUG - OnReadAsyncResult event received.") ;" readLineBuffer=" + readLineBuffer)

	; unregister for async result event
	UnRegisterForExternalEvent(ReadAsyncResultEvent)

	If (readMode == READMODE_LINE_SYNC || readMode == READMODE_KEY_SYNC)
		; synchronous Read operation has completed, fill async read buffer from event parameter
		readAsyncBuffer = readLineBuffer
 		; set sync read complete flag
		readSyncCompleteFlag = true
		; clear readmode
		readMode = READMODE_NONE

	ElseIf (readMode == READMODE_LINE_ASYN || readMode == READMODE_KEY_ASYN)
		; asynchronous Read operation has completed, signal derived class
		OnPapyrusTerminalReadAsyncCompleted(readLineBuffer)
		; reset readmode
		readMode = READMODE_NONE

	Else
		Debug.Trace(self + ": WARNING - OnReadAsyncResult event received, but no Read operation was in progress.");
	EndIf
EndFunction

; Result event handler for async Read cancellation
Function OnReadAsyncCancelled()
	If (readMode == READMODE_LINE_ASYN || readMode == READMODE_KEY_ASYN)
		; unregister for async result and cancelled events
		UnRegisterForExternalEvent(ReadAsyncResultEvent)
		UnRegisterForExternalEvent(ReadAsyncCancelledEvent)

		; clear async read mode
		readMode = READMODE_NONE

		; notify derived class
		OnPapyrusTerminalReadAsyncCancelled()
	EndIf
EndFunction

;Convenience Functions
Function Sleep(Float secondsToSleep)
	Utility.WaitMenuMode(secondsToSleep)
EndFunction

Function Dispatch(string functionName, var arg1 = none, var arg2 = none, var arg3 = none, var arg4 = none, var arg5 = none, var arg6 = none)
	If (functionName == "")
		Debug.Trace(self + ": ERROR - AsyncDispatch() called with no function name.")
		return
	EndIf
	var[] callArgs = new var[0]
	AddArg(callArgs, arg1)
	AddArg(callArgs, arg2)
	AddArg(callArgs, arg3)
	AddArg(callArgs, arg4)
	AddArg(callArgs, arg5)
	AddArg(callArgs, arg6)
	Debug.Trace(self + ": DEBUG - Dispatch(" + functionName + ", <" + callArgs.Length + " parameters>) called.")
	If (!TerminalShutdown)
		CallFunctionNoWait(functionName, callArgs)
	EndIf
EndFunction

Function AddArg(var[] argsArray, var varArg)
	If ((varArg + "") == "None")
		return
	EndIf

	; TESTING THIS
	argsArray.Add(varArg)
	return

	;/ 	If (varArg is string)
		argsArray.Add(varArg as string)
		Debug.Trace(self + ": DEBUG - Argument (" + varArg + ") added as string")
	ElseIf (varArg is int)
		argsArray.Add(varArg as int)
		Debug.Trace(self + ": DEBUG - Argument (" + varArg + ") added as int")
	ElseIf (varArg is Float)
		argsArray.Add(varArg as Float)
		Debug.Trace(self + ": DEBUG - Argument (" + varArg + ") added as Float")
	ElseIf (varArg is Form)
		argsArray.Add(varArg as Form)
		Debug.Trace(self + ": DEBUG - Argument (" + varArg + ") added as Form")
	ElseIf (varArg is ObjectReference)
		Debug.Trace(self + ": DEBUG - Argument (" + varArg + ") added as ObjectReference")
		argsArray.Add(varArg as ObjectReference)
	EndIf /;
EndFunction


; string Utility Functions
string[] Function StringSplit(string line, string separator = " ")
	If (isShuttingDown)
		string[] retVal = new string[0]
		return retVal
	EndIf

	var[] args = new var[2]
	args[0] = line
	args[1] = separator
	return Utility.VarToVarArray(UI.Invoke(FlashMenu, "root1.StringSplitPapyrus", args)) as string[]
EndFunction

string Function StringCharAt(string line, int charIndex)
	If (isShuttingDown)
		return ""
	EndIf

	var[] args = new var[2]
	args[0] = line
	args[1] = charIndex
	return UI.Invoke(FlashMenu, "root1.StringCharAtPapyrus", args) as string
EndFunction

int Function StringCharCodeAt(string line, int charIndex)
	If (isShuttingDown)
		return -1
	EndIf

	var[] args = new var[2]
	args[0] = line
	args[1] = charIndex
	return UI.Invoke(FlashMenu, "root1.StringCharCodeAtPapyrus", args) as int
EndFunction

int Function StringIndexOf(string line, string part, int startIndex)
	If (isShuttingDown)
		return -1
	EndIf

	var[] args = new var[3]
	args[0] = line
	args[1] = part
	args[2] = startIndex
	return UI.Invoke(FlashMenu, "root1.StringIndexOfPapyrus", args) as int
EndFunction

int Function StringLastIndexOf(string line, string part, int priorToIndex = -1)
	If (isShuttingDown)
		return -1
	EndIf

	var[] args = new var[3]
	args[0] = line
	args[1] = part
	args[2] = priorToIndex
	return UI.Invoke(FlashMenu, "root1.StringLastIndexOfPapyrus", args) as int
EndFunction

string Function StringReplace(string line, string pattern, string replacement)
	If (isShuttingDown)
		return ""
	EndIf

	var[] args = new var[3]
	args[0] = line
	args[1] = pattern
	args[2] = replacement
	return UI.Invoke(FlashMenu, "root1.StringReplacePapyrus", args) as string
EndFunction

string Function StringSlice(string line, int startIndex, int endIndex = 0x7fffffff)
	If (isShuttingDown)
		return ""
	EndIf

	var[] args = new var[3]
	args[0] = line
	args[1] = startIndex
	args[2] = endIndex
	return UI.Invoke(FlashMenu, "root1.StringSlicePapyrus", args) as string
EndFunction

string Function StringSubstring(string line, int startIndex, int endIndex = 0x7fffffff)
	If (isShuttingDown)
		return ""
	EndIf

	var[] args = new var[3]
	args[0] = line
	args[1] = startIndex
	args[2] = endIndex
	return UI.Invoke(FlashMenu, "root1.StringSubstringPapyrus", args) as string
EndFunction

bool Function StringIsNumeric(string line)
	If (isShuttingDown)
		return false
	EndIf

	If (line == "")
		return false
	EndIf

	var[] args = new var[1]
	args[0] = line
	return UI.Invoke(FlashMenu, "root1.StringIsNumericPapyrus", args) as bool
EndFunction

string Function StringFormat(var[] lineAndArguments)
	If (isShuttingDown)
		return ""
	EndIf

	return UI.Invoke(FlashMenu, "root1.StringFormatPapyrus", lineAndArguments) as string
EndFunction

string Function StringRepeat(string sequenceToRepeat, int numberOfRepetitions)
	If (isShuttingDown)
		return ""
	EndIf

	var[] args = new var[2]
	args[0] = sequenceToRepeat
	args[1] = numberOfRepetitions

	return UI.Invoke(FlashMenu, "root1.StringRepeatPapyrus")
EndFunction
