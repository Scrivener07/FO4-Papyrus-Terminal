#pragma once
#include "f4se/PluginAPI.h"
#include "f4se/PapyrusArgs.h"
#include <f4se/PapyrusEvents.h>
#include "f4se/PapyrusNativeFunctions.h"
#include "f4se/ScaleformCallbacks.h"
//---------------------------------------------

namespace SNE
{
	/// <summary>
	/// Represents a Papyrus script with terminal methods.
	/// </summary>
	class KernelScript
	{

		public:

		/// <summary>
		/// The script name to use.
		/// </summary>
		static const char* SCRIPTNAME;


		/// <summary>
		/// Register the Papyrus scripts & functions.
		/// </summary>
		/// <param name="papyrus"></param>
		static void Papyrus(F4SEPapyrusInterface* papyrus);


		static void SendEventStartup();
		static void SendEventShutdown();

		private:

		/// <summary>
		/// Registers the native papyrus functions for this script.
		/// </summary>
		/// <param name="vm">The virtual machine to use.</param>
		/// <returns>true on success</returns>
		static bool OnRegister(VirtualMachine* vm);


		#pragma region Startup

		static void RegisterForStartup(VMObject* self);
		static void UnregisterForStartup(VMObject* self);

		#pragma endregion

		#pragma region Shutdown

		static void RegisterForShutdown(VMObject* self);
		static void UnregisterForShutdown(VMObject* self);

		#pragma endregion

		#pragma region Terminal

		static void TerminalRows_PropertyGet(VMObject* self);
		static void TerminalColumns_PropertyGet(VMObject* self);

		static void QuitOnTABEnabled_PropertyGet(VMObject* self);
		static void QuitOnTABEnabled_PropertySet(VMObject* self, bool value);

		static void End(VMObject* self);

		#pragma endregion

		#pragma region Screen

		/// <summary>
		/// Print characters to screen.
		/// </summary>
		static void Print(VMObject* self, BSFixedString value);

		/// <summary>
		/// Prints a line to the screen with an LF appended to the end.
		/// </summary>
		static void PrintLine(VMObject* self, BSFixedString value);

		/// <summary>
		/// Clears the screen.
		/// </summary>
		static void Clear(VMObject* self);

		/// <summary>
		/// Clears the screen and moves the cursor back to home position. The home position is at row/column (1, 1).
		/// </summary>
		static void ClearHome(VMObject* self);

		/// <summary>
		/// Enable/disable reverse (inverse) text mode.
		/// </summary>
		static void ReverseModePropertyGet(VMObject* self);

		/// <summary>
		/// Enable/disable reverse (inverse) text mode.
		/// </summary>
		static void ReverseModePropertySet(VMObject* self, bool value);

		/// <summary>
		/// Enable/disable insert mode (insert key toggle)
		/// </summary>
		static void InsertModePropertyGet(VMObject* self);

		/// <summary>
		/// Enable/disable insert mode (insert key toggle)
		/// </summary>
		/// <param name="self"></param>
		/// <returns></returns>
		static void InsertModePropertySet(VMObject* self, bool value);

		/// <summary>
		/// Enable/disable Terminal local echo (print typed keys to screen)
		/// </summary>
		static void LocalEchoPropertyGet(VMObject* self);

		/// <summary>
		/// Enable/disable Terminal local echo (print typed keys to screen)
		/// </summary>
		static void LocalEchoPropertySet(VMObject* self, bool value);

		static void PapyrusStringEscapeSequencePropertyGet(VMObject* self);
		static void PapyrusStringEscapeSequencePropertySet(VMObject* self, bool value);

		#pragma endregion


		// Cursor
		static void CursorMove(VMObject* self);
		static void CursorMoveByIndex(VMObject* self);

		static void CursorPositionRow_PropertyGet(VMObject* self);
		static void CursorPositionColumn_PropertyGet(VMObject* self);
		static void CursorPositionIndex_PropertyGet(VMObject* self);

		static void CursorEnabled_PropertyGet(VMObject* self);
		static void CursorEnabled_PropertySet(VMObject* self, bool value);

		// Keyboard
		static BSFixedString ReadLine(VMObject* self);
		static BSFixedString ReadKey(VMObject* self);

		static void ReadLineAsyncBegin(VMObject* self, float maxLength);

		static void ReadKeyAsyncBegin(VMObject* self);
		static void ReadAsyncCancel(VMObject* self);

		static void OnReadAsyncResult(VMObject* self, BSFixedString readLineBuffer);
		static void OnReadAsyncCancelled(VMObject* self);

		// Convenience
		static void Sleep(VMObject* self);

		// Scripting
		static void Dispatch(VMObject* self);
		static void AddArg(VMObject* self);


	};
}
