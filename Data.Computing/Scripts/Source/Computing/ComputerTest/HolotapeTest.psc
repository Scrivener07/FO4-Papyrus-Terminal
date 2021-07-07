ScriptName ComputerTest:HolotapeTest extends Computer:Holotape
{DEV-ONLY}

; https://www.creationkit.com/fallout4/index.php?title=GetBaseObject_-_ObjectReference
; https://www.creationkit.com/fallout4/index.php?title=GetItemCount_-_ObjectReference
; https://www.creationkit.com/fallout4/index.php?title=GetContainer_-_ObjectReference


Actor Property Player Hidden
	Actor Function Get()
		return Game.GetPlayer()
	EndFunction
EndProperty

string TERMINAL_MENUNAME = "TerminalHolotapeMenu" const
string PIPBOY_MENUNAME = "PipboyHolotapeMenu" const


; Events
;---------------------------------------------

Event OnInit()
	Debug.TraceSelf(self, "OnInit", "ctor")
	RegisterForStartup()
	RegisterForShutdown()
	RegisterForMenuOpenCloseEvent(TERMINAL_MENUNAME)
	RegisterForMenuOpenCloseEvent(PIPBOY_MENUNAME)
	; Dump("OnInit")
EndEvent

Event OnHolotapePlay(ObjectReference refTerminal)
	Debug.TraceSelf(self, "OnHolotapePlay", "refTerminal:"+refTerminal)
	; Dump("OnHolotapePlay")
EndEvent

Event OnMenuOpenCloseEvent(string menuName, bool opening)
	Debug.TraceSelf(self, "OnMenuOpenCloseEvent", "menuName:"+menuName + ", opening:"+opening)
	; Dump("OnMenuOpenCloseEvent")
EndEvent


Event OnInitialize(ObjectReference refTerminal)
	Debug.TraceSelf(self, "OnInitialize", "refTerminal:"+refTerminal)
EndEvent

Event OnStartup(bool a)
	Debug.TraceSelf(self, "OnStartup", "a:"+a)
	Print("Print: ")
	PrintLine("Hello Startup")
	string line = ReadLine()
	Debug.TraceSelf(self, "OnStartup", "ReadLine(): '"+line+"'")
EndEvent

Event OnShutdown()
	Debug.TraceSelf(self, "OnShutdown", "ctor")
EndEvent


; Methods
;---------------------------------------------

Function Dump(string caller) DebugOnly
	If (self != none)
		Form object = self.GetBaseObject()
		Debug.TraceSelf(self, caller+"-> this::Dump", "---------------------------------------------")
		Debug.TraceSelf(self, caller+"-> this::Dump", "FormID: "+object.GetFormID())
		Debug.TraceSelf(self, caller+"-> this::Dump", "DisplayName: "+self.GetDisplayName())
		Debug.TraceSelf(self, caller+"-> this::Dump", "Player::ItemCount:"+Player.GetItemCount(self))

		ObjectReference contained = self.GetContainer()
		If (contained != none)
			Debug.TraceSelf(self, caller+"-> this::Dump", "Container:"+contained)
			Debug.TraceSelf(self, caller+"-> this::Dump", "Container::FormID:"+contained.GetFormID())
			Debug.TraceSelf(self, caller+"-> this::Dump", "Container::DisplayName:"+contained.GetDisplayName())
			Debug.TraceSelf(self, caller+"-> this::Dump", "Container::ItemCount:"+contained.GetItemCount(self))
		Else
			Debug.TraceSelf(self, caller+"-> this::Dump", "Container: NONE")
		EndIf

		Debug.TraceSelf(self, caller+"-> this::Dump", "---------------------------------------------")
	Else
		Debug.Trace(caller+"-> this::Dump(): The 'self' variable is none.")
	EndIf
EndFunction
