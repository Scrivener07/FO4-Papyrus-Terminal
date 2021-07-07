Scriptname Computer:Holotape extends ObjectReference Native Const Hidden
{This class defines Papyrus events that will be available to Scripts extending this class.
You do not need to worry about this. Just extend from BIOS in your script.}
; Custom scripting by niston & Scrivener07

; Instance
;---------------------------------------------

Group Alignment
	int Property ALIGNMENT_LEFT Hidden
		int Function Get()
			return 0
		EndFunction
	EndProperty
	int Property ALIGNMENT_CENTER Hidden
		int Function Get()
			return 1
		EndFunction
	EndProperty
	int Property ALIGNMENT_RIGHT Hidden
		int Function Get()
			return 2
		EndFunction
	EndProperty
EndGroup

Group Terminal
	bool Property TerminalShutdown Hidden
		bool Function Get()
			return false
		EndFunction
	EndProperty
EndGroup

Group Menus
	string Property TerminalHolotapeMenu Hidden
		{The vanilla holotape menu used with Terminals.}
		string Function Get()
			return "TerminalHolotapeMenu"
		EndFunction
	EndProperty

	string Property PipboyHolotapeMenu Hidden
		{The vanilla holotape menu used with Pipboys.}
		string Function Get()
			return "PipboyHolotapeMenu"
		EndFunction
	EndProperty

	string Property FlashMenu Hidden
		{Returns the current menu name which supports either Terminals or Pipboys.
		When neither menu is open, an empty string is returned.}
		string Function Get()
			If (UI.IsMenuOpen(TerminalHolotapeMenu))
				return TerminalHolotapeMenu
			ElseIf (UI.IsMenuOpen(PipboyHolotapeMenu))
				return PipboyHolotapeMenu
			Else
				return ""
			EndIf
		EndFunction
	EndProperty
EndGroup


; Holotape
;---------------------------------------------

; Occurs when the terminal is initializing.
; This may be used to set text replacement token data.
Event OnInitialize(ObjectReference refTerminal) Native

; Occurs when the terminal is ready for Papyrus interaction.
Event OnStartup(bool a) Native
Function RegisterForStartup() Native
Function UnregisterForStartup() Native

; Occurs when the terminal was shut down, used for clean-up purposes.
Event OnShutdown() Native
Function RegisterForShutdown() Native
Function UnregisterForShutdown() Native

; Terminal
;---------------------------------------------

Function GetTerminalRows() Native
Function GetTerminalColumns() Native
Function GetQuitOnTABEnabled() Native
Function End() Native

; Screen
;---------------------------------------------

; Print characters to screen
Function Print(string charsToPrint) Native

; Print line to screen (appends LF at the end)
Function PrintLine(string lineToPrint = "") Native

Function Clear() Native
Function ClearHome() Native

Function GetReverseMode() Native
Function SetReverseMode() Native

Function GetInsertMode() Native
Function SetInsertMode() Native

Function GetLocalEcho() Native
Function SetLocalEcho() Native

Function GetPapyrusStringEscapeSequence() Native
Function SetPapyrusStringEscapeSequence() Native

; Cursor
;---------------------------------------------

Function CursorMove() Native
Function CursorMoveByIndex() Native

Function GetCursorPositionRow() Native
Function GetCursorPositionColumn() Native
Function GetCursorPositionIndex() Native

Function GetCursorEnabled() Native
Function SetCursorEnabled(bool enabled = true) Native

; Keyboard
;---------------------------------------------

Function ReadLineAsyncBegin() Native
Function ReadKeyAsyncBegin() Native
Function ReadAsyncCancel() Native

string Function ReadLine() Native
string Function ReadKey() Native

Function OnReadAsyncResult() Native

; Async Terminal ReadLine operation was cancelled
Event OnReadAsyncCancelled() Native

; Async Terminal ReadLine operation completed.
Event OnReadAsyncCompleted(String readBuffer) Native


; Other
;---------------------------------------------

Function Sleep() Native
Function Dispatch() Native
Function AddArg() Native
