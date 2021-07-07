Scriptname PapyrusTerminal:KERNAL extends ObjectReference Native Const Hidden

; Papyrus Terminal KERNAL
; This defines Papyrus events that will be available to Scripts implementing the BIOS class
; You do not need to worry about this; Just extend from BIOS in your script.

; custom scripting by niston & Scrivener07

; Terminal is ready for Papyrus interaction
Event OnPapyrusTerminalReady()
	; must override in derived class
	Debug.Trace(Self + ": ERROR - OnPapyrusTerminalReady() called on BIOS class. This happens in error and the terminal script won't work. Your script must extend the BIOS class instead.")
EndEvent

; Terminal was shut down, used for clean-up purposes
Event OnPapyrusTerminalShutdown()
	; must override in derived class
	Debug.Trace(Self + ": ERROR - OnPapyrusTerminalShutdown() called on BIOS class. This happens in error and the terminal script clean-up won't work. Your script must extend the BIOS class instead.")
EndEvent

; Terminal is initializing, used to set text replacement token data
Event OnPapyrusTerminalInitialize(ObjectReference refTerminal) Native

; Async Terminal ReadLine operation completed.
Event OnPapyrusTerminalReadAsyncCompleted(String readBuffer) Native

; Async Terminal ReadLine operation was cancelled
Event OnPapyrusTerminalReadAsyncCancelled() Native
