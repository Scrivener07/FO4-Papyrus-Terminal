ScriptName Computer:Terminal extends Terminal
{DEV-ONLY}

string TerminalMenu = "TerminalMenu" const
string TerminalHolotapeMenu = "TerminalHolotapeMenu" const
string PipboyMenu = "PipboyMenu" const
string MessageBoxMenu = "MessageBoxMenu" const


; Events
;---------------------------------------------

Event OnInit()
	RegisterForMenuOpenCloseEvent(TerminalMenu)
	RegisterForMenuOpenCloseEvent(TerminalHolotapeMenu)
	RegisterForMenuOpenCloseEvent(PipboyMenu)
	RegisterForMenuOpenCloseEvent(MessageBoxMenu)
EndEvent


Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
	Debug.TraceSelf(self, "OnMenuOpenCloseEvent", "asMenuName:"+asMenuName+", abOpening:"+abOpening)
EndEvent


Event OnMenuItemRun(int auiMenuItemID, ObjectReference akTerminalRef)
	Debug.TraceSelf(self, "OnMenuItemRun", "auiMenuItemID:"+auiMenuItemID+", akTerminalRef:"+akTerminalRef)
EndEvent
