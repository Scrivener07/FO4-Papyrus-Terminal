Scriptname PapyrusTerminal:Example02 extends PapyrusTerminal:BIOS

Event OnPapyrusTerminalInitialize(ObjectReference refTerminal)
    ; you can optoinally set text replacement tokens for the terminal here.
    ; NOTE: text replacement won't work on the PipBoy; refTerminal will be none (game limitation).
    ; example syntax:
    ; refTerminal.AddTextReplacementData("TokenName", Message)
EndEvent

Event OnPapyrusTerminalReady()
    ; once you get this event, the terminal is ready to be written to / read from
    ; ReadLine example
    PrintLine("What is your name?")
    Print (" > ")
    ; enable the cursor
    CursorEnabled = true
	; synchronous ReadLine() call reads an entire line (user must end input with ENTER key) from the keyboard
    String readName = ReadLine(20)
    ; disable cursor
    CursorEnabled = false
    ; disable Terminal local echo
    LocalEcho = false
    ; clear screen and move cursor to home (1, 1)
    ClearHome()
    ; reprint name that was entered and show notice to quit
    PrintLine("HELLO " + readName + "!")
    PrintLine("Press TAB or CTRL-C, or any other key to quit this program.")    
    string[] test = StringSplit("blah blah blah")
    ;string full = test[0] + ":" + test[1] + ":" + test[2]
    ; synchronous ReadKey() call reads a single character/keypress from the keyboard
    String keyPress = ReadKey()        
    ; end terminal session (close terminal)
    End()
EndEvent

Event OnPapyrusTerminalShutdown()
    ; if you get this event, the terminal has shut down (user left holotape with tab, ctrl-c or by some other means)
    ; your script should perform any necessary clean-up duty upon receiving this event, so that it may terminate properly.
EndEvent