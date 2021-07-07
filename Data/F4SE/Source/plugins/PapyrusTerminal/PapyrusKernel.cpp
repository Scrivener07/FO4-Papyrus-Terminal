#include "PapyrusKernel.h"
#include "HolotapeProgram.h"
#include "Menu.h"
#include "f4se/PapyrusArgs.h"
#include "f4se/PapyrusEvents.h"
#include "f4se/PapyrusNativeFunctions.h"
#include "f4se/ScaleformCallbacks.h"
//---------------------------------------------

RegistrationSetHolder<NullParameters> StartupEventRegs{};
RegistrationSetHolder<NullParameters> ShutdownEventRegs{};


namespace SNE
{
	const char* SNE::KernelScript::SCRIPTNAME = "Computer:Holotape";


	#pragma region Startup

	void SNE::KernelScript::RegisterForStartup(VMObject* self)
	{
		if (!self) { return; }
		UInt64 handle = self->GetHandle();
		BSFixedString objectType = self->GetObjectType();
		StartupEventRegs.Register(handle, objectType);

		_MESSAGE("SNE::KernelScript::RegisterForStartup");
		_MESSAGE("-->Handle: %i", handle);
		_MESSAGE("-->ObjectType: %s", objectType.c_str());
		_MESSAGE("-->TypeID: %i", self->kTypeID);
	}


	void SNE::KernelScript::UnregisterForStartup(VMObject* self)
	{
		if (!self) { return; }
		UInt64 handle = self->GetHandle();
		BSFixedString objectType = self->GetObjectType();
		StartupEventRegs.Unregister(handle, objectType);

		_MESSAGE("SNE::KernelScript::UnregisterForStartup");
		_MESSAGE("-->Handle: %i", handle);
		_MESSAGE("-->ObjectType: %s", objectType.c_str());
		_MESSAGE("-->TypeID: %i", self->kTypeID);
	}


	void SNE::KernelScript::SendEventStartup()
	{
		_MESSAGE("SNE::KernelScript::SendEventStartup");
		_MESSAGE("-->StartupEventRegs.m_data.size: %i", StartupEventRegs.m_data); // (collection) std::set

		// TODO: Figure out how to send an event with no parameters.
		// It might be that you simply use CallFunctionNoWait if no parameters are needed.
		bool argument1 = true;

		// TODO: Filter which script instances get this event.
		StartupEventRegs.ForEach
		(
			[&argument1]
			(const EventRegistration<NullParameters>& registration)
			{
				_MESSAGE("-->@EventRegistration");
				_MESSAGE("   +--handle: '%i'", registration.handle);
				_MESSAGE("   +--scriptName: '%s'", registration.scriptName.c_str());
				SendPapyrusEvent1<bool>(registration.handle, registration.scriptName, BSFixedString("OnStartup"), argument1);
			}
		);
	}

	#pragma endregion


	#pragma region Shutdown

	void SNE::KernelScript::RegisterForShutdown(VMObject* self)
	{
		_MESSAGE("SNE::KernelScript::RegisterForShutdown");
		if (!self) { return; }
		ShutdownEventRegs.Register(self->GetHandle(), self->GetObjectType());
	}

	void SNE::KernelScript::UnregisterForShutdown(VMObject* self)
	{
		_MESSAGE("SNE::KernelScript::UnregisterForShutdown");
		if (!self) { return; }
		ShutdownEventRegs.Unregister(self->GetHandle(), self->GetObjectType());
	}

	void SNE::KernelScript::SendEventShutdown()
	{
		_MESSAGE("SNE::KernelScript::SendEventShutdown");
		_MESSAGE("-->ShutdownEventRegs.m_data.size: %i", ShutdownEventRegs.m_data); // (collection) std::set

		// TODO: Filter which script instances get this event.
		const EventRegistration<NullParameters> * registered = nullptr;
		StartupEventRegs.ForEach
		(
			[&registered]
			(const EventRegistration<NullParameters>& registration)
			{
				_MESSAGE("-->@EventRegistration");
				_MESSAGE("   +--handle: '%i'", registration.handle);
				_MESSAGE("   +--scriptName: '%s'", registration.scriptName.c_str());
				registered = &registration;
				//return;
			}
		);

		if (registered)
		{
			_MESSAGE("SNE::KernelScript::SendEventShutdown: Sending...");
			bool argument1 = true;
			SendPapyrusEvent1<bool>(registered->handle, registered->scriptName, BSFixedString("OnShutdown"), argument1);
			//CallFunctionNoWait((*g_gameVM)->m_virtualMachine, BSFixedString("OnShutdown"), arrayArg);
		}
		else
		{
			_MESSAGE("SNE::KernelScript::SendEventShutdown: No valid event registrations.");
		}
	}

	#pragma endregion

	#pragma region Terminal

	// Number of text rows in the current Terminal display mode.
	void SNE::KernelScript::TerminalRows_PropertyGet(VMObject* self)
	{
		_MESSAGE("SNE::KernelScript::TerminalRows_PropertyGet");
		//return UI.Get(FlashMenu, "root1.TerminalLines") as int
	}

	// Number of text columns in the current Terminal display mode.
	void SNE::KernelScript::TerminalColumns_PropertyGet(VMObject* self)
	{
		_MESSAGE("SNE::KernelScript::TerminalColumns_PropertyGet");
		//return UI.Get(FlashMenu, "root1.TerminalColumns") as int
	}


	// Enable or disable leaving Terminal by pressing TAB key.
	// This is useful for making menus with submenus, or when you want to react to TAB.
	void SNE::KernelScript::QuitOnTABEnabled_PropertyGet(VMObject* self)
	{
		_MESSAGE("SNE::KernelScript::QuitOnTABEnabled_PropertyGet");
		//return UI.Get(FlashMenu, "root1.QuitOnTABEnable") as bool
	}
	void SNE::KernelScript::QuitOnTABEnabled_PropertySet(VMObject* self, bool value)
	{
		_MESSAGE("SNE::KernelScript::QuitOnTABEnabled_PropertySet");
		//UI.Set(FlashMenu, "root1.QuitOnTABEnable", value)
	}


	// End the terminal session (exit holotape)
	void SNE::KernelScript::End(VMObject* self)
	{
		_MESSAGE("SNE::KernelScript::End");
		//var[] args = new var[1]
		//args[0] = true
		//UI.Invoke(FlashMenu, "root1.End", args)
	}

	#pragma endregion

	#pragma region Screen

	void SNE::KernelScript::Print(VMObject* self, BSFixedString value)
	{
		_MESSAGE("SNE::KernelScript::Print");
		if (!self) { return; }

		//var[] args = new var[1]
		//args[0] = charsToPrint
		//UI.Invoke(FlashMenu, "root1.PrintPapyrus", args)
	}


	void SNE::KernelScript::PrintLine(VMObject* self, BSFixedString value)
	{
		_MESSAGE("SNE::KernelScript::PrintLine");
		if (!self) { return; }

		//var[] args = new var[1]
		//args[0] = lineToPrint
		//UI.Invoke(FlashMenu, "root1.PrintLinePapyrus", args)
	}


	void SNE::KernelScript::Clear(VMObject* self)
	{
		_MESSAGE("SNE::KernelScript::Clear");
		//var[] args = new var[1]
		//args[0] = false
		//UI.Invoke(FlashMenu, "root1.ClearScreenPapyrus", args)
	}


	void SNE::KernelScript::ClearHome(VMObject* self)
	{
		_MESSAGE("SNE::KernelScript::ClearHome");
		//var[] args = new var[1]
		//args[0] = true
		//UI.Invoke(FlashMenu, "root1.ClearScreenPapyrus", args)
	}


	void SNE::KernelScript::ReverseModePropertyGet(VMObject* self)
	{
		_MESSAGE("SNE::KernelScript::ReverseModePropertyGet");
		//return UI.Get(FlashMenu, "root1.ReverseMode") as bool
	}

	void SNE::KernelScript::ReverseModePropertySet(VMObject* self, bool value)
	{
		_MESSAGE("SNE::KernelScript::ReverseModePropertySet");
		//UI.Set(FlashMenu, "root1.ReverseMode", value)
	}


	void SNE::KernelScript::InsertModePropertyGet(VMObject* self)
	{
		_MESSAGE("SNE::KernelScript::InsertModePropertyGet");
		//return UI.Get(FlashMenu, "root1.InsertMode") as bool
	}

	void SNE::KernelScript::InsertModePropertySet(VMObject* self, bool value)
	{
		_MESSAGE("SNE::KernelScript::InsertModePropertySet");
		//UI.Set(FlashMenu, "root1.InsertMode", value)
	}


	void SNE::KernelScript::LocalEchoPropertyGet(VMObject* self)
	{
		_MESSAGE("SNE::KernelScript::LocalEchoPropertyGet");
		//UI.Get(FlashMenu, "root1.ScreenEchoEnable") as bool
	}

	void SNE::KernelScript::LocalEchoPropertySet(VMObject* self, bool value)
	{
		_MESSAGE("SNE::KernelScript::LocalEchoPropertySet");
		//UI.Set(FlashMenu, "root1.ScreenEchoEnable", value)
	}


	void SNE::KernelScript::PapyrusStringEscapeSequencePropertyGet(VMObject* self)
	{
		_MESSAGE("SNE::KernelScript::PapyrusStringEscapeSequencePropertyGet");
		//return UI.Get(FlashMenu, "root1.PapyrusStringEscapeSequence") as string
	}

	void SNE::KernelScript::PapyrusStringEscapeSequencePropertySet(VMObject* self, bool value)
	{
		_MESSAGE("SNE::KernelScript::PapyrusStringEscapeSequencePropertySet");
		//UI.Set(FlashMenu, "root1.PapyrusStringEscapeSequence", value)
	}

	#pragma endregion

	#pragma region Cursor

	// Move the cursor by row and column number (top left is 1,1)
	void SNE::KernelScript::CursorMove(VMObject* self)
	{
		//var[] args = new var[2]
		//args[0] = row
		//args[1] = column
		//UI.Invoke(FlashMenu, "root1.CursorMovePapyrus", args)
	}

	// Move the cursor by character index (zero based "screen memory" address, top left is 0)
	void SNE::KernelScript::CursorMoveByIndex(VMObject* self)
	{
		//var[] args = new var[1]
		//args[0] = index
		//UI.Invoke(FlashMenu, "root1.CursorMoveByIndex", args)
	}

	// Number of screen row the cursor is currently positioned at (first row is 1).
	void SNE::KernelScript::CursorPositionRow_PropertyGet(VMObject* self)
	{
		//return UI.Get(FlashMenu, "root1.CursorCurrentLine") as int
	}

	// Number of screen column the cursor is currently positioned at (first column is 1)
	void SNE::KernelScript::CursorPositionColumn_PropertyGet(VMObject* self)
	{
		//return UI.Get(FlashMenu, "root1.CursorCurrentColumn") as int
	}

	// Character index of current cursor position (zero based "screen memory" address, top left is 0)
	void SNE::KernelScript::CursorPositionIndex_PropertyGet(VMObject* self)
	{
		//return UI.Get(FlashMenu, "root1.CursorCurrentIndex") as int
	}

	// Returns true when the cursor rectangle on Terminal screen is visible.
	void SNE::KernelScript::CursorEnabled_PropertyGet(VMObject* self)
	{
		//return UI.Get(FlashMenu, "root1.CursorEnabled") as bool
	}

	// Enable/disable visible cursor rectangle on Terminal screen
	void SNE::KernelScript::CursorEnabled_PropertySet(VMObject* self, bool value)
	{
		//UI.Set(FlashMenu, "root1.CursorEnabled", value)
	}

	#pragma endregion

	#pragma region Keyboard

	// Synchronously read a line (ends in ENTER keypress) from the Terminal.
	// TODO: Add support for the pipboy.
	BSFixedString SNE::KernelScript::ReadLine(VMObject* self)
	{
		if (!self) { return BSFixedString(); }

		UI* ui = (*g_ui);
		BSFixedString terminalHoloMenuName = BSFixedString(MenuName::TerminalHolotapeMenu);

		if (ui->IsMenuOpen(terminalHoloMenuName))
		{
			IMenu* terminalHoloMenu = ui->GetMenu(terminalHoloMenuName);

			GFxMovieRoot* movieRoot = terminalHoloMenu->movie->movieRoot;
			if (movieRoot)
			{
				if (SNE::HolotapeProgram::IsProgram(movieRoot))
				{
					GFxValue line;
					if (movieRoot->Invoke("root.ReadLineAsyncBeginPapyrus", &line, "%s"))
					{
						_MESSAGE("HolotapeProgram::ReadLine(): '%s'", line.data.string);

						return BSFixedString(line.data.string);
					}
					else
					{
						_MESSAGE("HolotapeProgram::ReadLine(): Could not read the line.");
					}
				}
				else
				{
					_MESSAGE("HolotapeProgram::ReadLine(): There is no holotape program.");
				}
			}
			else
			{
				_MESSAGE("HolotapeProgram::ReadLine(): There is no valid movie root.");
			}
		}

		return BSFixedString("ReadLine: This is fake dummy text from native code.");
	}


	// Read a line (ends in ENTER keypress) from the Terminal
	BSFixedString SNE::KernelScript::ReadKey(VMObject* self)
	{
		if (!self) { return BSFixedString(); }
		return BSFixedString("ReadKey: This is fake dummy text from native code.");

		//If(readMode == READMODE_NONE)
		//	; set read mode synchronous key
		//	readMode = READMODE_KEY_SYNC

		//	; clear readAsync input bufferand sync read complete flag
		//	readSyncCompleteFlag = false
		//	readAsyncBuffer = ""

		//	; register for async result event
		//	RegisterForExternalEvent(ReadAsyncResultEvent, "OnReadAsyncResult");

		//; invoke ReadLineAsync on Terminal
		//	var[] args = new var[1]
		//	args[0] = ""
		//	bool readAsyncBeginResult = UI.Invoke(FlashMenu, "root1.ReadKeyAsyncBegin", args) as bool
		//	If(readAsyncBeginResult)
		//	; wait for read async result
		//	While(IsBoundGameObjectAvailable() && readMode == READMODE_KEY_SYNC && !readSyncCompleteFlag && !isShuttingDown)
		//	; Debug.Trace(self + ": DEBUG - [ReadKey] Waiting for OnReadAsyncResult")

		//	; ##### WARNING: DO NOT use Utility.Wait() in your Papyrus Terminal scripts!#####
		//	; Doing so will suspend execution of your script, because the Terminal Menu is open.
		//	; Use Utility.WaitMenuMode() instead.

		//	Utility.WaitMenuMode(SYNCREAD_WAIT_INTERVAL)
		//	EndWhile

		//	If(readSyncCompleteFlag)
		//	; completed, return async input buffer contents
		//	return readAsyncBuffer
		//	Else
		//	; aborted, return empty string
		//	return ""
		//	EndIf
		//	Else
		//	Debug.Trace(self + ": ERROR - ReadKeyAsyncBegin call failed.")
		//	return ""
		//	EndIf
		//	Else
		//	Debug.Trace(self + ": ERROR - ReadKey() called, but a Read operation is already in progress.")
		//	return ""
		//EndIf
	}


	// Begin asynchronous ReadLine operation.Completes on ENTER keypress by user.Cancellable by calling ReadAsyncCancel().
	// Operation will generate OnPapyrusTerminalReadAsyncCompleted event callback on completion.
	void SNE::KernelScript::ReadLineAsyncBegin(VMObject* self, float maxLength)
	{
		//If(readMode == READMODE_NONE)

		//	; set async readline mode
		//	readMode = READMODE_LINE_ASYN

		//	; clear async read buffer
		//	readAsyncBuffer = ""

		//	; register for terminal async read resultand cancel events
		//	RegisterForExternalEvent(ReadAsyncResultEvent, "OnReadAsyncResult")

		//	; invoke async ReadLine on Terminal
		//	var[] args = new var[1]
		//	args[0] = maxLength
		//	return UI.Invoke(FlashMenu, "root1.ReadLineAsyncBeginPapyrus", args) as bool
		//EndIf
	}


	// Begin asynchronous ReadKey operation. Completes as user depresses a key. Cancellable by calling ReadAsyncCancel().
	void SNE::KernelScript::ReadKeyAsyncBegin(VMObject* self)
	{
		//If(readMode == READMODE_NONE)
		//	; set readmode KEY ASYNC
		//	readMode = READMODE_KEY_ASYN

		//	; clear async read buffer
		//	readAsyncBuffer = ""

		//	; register for readasyncresult event
		//	RegisterForExternalEvent(ReadAsyncResultEvent, "OnReadAsyncResult")

		//	; invoke on Terminal
		//	var[] args = new var[1]
		//	args[0] = ""
		//	return UI.Invoke(FlashMenu, "root1.ReadKeyAsyncBegin", args) as bool

		//	Else
		//	; read operation in progress
		//	Debug.Trace(self + ": ERROR - ReadKeyAsyncBegin() called, but a Read operation is already in progres.")
		//	return false;
		//EndIf
	}


	// Cancel a pending asynchronous Read operation
	void SNE::KernelScript::ReadAsyncCancel(VMObject* self)
	{
		//If(readMode == READMODE_LINE_ASYN || readMode == READMODE_KEY_ASYN)
		//	; unregister for terminal async read result event
		//	UnRegisterForExternalEvent(ReadAsyncResultEvent)

		//	; register for terminal async read cancelled event
		//	RegisterForExternalEvent(ReadAsyncCancelledEvent, "OnReadAsyncCancelled")

		//	; invoke ReadLineAsyncCancel on Terminal
		//	var[] args = new var[1]
		//	args[0] = ""
		//	UI.Invoke(FlashMenu, "root1.ReadAsyncCancel", args)

		//	Else
		//	Debug.Trace(self + ": WARNING - ReadAsyncCancel() called, but no async Read operation was in progress.")

		//EndIf
	}


	// Result event handler for Terminal ReadLine operations
	// The Fash Terminal itself can only do async Reads, but the API provides synchronous wrappers ReadKey() and ReadLine()
	void SNE::KernelScript::OnReadAsyncResult(VMObject* self, BSFixedString readLineBuffer)
	{
		//; unregister for async result event
		// UnRegisterForExternalEvent(ReadAsyncResultEvent)

		//If(readMode == READMODE_LINE_SYNC || readMode == READMODE_KEY_SYNC)
		//	; synchronous Read operation has completed, fill async read buffer from event parameter
		//	readAsyncBuffer = readLineBuffer
		//	; set sync read complete flag
		//	readSyncCompleteFlag = true
		//	; clear readmode
		//	readMode = READMODE_NONE

		//ElseIf(readMode == READMODE_LINE_ASYN || readMode == READMODE_KEY_ASYN)
		//	; asynchronous Read operation has completed, signal derived class
		//	OnPapyrusTerminalReadAsyncCompleted(readLineBuffer)
		//	; reset readmode
		//	readMode = READMODE_NONE

		//Else
		//	Debug.Trace(self + ": WARNING - OnReadAsyncResult event received, but no Read operation was in progress.");
		//EndIf
	}


	// Result event handler for async Read cancellation
	void SNE::KernelScript::OnReadAsyncCancelled(VMObject* self)
	{
		//If(readMode == READMODE_LINE_ASYN || readMode == READMODE_KEY_ASYN)
		//	; unregister for async resultand cancelled events
		//	UnRegisterForExternalEvent(ReadAsyncResultEvent)
		//	UnRegisterForExternalEvent(ReadAsyncCancelledEvent)

		//	; clear async read mode
		//	readMode = READMODE_NONE

		//	; notify derived class
		//	OnPapyrusTerminalReadAsyncCancelled()
		//EndIf
	}

	#pragma endregion

	#pragma region Convenience

	void SNE::KernelScript::Sleep(VMObject* self) { }

	#pragma endregion

	#pragma region Scripting

	// TODO: The `int` parameters are actually `var` type with default `none`.
	void SNE::KernelScript::Dispatch(VMObject* self /*, std::string functionName, int arg1 = 0, int arg2 = 0, int arg3 = 0, int arg4 = 0, int arg5 = 0, int arg6 = 0*/)
	{
		//If(functionName == "")
		//	Debug.Trace(self + ": ERROR - AsyncDispatch() called with no function name.")
		//	return
		//EndIf
		//var[] callArgs = new var[0]
		//AddArg(callArgs, arg1)
		//AddArg(callArgs, arg2)
		//AddArg(callArgs, arg3)
		//AddArg(callArgs, arg4)
		//AddArg(callArgs, arg5)
		//AddArg(callArgs, arg6)
		//Debug.Trace(self + ": DEBUG - Dispatch(" + functionName + ", <" + callArgs.Length + " parameters>) called.")
		//If(!TerminalShutdown)
		//	CallFunctionNoWait(functionName, callArgs)
		//EndIf
	}


	void SNE::KernelScript::AddArg(VMObject* self /*var[] argsArray, var varArg*/)
	{
		//If((varArg + "") == "None")
		//	return
		//EndIf

		//; TESTING THIS
		//argsArray.Add(varArg)
		//return
	}

	#pragma endregion


	bool SNE::KernelScript::OnRegister(VirtualMachine* vm)
	{
		_MESSAGE("KernelScript::OnRegister()");

		// Startup
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("RegisterForStartup", KernelScript::SCRIPTNAME, KernelScript::RegisterForStartup, vm));
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("UnregisterForStartup", KernelScript::SCRIPTNAME, KernelScript::UnregisterForStartup, vm));

		// Shutdown
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("RegisterForShutdown", KernelScript::SCRIPTNAME, KernelScript::RegisterForShutdown, vm));
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("UnregisterForShutdown", KernelScript::SCRIPTNAME, KernelScript::UnregisterForShutdown, vm));

		// Terminal
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("TerminalRows", KernelScript::SCRIPTNAME, KernelScript::TerminalRows_PropertyGet, vm)); // error: Function will not be bound.
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("TerminalColumns", KernelScript::SCRIPTNAME, KernelScript::TerminalColumns_PropertyGet, vm)); // error: Function will not be bound.
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("GetQuitOnTABEnabled", KernelScript::SCRIPTNAME, KernelScript::QuitOnTABEnabled_PropertyGet, vm));
		vm->RegisterFunction(new NativeFunction1 <VMObject, void, bool>("SetQuitOnTABEnabled", KernelScript::SCRIPTNAME, KernelScript::QuitOnTABEnabled_PropertySet, vm)); // error: Function will not be bound.
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("End", KernelScript::SCRIPTNAME, KernelScript::End, vm));

		// Screen
		vm->RegisterFunction(new NativeFunction1 <VMObject, void, BSFixedString>("Print", KernelScript::SCRIPTNAME, KernelScript::Print, vm)); // error: Function will not be bound.
		vm->RegisterFunction(new NativeFunction1 <VMObject, void, BSFixedString>("PrintLine", KernelScript::SCRIPTNAME, KernelScript::PrintLine, vm)); // error: Function will not be bound.

		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("Clear", KernelScript::SCRIPTNAME, KernelScript::Clear, vm));
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("ClearHome", KernelScript::SCRIPTNAME, KernelScript::ClearHome, vm));
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("GetReverseMode", KernelScript::SCRIPTNAME, KernelScript::ReverseModePropertyGet, vm));
		vm->RegisterFunction(new NativeFunction1 <VMObject, void, bool>("SetReverseMode", KernelScript::SCRIPTNAME, KernelScript::ReverseModePropertySet, vm)); // error: Function will not be bound.
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("GetInsertMode", KernelScript::SCRIPTNAME, KernelScript::InsertModePropertyGet, vm));
		vm->RegisterFunction(new NativeFunction1 <VMObject, void, bool>("SetInsertMode", KernelScript::SCRIPTNAME, KernelScript::InsertModePropertySet, vm)); // error: Function will not be bound.
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("GetLocalEcho", KernelScript::SCRIPTNAME, KernelScript::LocalEchoPropertyGet, vm));
		vm->RegisterFunction(new NativeFunction1 <VMObject, void, bool>("SetLocalEcho", KernelScript::SCRIPTNAME, KernelScript::LocalEchoPropertySet, vm)); // error: Function will not be bound.
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("GetPapyrusStringEscapeSequence", KernelScript::SCRIPTNAME, KernelScript::PapyrusStringEscapeSequencePropertyGet, vm));
		vm->RegisterFunction(new NativeFunction1 <VMObject, void, bool>("SetPapyrusStringEscapeSequence", KernelScript::SCRIPTNAME, KernelScript::PapyrusStringEscapeSequencePropertySet, vm)); // error: Function will not be bound.

		// Cursor
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("CursorMove", KernelScript::SCRIPTNAME, KernelScript::CursorMove, vm));
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("CursorMoveByIndex", KernelScript::SCRIPTNAME, KernelScript::CursorMoveByIndex, vm));
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("CursorPositionRow", KernelScript::SCRIPTNAME, KernelScript::CursorPositionRow_PropertyGet, vm)); // error: Function will not be bound.
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("CursorPositionColumn", KernelScript::SCRIPTNAME, KernelScript::CursorPositionColumn_PropertyGet, vm)); // error: Function will not be bound.
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("CursorPositionIndex", KernelScript::SCRIPTNAME, KernelScript::CursorPositionIndex_PropertyGet, vm)); // error: Function will not be bound.
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("CursorEnabled", KernelScript::SCRIPTNAME, KernelScript::CursorEnabled_PropertyGet, vm)); // error: Function will not be bound.
		vm->RegisterFunction(new NativeFunction1 <VMObject, void, bool>("SetCursorEnabled", KernelScript::SCRIPTNAME, KernelScript::CursorEnabled_PropertySet, vm));

		// Keyboard
		vm->RegisterFunction(new NativeFunction0 <VMObject, BSFixedString>("ReadKey", KernelScript::SCRIPTNAME, KernelScript::ReadKey, vm)); // error: Function will not be bound.
		vm->RegisterFunction(new NativeFunction0 <VMObject, BSFixedString>("ReadLine", KernelScript::SCRIPTNAME, KernelScript::ReadLine, vm)); // error: Function will not be bound.

		vm->RegisterFunction(new NativeFunction1 <VMObject, void, float>("ReadLineAsyncBegin", KernelScript::SCRIPTNAME, KernelScript::ReadLineAsyncBegin, vm)); // error: Function will not be bound.
		vm->SetFunctionFlags(KernelScript::SCRIPTNAME, "ReadLineAsyncBegin", IFunction::kFunctionFlag_NoWait);

		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("ReadKeyAsyncBegin", KernelScript::SCRIPTNAME, KernelScript::ReadKeyAsyncBegin, vm));
		vm->SetFunctionFlags(KernelScript::SCRIPTNAME, "ReadKeyAsyncBegin", IFunction::kFunctionFlag_NoWait);

		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("ReadAsyncCancel", KernelScript::SCRIPTNAME, KernelScript::ReadAsyncCancel, vm));
		vm->SetFunctionFlags(KernelScript::SCRIPTNAME, "ReadAsyncCancel", IFunction::kFunctionFlag_NoWait);

		//vm->RegisterFunction(new NativeFunction1 <VMObject, void, BSFixedString>("OnReadAsyncResult", KernelScript::SCRIPT, KernelScript::OnReadAsyncResult, vm)); // error: Function will not be bound.
		//vm->RegisterFunction(new NativeFunction0 <VMObject, void>("OnReadAsyncCancelled", KernelScript::SCRIPT, KernelScript::OnReadAsyncCancelled, vm));

		// Convenience
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("Sleep", KernelScript::SCRIPTNAME, KernelScript::Sleep, vm));

		// Scripting
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("Dispatch", KernelScript::SCRIPTNAME, KernelScript::Dispatch, vm));
		vm->RegisterFunction(new NativeFunction0 <VMObject, void>("AddArg", KernelScript::SCRIPTNAME, KernelScript::AddArg, vm));

		return true;
	}


	void SNE::KernelScript::Papyrus(F4SEPapyrusInterface* papyrus)
	{
		if (papyrus->Register(KernelScript::OnRegister))
		{
			_MESSAGE("KernelScript::Papyrus(): Registered the kernel script.");
		}
	}


}
