#include "Papyrus.h"
#include "f4se/PluginAPI.h"
#include "f4se/PapyrusNativeFunctions.h"

namespace Papyrus
{
	namespace Kernal
	{
		/// <summary>
		/// The implementation for this papyrus function.
		/// </summary>
		/// <param name="base"></param>
		void Test(StaticFunctionTag* base)
		{
			_MESSAGE("Papyrus", SCRIPT_KERNAL, ":: void Test()", ", kTypeID:", base->kTypeID);
			Console_Print(SCRIPT_KERNAL, base->kTypeID);
		}

		/// <summary>
		/// The implementation for this papyrus function.
		/// </summary>
		/// <param name="base"></param>
		void Test2(StaticFunctionTag* base, bool a, bool b)
		{
			_MESSAGE("Papyrus", SCRIPT_KERNAL, ":: void Test2(bool, bool)", ", kTypeID:", base->kTypeID);
			Console_Print(SCRIPT_KERNAL, base->kTypeID);
		}
	}
}


// XSE
// ---------------------------------------------

/// <summary>
/// Registers the papyrus functions for this XSE plugin.
/// </summary>
/// <param name="vm">The virtual machine to use.</param>
/// <returns>true</returns>
bool Papyrus::RegisterFunctions(VirtualMachine* VM)
{
	_MESSAGE("Papyrus::RegisterFunctions()");

	VM->RegisterFunction(new NativeFunction0 <StaticFunctionTag, void>("Test", SCRIPT_KERNAL, Papyrus::Kernal::Test, VM));
	VM->RegisterFunction(new NativeFunction2 <StaticFunctionTag, void, bool, bool>("Test2", SCRIPT_KERNAL, Papyrus::Kernal::Test2, VM));

	return true;
}
