ScriptName Computer:Terminal extends Terminal
{DEV-ONLY}

string TerminalMenu = "TerminalMenu" const
string TerminalMenuButtons = "TerminalMenuButtons" const
string TerminalHolotapeMenu = "TerminalHolotapeMenu" const

string PipboyMenu = "PipboyMenu" const
string PipboyHolotapeMenu = "PipboyHolotapeMenu" const

string MessageBoxMenu = "MessageBoxMenu" const
string CursorMenu = "CursorMenu" const

; Events
;---------------------------------------------

Event OnInit()
	RegisterForMenuOpenCloseEvent(TerminalMenu)
	RegisterForMenuOpenCloseEvent(TerminalMenuButtons)
	RegisterForMenuOpenCloseEvent(TerminalHolotapeMenu)
	RegisterForMenuOpenCloseEvent(PipboyMenu)
	RegisterForMenuOpenCloseEvent(PipboyHolotapeMenu)
	RegisterForMenuOpenCloseEvent(MessageBoxMenu)
	RegisterForMenuOpenCloseEvent(CursorMenu)
EndEvent


Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
	Debug.TraceSelf(self, "OnMenuOpenCloseEvent", "asMenuName:"+asMenuName+", abOpening:"+abOpening)
EndEvent


Event OnMenuItemRun(int auiMenuItemID, ObjectReference akTerminalRef)
	Debug.TraceSelf(self, "OnMenuItemRun", "auiMenuItemID:"+auiMenuItemID+", akTerminalRef:"+akTerminalRef)
EndEvent
