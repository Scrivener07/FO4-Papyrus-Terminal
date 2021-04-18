#include "Papyrus.h"
#include "f4se/PluginAPI.h"
#include "f4se/PapyrusArgs.h"
#include "f4se/PapyrusNativeFunctions.h"
#include "f4se/GameReferences.h"
#include "f4se/GameExtraData.h"

namespace Papyrus
{
	/// <summary>
	/// PapyrusTerminal:KERNAL.psc
	/// </summary>
	namespace Kernel
	{

		/// <summary>
		/// The implementation for this papyrus function.
		/// </summary>
		/// <param name="base"></param>
		void Test(StaticFunctionTag* base)
		{
			_MESSAGE("PapyrusTerminal:KERNAL::Test()");
			_MESSAGE("+---kTypeID: '%i'", base->kTypeID);

			Console_Print("%s::Test, Type:%i", SCRIPT_KERNAL, base->kTypeID);
		}


		/// <summary>
		/// The implementation for this papyrus function has two boolean parameters.
		/// </summary>
		/// <param name="base"></param>
		void Test2(StaticFunctionTag* base, bool a, bool b)
		{
			_MESSAGE("PapyrusTerminal:KERNAL::Test2()");
			_MESSAGE("+---kTypeID: '%i'", base->kTypeID);
			_MESSAGE("+---a: '%i'", a);
			_MESSAGE("+---b: '%i'", b);

			Console_Print("%s::Test2, Type:%i, A:%i, B:%i", SCRIPT_KERNAL, base->kTypeID, a, b);
		}


		BSFixedString GetDirectoryCurrent(StaticFunctionTag* base)
		{
			const char* value = "E:\\Bethesda\\steamapps\\common\\Fallout 4";

			_MESSAGE("PapyrusTerminal:KERNAL::GetDirectoryCurrent()");
			_MESSAGE("+---kTypeID: '%i'", base->kTypeID);
			_MESSAGE("+---value: '%s'", value);

			Console_Print("%s::GetDirectoryCurrent, Type:%i, value:%s", SCRIPT_KERNAL, base->kTypeID, value);
			return value;
		}


	}
}


// XSE
// ---------------------------------------------

/// <summary>
/// Registers the native papyrus functions for this XSE plugin.
/// </summary>
/// <param name="vm">The virtual machine to use.</param>
/// <returns>true on success</returns>
bool Papyrus::RegisterFunctions(VirtualMachine* VM)
{
	_MESSAGE("Papyrus::RegisterFunctions()");

	VM->RegisterFunction(new NativeFunction0 <StaticFunctionTag, void>("Test", SCRIPT_KERNAL, Papyrus::Kernel::Test, VM));
	VM->RegisterFunction(new NativeFunction2 <StaticFunctionTag, void, bool, bool>("Test2", SCRIPT_KERNAL, Papyrus::Kernel::Test2, VM));
	VM->RegisterFunction(new NativeFunction0 <StaticFunctionTag, BSFixedString>("GetDirectoryCurrent", SCRIPT_KERNAL, Papyrus::Kernel::GetDirectoryCurrent, VM));

	return true;
}
