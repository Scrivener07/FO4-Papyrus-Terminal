#pragma once
#include "f4se/PluginAPI.h"
#include "f4se/PapyrusArgs.h"
#include "f4se/PapyrusNativeFunctions.h"
//---------------------------------------------

namespace SNE
{
	/// <summary>
	/// Represents a Papyrus script with text manipulation methods.
	/// </summary>
	class TextScript
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


		private:

		/// <summary>
		/// Registers the native papyrus functions for this script.
		/// </summary>
		/// <param name="vm">The virtual machine to use.</param>
		/// <returns>true on success</returns>
		static bool OnRegister(VirtualMachine* vm);

		/// <summary>
		/// TODO: Not Implemented yet
		/// </summary>
		static void Split(StaticFunctionTag* self, BSFixedString line, BSFixedString separator);


	};
}
