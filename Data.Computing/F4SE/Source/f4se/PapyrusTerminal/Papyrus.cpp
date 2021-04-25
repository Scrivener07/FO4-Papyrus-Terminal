#include "Papyrus.h"
#include "f4se/PluginAPI.h"
#include "f4se/PapyrusArgs.h"
#include "f4se/PapyrusNativeFunctions.h"
#include "f4se/GameReferences.h"
#include "f4se/GameExtraData.h"
#include <Windows.h>
#include <string>

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


		// https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfilea
		// https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findnextfilea
		// https://docs.microsoft.com/en-us/cpp/standard-library/directory-iterator-class
		// https://docs.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-win32_find_dataa
		// http://www.cs.rpi.edu/courses/fall01/os/WIN32_FIND_DATA.html <-----
		BSFixedString GetDirectoryCurrent(StaticFunctionTag* base)
		{
			const char* value = Papyrus::GetCurrentDirectory();

			_MESSAGE("PapyrusTerminal:KERNAL::GetDirectoryCurrent()");
			_MESSAGE("+---kTypeID: '%i'", base->kTypeID);
			_MESSAGE("+---value: '%s'", value);

			Console_Print("%s::GetDirectoryCurrent, Type:%i, value:%s", SCRIPT_KERNAL, base->kTypeID, value);
			return value;
		}


	}
}


const char* Papyrus::GetCurrentDirectory()
{
	char buffer[MAX_PATH];
	GetModuleFileNameA(NULL, buffer, MAX_PATH);
	std::string::size_type pos = std::string(buffer).find_last_of("\\/");
	return std::string(buffer).substr(0, pos).c_str();;
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

