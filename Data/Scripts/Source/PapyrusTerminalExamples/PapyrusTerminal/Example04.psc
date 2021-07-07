Scriptname PapyrusTerminal:Example04 extends PapyrusTerminal:BIOS

; Provisioner Diagnostics v0.1
; Fully working example application for the Papyrus Terminal
; custom scripting by niston

RefCollectionAlias Property CaravanActors Auto Const
RefCollectionAlias Property Workshops Auto Const
AIPackageDescriptor[] Property AIPackageDescriptors Auto Const

Keyword kwdWorkhopLinkCaravanStart
Keyword kwdWorkshopLinkCaravanEnd
ActorValue avWorkshopRatingProvisioner
ActorValue avWorkshopActorWounded
WorkshopParentScript scrWorkshopParent

Event OnPapyrusTerminalReady()

    ; configure terminal
    InsertMode = false
    LocalEcho = false

    ; load dynamic forms
    kwdWorkhopLinkCaravanStart = Game.GetForm(0x66eae) as Keyword
    kwdWorkshopLinkCaravanEnd = Game.GetForm(0x66eaf) as Keyword
    avWorkshopRatingProvisioner = Game.GetForm(0x249e4a) as ActorValue        
    avWorkshopActorWounded = Game.GetForm(0x33b) as ActorValue    
    kwdWorkhopLinkCaravanStart = Game.GetForm(0x66eae) as Keyword
    kwdWorkshopLinkCaravanEnd = Game.GetForm(0x66eaf) as Keyword
    avWorkshopRatingProvisioner = Game.GetForm(0x249e4a) as ActorValue        
    avWorkshopActorWounded = Game.GetForm(0x33b) as ActorValue
    scrWorkshopParent = Game.GetForm(0x2058E) as WorkshopParentScript
    
    NaviProvisionerListFirst()
EndEvent

Event OnPapyrusTerminalShutdown()
    ; if you get this event, the terminal has shut down (user left holotape with tab, ctrl-c or by some other means)
    ; your script should unregister for all events and perform any necessary clean-up duty upon receiving this event,
    ; so that it may terminate properly.
    ; NOTE: The Terminal is already gone when this event occurs.
    ; DO NOT interact with the terminal in this event handler, or suffer a CTD!

    kwdWorkhopLinkCaravanStart = none
    kwdWorkshopLinkCaravanEnd = none
    avWorkshopRatingProvisioner = none
    avWorkshopActorWounded = none
    kwdWorkhopLinkCaravanStart = none
    kwdWorkshopLinkCaravanEnd = none
    avWorkshopRatingProvisioner = none
    avWorkshopActorWounded = none
    scrWorkshopParent = none    
EndEvent



; ##########################
; #### PROVISIONER LIST ####
; ##########################

Function MenuProvisionerList(Int startIndex)
    ; prepare screen
    ClearHome()
    PrintProgramHeader()
    PrintProvisionerListHeader()    
    
    int pageHeight = TerminalRows - 7
    
    ; generate list view
    Int lastIndex = PrintProvisionerListEntries(startIndex)        
    
    ; prompt user
    PrintLine("")
    PrintLine("## Provisioner number, [n]ext/[p]rev or Ctrl-C to quit.")
    Print("> ")
    
    ; read from keyboard
    CursorEnabled = true
    LocalEcho = true
    String pgOption = ReadLine(3)
    CursorEnabled = false
    LocalEcho = false

    ; process user input
    If (StringIsNumeric(pgOption))
        ; entered a number, assume provisioner index and sanitize
        Int provisionerIndex = pgOption as Int
        If (provisionerIndex < 0)
            provisionerIndex = 0
        EndIf
        If (provisionerIndex > CaravanActors.GetCount() - 1)
            provisionerIndex = CaravanActors.GetCount() - 1
        EndIf
        ; show details menu for selcted provisioner
        NaviProvisionerDetails(CaravanActors.GetAt(provisionerIndex) as ObjectReference)
    Else
        If (pgOption == "F")                
            NaviProvisionerListFirst()
        ElseIf (pgOption == "L")
            NaviProvisionerListLast(pageHeight)
        ElseIf (pgOption == "P")
            NaviProvisionerListPrevious(startIndex, pageHeight)
        ElseIf (pgOption == "N")
            NaviProvisionerListNext(lastIndex)
        Else
            ; refresh current page
            NaviProvisionerList(startIndex)
        EndIf
    EndIf
EndFunction

; print provisioner list entries
Int Function PrintProvisionerListEntries(Int startIndex)
    Int i = startIndex
    String listEntry = ""
    ObjectReference refProvisioner = none
    While (i < CaravanActors.GetCount() && !TerminalShutdown && !PageFull(3))
        
        refProvisioner = CaravanActors.GetAt(i) as ObjectReference   
        PrintField(i, 3, ALIGNMENT_RIGHT)
        Print("  ")
        PrintField(GetProvisionerRoute(refProvisioner), 58, ALIGNMENT_LEFT)
        Print("  " + GetProvisionerWarningFlags(refProvisioner))
        i += 1
    EndWhile
    Return i
EndFunction    

Function NaviProvisionerList(int startIndex)
    If (!TerminalShutdown)
        var[] parms = new var[1]
        parms[0] = startIndex
        CallFunctionNoWait("MenuProvisionerList", parms)
    EndIf
EndFunction

Function NaviProvisionerListFirst()
    Dispatch("MenuProvisionerList", 0)
EndFunction

Function NaviProvisionerListLast(int pageHeight)
    Int lastPageStartIndex = (CaravanActors.GetCount() - 1) - pageHeight
    Dispatch("MenuProvisionerList", lastPageStartIndex)
EndFunction

Function NaviProvisionerListNext(int currentLastIndex)    
    Int nextStartIndex = currentLastIndex + 1
    If (nextStartIndex > CaravanActors.GetCount() - 1)
        nextStartIndex = CaravanActors.GetCount() - 1
    EndIf
    Dispatch("MenuProvisionerList", nextStartIndex)
EndFunction

Function NaviProvisionerListPrevious(int currentFirstIndex, int pageHeight)
    Int nextStartIndex = currentFirstIndex - pageHeight - 1
    If (nextStartIndex < 0)
        nextStartIndex = 0
    EndIf
    Dispatch("MenuProvisionerList", nextStartIndex)
EndFunction

Function PrintProvisionerListHeader()    
    Print("No.  Route                                                      Warnings")
    Print("------------------------------------------------------------------------")
EndFunction 

Bool Function PageFull(Int linesToPrint)
    If (CursorPositionRow + linesToPrint > TerminalRows)
        Return true
    EndIf
    Return false
EndFunction



; #############################
; #### PROVISIONER DETAILS ####
; #############################

Function MenuProvisionerDetails(ObjectReference refProvisioner)
    If (TerminalShutdown)
        Return
    EndIf

    ; prepare screen
    ClearHome()
    PrintProgramHeader()

    ; local vars
    Actor actProvisioner = refProvisioner as Actor
    Location lctRouteOrigin = refProvisioner.GetLinkedRef(kwdWorkhopLinkCaravanStart).GetCurrentLocation()
    Location lctRouteDest = refProvisioner.GetLinkedRef(kwdWorkshopLinkCaravanEnd).GetCurrentLocation()    
    Form frmXMarker = Game.GetForm(0x3b)
    ObjectReference refPosMarker = none

    PrintLine("Details for Provisioner #" + CaravanActors.Find(refProvisioner))
    Print("------------------------------------------------------------------------")
    PrintField("Name: " + refProvisioner.GetDisplayName(), 52, ALIGNMENT_LEFT)
    Print("  ")
    PrintField("Warnings: " + GetProvisionerWarningFlags(refProvisioner), 18, ALIGNMENT_RIGHT)    
    Print("From: ")
    PrintField(GetLocationName(lctRouteOrigin), 66, ALIGNMENT_LEFT)
    Print("  To: ")
    PrintField(GetLocationName(lctRouteDest), 66, ALIGNMENT_LEFT)
    PrintLine()                
    PrintLine("  Workshop: " + GetHomeRef(refProvisioner))        
    Print(" Essential: " + YesNoBool(actProvisioner.IsEssential()) + "      ")
    Print("Protected Base: " + YesNoBool(actProvisioner.GetActorBase().IsProtected()) + "      ")
    PrintLine("Companionscript: " + YesNoBool((refProvisioner as CompanionActorScript) != none))        
    PrintLine("      Race: " + actProvisioner.GetRace().GetName() + " (" + GetFormIDStr(actProvisioner.GetRace()) + ")") 
    PrintLine("AI Package: " + GetCurrentAIPackageName(actProvisioner))
    PrintLine("  Location: " + GetLocationDescription(refProvisioner)) 
    PrintLine("Pos. X/Y/Z: " + refProvisioner.GetPositionX() + " / " +  refProvisioner.GetPositionY() + " / " + refProvisioner.GetPositionZ())
    PrintLine()
    Print(" Reference: " + GetFormIDStr(refProvisioner as Form) + "    ")
    PrintLine("Base Class: " + GetFormIDStr(actProvisioner.GetBaseObject()))
    PrintLine()
    PrintLine("Options:")
    PrintLine("   [R] : Reset AI            [C] : Cycle Alias            [S] : Summon")                
    PrintLine("   [M] : Show OMods          [I] : Inventory              [K] : Kill")
    PrintLine("   [U] : Update Display      ---                          [X] : Back")
    String selectedOption = ReadKey()    
    int i = 0
    If (selectedOption == "x")
        NaviProvisionerList(CaravanActors.Find(refProvisioner))
    ElseIf (selectedOption == "i")
        Print("## Listing Inventory...")
        ClearHome()
        PrintProgramHeader()
        PrintLine("Inventory for Provisioner #" + CaravanActors.Find(refProvisioner))
        Print("------------------------------------------------------------------------")
        Form[] inventoryItems = refProvisioner.GetInventoryItems()
        i = 0
        While (i < inventoryItems.Length && !TerminalShutdown)
            PrintField(i, 2, ALIGNMENT_RIGHT)
            Print("  ")
            PrintLine(inventoryItems[i] + " " + inventoryItems[i].GetName())
            i += 1
        EndWhile
        PrintLine()
        PrintLine("## SPACE to return to details view, Ctrl-C to quit.")
        ReadKey()
        NaviProvisionerDetails(refProvisioner)
    ElseIf (selectedOption == "u")
        NaviProvisionerDetails(refProvisioner)
    ElseIf (selectedOption == "r")
        Print("## Resetting AI... ")  
        ; remember where they are
        refPosMarker = refProvisioner.PlaceAtMe(frmXMarker, 1, true, false, false)
        ; move them to us so they are fully loaded
        refProvisioner.MoveTo(Game.GetPlayer())
        ; reset AI
        actProvisioner.EvaluatePackage(true)
        Sleep(1.0)
        ; send them back to where they were
        refProvisioner.MoveTo(refPosMarker)
        Sleep(0.1)
        ; clean up
        refPosMarker.Delete()
        Print("OK.")
        NaviProvisionerDetails(refProvisioner)
    ElseIf (selectedOption == "s")
        Print("## Summoning Provisioner to Player position... ")
        refProvisioner.MoveTo(Game.GetPlayer())
        Print("OK.")
        NaviProvisionerDetails(refProvisioner)
    ElseIf (selectedOption == "k")
        Print("## Kill Provisioner - Sure (Y/N) ? ")
        If (ReadKey() == "y")
            PrintLine("Y")
            Print("## Killing provisioner...")
            ; kill them dead, even if essential/protected
            ; they will get unassigned from workshop, supply lines, etc
            actProvisioner.KillEssential()
            Sleep(1.0)
            ; get rid of their dead body
            actProvisioner.Disable()
            actProvisioner.Delete()
            Print("OK.")
            NaviProvisionerListFirst()
        Else
            Print("N")
            NaviProvisionerDetails(refProvisioner)
        EndIf
    ElseIf (selectedOption == "c")
        Print("## Cycling CaravanActor Alias Membership... ")            
        ; remember where they were
        refPosMarker = refProvisioner.PlaceAtMe(frmXMarker, 1, true, false, false)
        ; move them to us so they are fully loaded
        refProvisioner.MoveTo(Game.GetPlayer())
        ; remove from CaravanActors alias
        CaravanActors.RemoveRef(refProvisioner)
        ; reset AI
        actProvisioner.EvaluatePackage(true)
        Sleep(2.0)
        ; add them to CaravanActors alias
        CaravanActors.AddRef(refProvisioner)
        ; reset AI again
        actProvisioner.EvaluatePackage(true)
        Sleep(2.0)
        ; send them back to where they came from
        refProvisioner.MoveTo(refPosMarker)
        Sleep(0.1)
        ; clean up
        refPosMarker.Delete()
        PrintLine("OK.")
        NaviProvisionerDetails(refProvisioner)
    ElseIf (selectedOption == "m")
        ClearHome()
        PrintProgramHeader()
        PrintLine("OMods List for Provisioner #" + CaravanActors.Find(refProvisioner))
        Print("------------------------------------------------------------------------")
        ObjectMod[] aryMods = refProvisioner.GetAllMods()
        While (i < aryMods.Length && !TerminalShutdown)
            PrintField(i, 2, ALIGNMENT_RIGHT)
            Print(" ")
            PrintLine(aryMods[i].GetName() + " (" + GetFormIDStr(aryMods[i]) + ") ")
            i += 1
        EndWhile
        PrintLine()
        PrintLine("## SPACE to return to details view, Ctrl-C to quit.")
        ReadKey()
        NaviProvisionerDetails(refProvisioner)
    ;/ ElseIf (selectedOption == "b")
        Print("## Rebuilding Actor...")
        ; remember where they were
        refPosMarker = refProvisioner.PlaceAtMe(frmXMarker, 1, true, false, false)
        ActorBase actbProvisioner = actProvisioner.GetActorBase()
        Race origRace = actProvisioner.GetRace()
        Keyword[] origKeywords = refProvisioner.GetKeywords()     
        ObjectMod[] origOMods = refProvisioner.GetAllMods()       
        ObjectReference refClone = Game.GetPlayer().PlaceAtMe(actbProvisioner, 1, false, false, false)
        Actor actClone = refClone as Actor
        i = 0
        While (i < origOMods.Length)
            refClone.AttachMod(origOMods[i])
            i += 1
        EndWhile
        ;actClone.SetProtected(true)    

        Int workshopId = (refProvisioner as WorkshopNPCScript).GetWorkshopID()
        ObjectReference refHomeWorkshop = scrWorkshopParent.GetWorkshop(workshopID)
        scrWorkshopParent.AddActorToWorkshopPUBLIC(refClone as Actor, refHomeWorkshop as WorkshopScript)

        ; clean up
        refPosMarker.Delete()
        Print("OK.")
        ReadKey()
        ChangeState("ProvisionerDetailsPage_Refresh")            
/;
    Else
        If (!TerminalShutdown)
            NaviProvisionerDetails(refProvisioner)
        EndIf
    EndIf        
EndFunction

Function NaviProvisionerDetails(ObjectReference refProvisioner)
    If (!TerminalShutdown)
        var[] parms = new var[1]
        parms[0] = refProvisioner
        CallFunctionNoWait("MenuProvisionerDetails", parms)
    EndIf
EndFunction


; ##########################
; #### SHARED FUNCTIONS ####
; ##########################

Function PrintProgramHeader()
    ReverseMode = true    
    String genInfo = scrWorkshopParent.Workshops.Length + " Workshops / " + CaravanActors.GetCount() + " Provisioners"
    Print("Provisioner Diagnostics v0.1  ")
    PrintField(genInfo, TerminalColumns - (CursorPositionColumn - 1), ALIGNMENT_RIGHT)
    ReverseMode = false
EndFunction

String Function GetLocationText(ObjectReference refProvisioner)
    String provLocation = refProvisioner.GetCurrentLocation()
    String provWorldspace = refProvisioner.GetWorldSpace().GetName()

    If (provLocation != provWorldspace)        
        Return provLocation + " (" + provWorldspace + ")"
    Else
        Return provWorldspace
    EndIf
EndFunction

String Function GetHomeRef(ObjectReference refProvisioner)
    If (refProvisioner != none)
        If (refProvisioner as WorkshopNPCScript)        
            Int workshopId = (refProvisioner as WorkshopNPCScript).GetWorkshopID()
            ObjectReference refWorkshop = scrWorkshopParent.GetWorkshop(workshopID)
            If (refWorkshop != none)
                Location lctWorkshopLocation = refWorkshop.GetCurrentLocation()
                If (lctWorkshopLocation != none)
                    String strWorkshopLocName = lctWorkshopLocation.GetName()
                    If (strWorkshopLocName != "")
                        Return GetFormIDStr(refWorkshop) + " (" + strWorkshopLocName + ")"
                    Else
                        Return GetFormIDStr(refWorkshop) + " (Unnamed Location)"
                    EndIf
                Else
                    Return GetFormIDStr(refWorkshop) + " <Location is None>"
                EndIf
                Return scrWorkshopParent.GetWorkshop(workshopID)
            Else
                Return "<WorkshopId " + workshopId + " does not exist in workshop array>"
            EndIf
        Else
            Return "<Actor has no WorkshopNPCScript>"
        EndIf
    Else
        Return "<Provisioner is None>"
    EndIf
EndFunction

String Function YesNoBool(Bool value)
    If (value)
        Return "Yes"
    Else
        Return "No"
    EndIf
EndFunction

String Function GetLocationDescription(ObjectReference refProvisioner)
    String locName = GetLocationName(refProvisioner.GetCurrentLocation())
    String wsName = refProvisioner.GetWorldSpace().GetName()
    If (locName == wsName)
        Return wsName
    Else
        Return locName + " (" + wsName + ")"
    EndIf
EndFunction

String Function GetWorldspaceName(ObjectReference refObject)
    If (refObject.GetWorldSpace() == none)
        Return "<No Worldspace>"
    Else
        Return "(" + refObject.GetWorldSpace().GetName() + ")"
    EndIf
EndFunction

String Function GetLocationName(Location lctCaravan)
    If (lctCaravan == none)
        Return "<Location is none>"
    Else
        String locName = lctCaravan.GetName()
        If (locName == "")
            Return "<Unnamed Location>"
        Else
            Return locName
        EndIf
    EndIf
EndFunction

String Function FormatRefInfo(String referenceInfo)
    referenceInfo = StringReplace(referenceInfo, "[", "")
    referenceInfo = StringReplace(referenceInfo, " <", " ")
    referenceInfo = StringReplace(referenceInfo, ">]", "")
    Return referenceInfo
EndFunction

String Function GetProvisionerRoute(ObjectReference refProvisioner)
    Location lctRouteOrigin = refProvisioner.GetLinkedRef(kwdWorkhopLinkCaravanStart).GetCurrentLocation()
    Location lctRouteDest = refProvisioner.GetLinkedRef(kwdWorkshopLinkCaravanEnd).GetCurrentLocation()
    Return lctRouteOrigin.GetName() + " > " + lctRouteDest.GetName()
EndFunction

String Function GetProvisionerWarningFlags(ObjectReference refProvisioner)
    Bool wAIPackage = false
    Bool wOrigin = false
    Bool wOriginUnreliable = false
    Bool wDestination = false
    Bool wDestinationUnreliable = false
    Bool wWounded = false
    Bool wBleedout = false
    Bool wDead = false
    Bool wUnconscious = false

    Actor actProvisioner = refProvisioner as Actor
    ObjectReference refOriginMarker = refProvisioner.GetLinkedRef(kwdWorkhopLinkCaravanStart)
    ObjectReference refDestMarker = refProvisioner.GetLinkedRef(kwdWorkshopLinkCaravanEnd)
    Location lctCaravanOrigin = refOriginMarker.GetCurrentLocation()    
    Location lctCaravanDestination = refDestMarker.GetCurrentLocation()
    String strOriginLocName = lctCaravanOrigin.GetName()
    String strOriginWsName
    If (refOriginMarker.GetWorldSpace() != none)
        strOriginWsName = refOriginMarker.GetWorldSpace().GetName()
    Else
        wOriginUnreliable = true
        Debug.Trace(Self + ": WARNING - Origin Center Marker for Location (" + strOriginLocName + ") has no Worldspace!")
    EndIf
    String strDestLocName = lctCaravanDestination.GetName()    
    String strDestWsName 
    If (refDestMarker.GetWorldSpace() != none)
        strDestWsName = refDestMarker.GetWorldSpace().GetName()
    Else
        wDestinationUnreliable = true
        Debug.Trace(Self + ": WARNING - Destination Center Marker for Location (" + strOriginLocName + ") has no Worldspace!")
    EndIf
    
    wAIPackage = ((!CheckPackage(actProvisioner.GetCurrentPackage())) || (!actProvisioner.IsAIEnabled()))
    wOrigin =  (refOriginMarker != none) && (strOriginWsName != "") && ((strOriginLocName == strOriginWsName) || (strOriginLocName == ""))
    wDestination = (refDestMarker != none) && (strDestWsName != "") && ((strDestLocName == strDestWsName) || (strDestLocName == ""))
    wWounded = (actProvisioner.GetValue(avWorkshopActorWounded) > 0)      
    wBleedout = actProvisioner.IsBleedingOut()
    wDead = actProvisioner.IsDead()
    wUnconscious = actProvisioner.IsUnconscious()

    String retVal = ""
    If (wAIPackage)
        retVal += "A"
    Else
        retVal += "-"
    EndIf
    If (wOriginUnreliable)
        retVal += "?"
    Else        
        If (wOrigin)
            retVal += "O"
        Else
            retVal += "-"
        EndIf
    EndIf
    If (wDestinationUnreliable)
        retVal += "?"
    Else
        If (wDestination)
            retVal += "D"
        Else
            retVal += "-"
        EndIf
    EndIf   
    If (wWounded)
        retVal += "W"
    Else
        retVal += "-"
    EndIf
    If (wBleedout)
        retVal += "B"
    Else
        retVal += "-"         
    EndIf
    If (wUnconscious)
        retVal += "U"
    Else
        retVal += "-"         
    EndIf
    If (wDead)
        retVal += "X"
    Else
        retVal += "-"
    EndIf
    return retVal
EndFunction

String Function GetCurrentAIPackageName(Actor actProvisioner)
    If (actProvisioner.IsAIEnabled())
        Return ResolveAIPackageName(actProvisioner.GetCurrentPackage())
    Else
        Return "<AI is currently disabled>"
    EndIf
EndFunction

String Function ResolveAIPackageName(Package aiPackage)
    Int i = 0
    AIPackageDescriptor curDescr = none
    While ((i < AIPackageDescriptors.Length) && !TerminalShutdown)
        curDescr = AIPackageDescriptors[i]
        If (curDescr.AIPackage == aiPackage)
            Return curDescr.PackageName
        EndIf        
        i += 1
    EndWhile
    Return aiPackage
EndFunction

String Function GetFormIDStr(Form frmObject)
    String refInfo = frmObject
    Int startBracketPos = StringLastIndexOf(refInfo, "(")
    If (startBracketPos > -1)
        String idPart = StringSubstring(refInfo, startBracketPos + 1)
        idPart = StringReplace(idPart, ")>]", "")
        Return idPart
    Else
        Return refInfo
    EndIf
EndFunction

Bool Function CheckPackage(Package aiPackage)
    Int i = 0
    AIPackageDescriptor curDescr = none
    While (i < AIPackageDescriptors.Length && !TerminalShutdown)
        curDescr = AIPackageDescriptors[i]
        If (curDescr.AIPackage == aiPackage)
            Return curDescr.PackageOK
        EndIf        
        i += 1
    EndWhile
    Return False
EndFunction

Struct AIPackageDescriptor
    Package AIPackage
    String PackageName
    Bool PackageOK
EndStruct