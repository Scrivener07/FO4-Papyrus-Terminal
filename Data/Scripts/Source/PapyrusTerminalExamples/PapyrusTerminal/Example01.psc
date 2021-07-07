Scriptname PapyrusTerminal:Example01 extends PapyrusTerminal:BIOS

Event OnPapyrusTerminalInitialize(ObjectReference refTerminal)
    ; you can set text replacement tokens for the terminal here.
    ; example syntax:
    ; refTerminal.AddTextReplacementData("TokenName", Message)
EndEvent

Event OnPapyrusTerminalReady()
    ; once you get this event, the terminal is ready to be written to / read from


    ; write some test output to the terminal
	CursorEnabled = false
	ReverseMode = true
	Print("                       CONCORD MUNICIPAL UTILITY                        ")
	ReverseMode = false
	Print("                          Water Supply System")
	CursorMove(4, 1)
	Print("[Local Water Pumps]-----------------------------------------------------")
	PrintLine("     Active:    0                        Supply Rate:   0 Water/day")
	PrintLine("    Damaged:    0                          Unpowered:   1")
	PrintLine("")
	Print("[Settlement Network Next-Day Water Forecast]----------------------------")
	PrintLine("    Linked Settlements: 108")
	PrintLine("    Water Availability: 132118 (PLENTYFUL)")
	PrintLine("")
	Print("[Water Tower Status]----------------------------------------------------")
	PrintLine("    Tower Capacity:  500 Water         Current Level:  250 Water")
	PrintLine("        Fill Valve:       Open        Max. Fill Rate:   50 Water/day")
	PrintLine("                                      Cur. Fill Rate:   50 Water/day")
	PrintLine("      Supply Valve:       Open      Max. Supply Rate:  100 Water/day")
	PrintLine("                                    Cur. Supply Rate:    0 Water/day")
	PrintLine("");
	PrintLine("[Options]-----------------------------------------------------------")
	PrintLine("   [T] : Tower Controls                [D] : Damage Report")
	PrintLine("   [P] : Pump Controls               [TAB] : Back to Main Menu")
	PrintLine("")
	Print("> ")
	CursorEnabled = true
EndEvent

Event OnPapyrusTerminalShutdown()
    ; if you get this event, the terminal has been shut down (user left holotape with tab, ctrl-c or by some other means)
	; your script should perform any necessary clean-up duty upon receiving this event, so that it may terminate properly.
	; NOTE: The Terminal is already gone when this event occurs. DO NOT interact with it in this event handler or suffer a CTD!
EndEvent
