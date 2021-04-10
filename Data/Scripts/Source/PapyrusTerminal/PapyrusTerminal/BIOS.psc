Scriptname PapyrusTerminal:BIOS extends PapyrusTerminal:KERNAL Hidden

; Papyrus Terminal BIOS
; This is the code layer that allows your Papyrus Scripts to interact with the Papyrus Terminal Flash application
; Derive from this base class to implement your Terminal scripts. See Example Holotape for, well, examples :)

; custom scripting by niston & Scrivener07



; internal constants, do not mess with
string TerminalReadyEvent = "PapyrusTerminal:ReadyEvent" const
string TerminalShutdownEvent = "PapyrusTerminal:ShutdownEvent" const
string ReadAsyncCancelledEvent = "PapyrusTerminal:ReadAsyncCancelledEvent" const
string ReadAsyncResultEvent = "PapyrusTerminal:ReadAsyncResultEvent" const
string FLASH_MENUNAME = "TerminalHolotapeMenu" const
int READMODE_NONE = 0 const
int READMODE_LINE_SYNC = 1 const
int READMODE_LINE_ASYN = 2 const
int READMODE_KEY_SYNC = 3 const
int READMODE_KEY_ASYN = 4 const
float SYNCREAD_WAIT_INTERVAL = 0.2 const

; ReadLine related vars
int readMode = 0
Bool readSyncCompleteFlag = false
string readAsyncBuffer = ""

; gets set to true upon receiving OnTerminalShutdown event.
bool isShuttingDown = false



; Lifecycle management

Event OnInit()	
	Debug.Trace(Self + ": DEBUG - Papyrus Terminal holotape initialized.")
EndEvent

Event OnHolotapePlay(ObjectReference refTerminal)
	Debug.Trace(Self + ": DEBUG - OnHolotapePlay event recevied.")	
	
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
EndEvent

Function OnTerminalReady()	
	Debug.Trace(Self + ": DEBUG - OnTerminalReady event received.")

	; unregister OnTerminalReady events
	UnRegisterForExternalEvent(TerminalReadyEvent)

	; notify derived class that terminal is ready for interaction
	OnPapyrusTerminalReady()
EndFunction

Function OnTerminalShutdown()	
	Debug.Trace(Self + ": DEBUG - OnTerminalShutdown event received.")	
	
	; unregister for all events
	UnregisterForAllEvents()

	; set shutdown flag
	isShuttingDown = true
	
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

; Number of rows in the current Terminal display mode
Int Property TerminalRows
	Int Function Get()
		If (!isShuttingDown)
			return UI.Get(FLASH_MENUNAME, "root1.TerminalLines") as Int
		Else
			return 0
		EndIf
	EndFunction
EndProperty

; Number of columns in the current Terminal display mode
Int Property TerminalColumns
	Int Function Get()
		If (!isShuttingDown)
			return UI.Get(FLASH_MENUNAME, "root1.TerminalColumns") as Int
		Else
			return 0
		EndIf
	EndFunction
EndProperty

; Enable/disable leaving Terminal by pressing TAB key (useful for making menus with submenus)
Bool Property QuitOnTABEnabled
	Function Set(Bool value)
		If (!isShuttingDown)
			UI.Set(FLASH_MENUNAME, "root1.QuitOnTABEnable", value)
		EndIf
	EndFunction
	Bool Function Get()
		If (!isShuttingDown)
			return UI.Get(FLASH_MENUNAME, "root1.QuitOnTABEnable") as Bool
		Else
			return false
		EndIf
	EndFunction
EndProperty

; End the terminal session (exit holotape)
Function End()
	If (!isShuttingDown)
		;isShuttingDown = true;
		; invoke shutdown event (will not reliably happen if we close the terminal)
		;OnTerminalShutdown();
		Var[] args = new Var[1]
		args[0] = true
		UI.Invoke(FLASH_MENUNAME, "root1.End", args)
	EndIf
EndFunction



; screen functions

; Print line to screen (appends LF at the end)
Function PrintLine(String lineToPrint)
	If (!isShuttingDown)
		Var[] args = new Var[1]
		args[0] = lineToPrint
		UI.Invoke(FLASH_MENUNAME, "root1.PrintLinePapyrus", args)
	EndIf
EndFunction

; Print characters to screen
Function Print(String charsToPrint)
	If (!isShuttingDown)
		Var[] args = new Var[1]
		args[0] = charsToPrint
		UI.Invoke(FLASH_MENUNAME, "root1.PrintPapyrus", args)
	EndIf
EndFunction

; Clear the screen
Function Clear()
	If (!isShuttingDown)
		Var[] args = new Var[1]
		args[0] = false
		UI.Invoke(FLASH_MENUNAME, "root1.ClearScreenPapyrus", args)
	EndIf
EndFunction

; Clear the screen and move cursor to home position (1, 1)
Function ClearHome()
	If (!isShuttingDown)
		Var[] args = new Var[1]
		args[0] = true
		UI.Invoke(FLASH_MENUNAME, "root1.ClearScreenPapyrus", args)
	EndIf
EndFunction



; Enable/disable reverse (inverse) text mode
Bool Property ReverseMode Hidden
	Function Set(Bool value)
		If (!isShuttingDown)
			UI.Set(FLASH_MENUNAME, "root1.ReverseMode", value)
		EndIf
	EndFunction
	Bool Function Get()
		If (!isShuttingDown)
			return UI.Get(FLASH_MENUNAME, "root1.ReverseMode") as Bool
		Else
			return false
		EndIf
	EndFunction	
EndProperty

; Enable/disable insert mode (insert key toggle)
Bool Property InsertMode Hidden
	Function Set(Bool value)
		If (!isShuttingDown)
			UI.Set(FLASH_MENUNAME, "root1.InsertMode", value)
		EndIf
	EndFunction
	Bool Function Get()
		If (!isShuttingDown)
			return UI.Get(FLASH_MENUNAME, "root1.InsertMode") as Bool
		Else
			return false
		EndIf
	EndFunction
EndProperty

; Enable/disable Terminal local echo (print typed keys to screen)
Bool Property LocalEcho Hidden
	Function Set(Bool value)
		If (!isShuttingDown)
			UI.Set(FLASH_MENUNAME, "root1.ScreenEchoEnable", value)
		EndIf
	EndFunction
	Bool Function Get()
		If (!isShuttingDown)
			return UI.Get(FLASH_MENUNAME, "root1.ScreenEchoEnable") as Bool
		Else
			return false
		EndIf
	EndFunction
EndProperty

String Property PapyrusStringEscapeSequence Hidden
	Function Set(String value)
		If (!isShuttingDown)
			UI.Set(FLASH_MENUNAME, "root1.PapyrusStringEscapeSequence", value)
		EndIf
	EndFunction
	String Function Get()
		If (!isShuttingDown)
			Return UI.Get(FLASH_MENUNAME, "root1.PapyrusStringEscapeSequence") as String
		Else
			Return ""
		EndIf
	EndFunction
EndProperty


; cursor functions

; Move the cursor by row and column number (top left is 1,1)
Function CursorMove(Int row, Int column)
	If (isShuttingDown)
		return
	EndIf

	Var[] args = new Var[2]
	args[0] = row
	args[1] = column
	UI.Invoke(FLASH_MENUNAME, "root1.CursorMovePapyrus", args)
EndFunction

; Move the cursor by character index (zero based "screen memory" address, top left is 0)
Function CursorMoveByIndex(Int index)
	If (isShuttingDown)		
		Var[] args = new Var[1]
		args[0] = index
		UI.Invoke(FLASH_MENUNAME, "root1.CursorMoveByIndex", args)
	EndIf
EndFunction

; Number of screen row the cursor is currently positioned at (first row is 1)
Int Property CursorPositionRow
	Int Function Get()
		If (!isShuttingDown)
			return UI.Get(FLASH_MENUNAME, "root1.CursorCurrentLine") as Int
		Else
			return 0
		EndIf
	EndFunction
EndProperty

; Number of screen column the cursor is currently positioned at (first column is 1)
Int Property CursorPositionColumn
	Int Function Get()
		If (!isShuttingDown)
			return UI.Get(FLASH_MENUNAME, "root1.CursorCurrentColumn") as Int
		Else
			return 0
		EndIf
	EndFunction
EndProperty

; Character index of current cursor position (zero based "screen memory" address, top left is 0)
Int Property CursorPositionIndex
	Int Function Get()
		If (!isShuttingDown)
			return UI.Get(FLASH_MENUNAME, "root1.CursorCurrentIndex") as Int
		Else
			return 0
		EndIf
	EndFunction
EndProperty

; Enable/disable visible cursor rectangle on Terminal screen
Bool Property CursorEnabled Hidden
	Function Set(Bool value)
		If (!isShuttingDown)
			UI.Set(FLASH_MENUNAME, "root1.CursorEnabled", value)
		EndIf
	EndFunction	
	Bool Function Get()
		If (!isShuttingDown)
			return UI.Get(FLASH_MENUNAME, "root1.CursorEnabled") as Bool
		EndIf
	EndFunction
EndProperty



; keyboard functions

; Begin asynchronous ReadLine operation. Completes on ENTER keypress by user. Cancellable by calling ReadAsyncCancel().
; Operation will generate OnPapyrusTerminalReadAsyncCompleted event callback on completion.
Bool Function ReadLineAsyncBegin(Int maxLength = 0)
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
		Var[] args = new Var[1]
		args[0] = maxLength
		return UI.Invoke(FLASH_MENUNAME, "root1.ReadLineAsyncBeginPapyrus", args) as Bool
	
	Else
		; read operation in progress
		Debug.Trace(Self + ": ERROR - ReadLineAsyncBegin() called, but a Read operation is already in progress.")
		return false;

	EndIf
EndFunction

; Begin asynchronous ReadKey operation. Completes as user depresses a key. Cancellable by calling ReadAsyncCancel().
Bool Function ReadKeyAsyncBegin()
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
		Var[] args = new Var[1]
		args[0] = ""
		return UI.Invoke(FLASH_MENUNAME, "root1.ReadKeyAsyncBegin", args) as Bool
	
	Else
		; read operation in progress
		Debug.Trace(Self + ": ERROR - ReadKeyAsyncBegin() called, but a Read operation is already in progres.")
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
		Var[] args = new Var[1]
		args[0] = ""
		UI.Invoke(FLASH_MENUNAME, "root1.ReadAsyncCancel", args)

	Else
		Debug.Trace(Self + ": WARNING - ReadAsyncCancel() called, but no async Read operation was in progress.")

	EndIf
EndFunction

; Synchronously read a line (ends in ENTER keypress) from the Terminal
String Function ReadLine(Int maxLength = 0)
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
		Var[] args = new Var[1]
		args[0] = maxLength
		UI.Invoke(FLASH_MENUNAME, "root1.ReadLineAsyncBeginPapyrus", args)	

		; wait for async result
		While (IsBoundGameObjectAvailable() &&  readMode == READMODE_LINE_SYNC && !readSyncCompleteFlag && !isShuttingDown)
			;Debug.Trace(Self + ": DEBUG - [ReadLine] Waiting for OnReadAsyncResult")	
		
			; WARNING: DO NOT use Utility.Wait() in your Papyrus Terminal scripts!
			; Doing so will suspend execution of your script, because the Terminal Menu is open.
			; Use Utility.WaitMenuMode() instead.
			
			Utility.WaitMenuMode(SYNCREAD_WAIT_INTERVAL)
		EndWhile

		; return async input buffer contents
		return readAsyncBuffer
	Else
		Debug.Trace(Self + ": ERROR - ReadLine() called, but a Read operation is already in progress.")		
		return ""
	EndIf
EndFunction

String Function ReadKey()
	If (isShuttingDown)
		Return "";
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
		Var[] args = new Var[1]
		args[0] = ""
		Bool readAsyncBeginResult = UI.Invoke(FLASH_MENUNAME, "root1.ReadKeyAsyncBegin", args) as Bool
		If (readAsyncBeginResult)
			; wait for read async result
			While (IsBoundGameObjectAvailable() &&  readMode == READMODE_KEY_SYNC && !readSyncCompleteFlag && !isShuttingDown)
				;Debug.Trace(Self + ": DEBUG - [ReadKey] Waiting for OnReadAsyncResult")	
			
				; WARNING: DO NOT use Utility.Wait() in your Papyrus Terminal scripts!
				; Doing so will suspend execution of your script, because the Terminal Menu is open.
				; Use Utility.WaitMenuMode() instead.
				
				Utility.WaitMenuMode(SYNCREAD_WAIT_INTERVAL)
			EndWhile

			If (readSyncCompleteFlag)
				; completed, return async input buffer contents
				Return readAsyncBuffer
			Else
				; aborted, return empty string
				return ""
			EndIf
		Else
			Debug.Trace(Self + ": ERROR - ReadKeyAsyncBegin call failed.")
			return ""
		EndIf	
	Else
		Debug.Trace(Self + ": ERROR - ReadKey() called, but a Read operation is already in progress.")		
		return ""		
	EndIf
EndFunction

; Result event handler for Terminal ReadLine operations
; The Fash Terminal itself can only do async Reads, but the API provides synchronous wrappers ReadKey() and ReadLine()
Function OnReadAsyncResult(string readLineBuffer)
	Debug.Trace(Self + ": DEBUG - OnReadAsyncResult event received.") ;" readLineBuffer=" + readLineBuffer)
	
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
		Debug.Trace(Self + ": WARNING - OnReadAsyncResult event received, but no Read operation was in progress.");
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



; String Utility Functions
String[] Function StringSplit(string line, string separator = " ")
	If (isShuttingDown) 
		string[] retVal = new string[0] 
		return retVal
	EndIf

	Var[] args = new Var[2]
	args[0] = line
	args[1] = separator
	Return Utility.VarToVarArray(UI.Invoke(FLASH_MENUNAME, "root1.StringSplitPapyrus", args)) as string[]
EndFunction

String Function StringCharAt(String line, Int charIndex)
	If (isShuttingDown)
		Return -1
	EndIf

	Var[] args = new Var[2]
	args[0] = line
	args[1] = charIndex
	Return UI.Invoke(FLASH_MENUNAME, "root1.StringCharAtPapyrus", args) as String
EndFunction

Int Function StringCharCodeAt(String line, Int charIndex)
	If (isShuttingDown)
		Return -1
	EndIf

	Var[] args = new Var[2]
	args[0] = line
	args[1] = charIndex
	Return UI.Invoke(FLASH_MENUNAME, "root1.StringCharCodeAtPapyrus", args) as Int	
EndFunction

Int Function StringIndexOf(String line, String part, Int startIndex)
	If (isShuttingDown)
		Return -1
	EndIf

	Var[] args = new Var[3]
	args[0] = line
	args[1] = part
	args[2] = startIndex
	Return UI.Invoke(FLASH_MENUNAME, "root1.StringIndexOfPapyrus", args) as Int		
EndFunction

Int Function StringLastIndexOf(String line, String part, Int startIndex)
	If (isShuttingDown)
		Return -1
	EndIf

	Var[] args = new Var[3]
	args[0] = line
	args[1] = part
	args[2] = startIndex
	Return UI.Invoke(FLASH_MENUNAME, "root1.StringLastIndexOfPapyrus", args) as Int		
EndFunction

String Function StringReplace(String line, String pattern, String replacement)
	If (isShuttingDown)
		Return ""
	EndIf

	Var[] args = new Var[3]
	args[0] = line
	args[1] = pattern
	args[2] = replacement
	Return UI.Invoke(FLASH_MENUNAME, "root1.StringReplacePapyrus", args) as String
EndFunction

String Function StringSlice(String line, Int startIndex, Int endIndex = 0x7fffffff)
	If (isShuttingDown)
		Return ""
	EndIf

	Var[] args = new Var[3]
	args[0] = line
	args[1] = startIndex
	args[2] = endIndex
	Return UI.Invoke(FLASH_MENUNAME, "root1.StringSlicePapyrus", args) as String
EndFunction

String Function StringSubstring(String line, Int startIndex, Int endIndex = 0x7fffffff)
	If (isShuttingDown)
		Return ""
	EndIf

	Var[] args = new Var[3]
	args[0] = line
	args[1] = startIndex
	args[2] = endIndex
	Return UI.Invoke(FLASH_MENUNAME, "root1.StringSubstringPapyrus", args) as String
EndFunction