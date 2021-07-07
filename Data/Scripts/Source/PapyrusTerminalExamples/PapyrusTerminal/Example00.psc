Scriptname PapyrusTerminal:Example00 extends PapyrusTerminal:BIOS

Event OnPapyrusTerminalReady()
	int bonks = 0
	While (true)
		bonks += 1
		PrintLine("BONK! You have been 'bonked' "+bonks+" times.")
	EndWhile
	; Press CTRL-C in Terminal to ruin everything!
EndEvent
