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
	#define SCRIPT_XSE "Computer:XSE"
	#define SCRIPT_DRIVE_IO "Computer:Drive:IO"

	namespace Computer
	{
		/// <summary>
		/// PapyrusTerminal:KERNAL.psc
		/// </summary>
		namespace XSE
		{
			/// <summary>
			/// The implementation for this papyrus function.
			/// </summary>
			/// <param name="base"></param>
			void Test(StaticFunctionTag* base)
			{
				_MESSAGE("Computer:XSE::Test()");
				_MESSAGE("+---kTypeID: '%i'", base->kTypeID);

				Console_Print("%s::Test, Type:%i", SCRIPT_XSE, base->kTypeID);
			}


			/// <summary>
			/// The implementation for this papyrus function has two boolean parameters.
			/// </summary>
			/// <param name="base"></param>
			void Test2(StaticFunctionTag* base, bool a, bool b)
			{
				_MESSAGE("Computer:XSE::Test2()");
				_MESSAGE("+---kTypeID: '%i'", base->kTypeID);
				_MESSAGE("+---a: '%i'", a);
				_MESSAGE("+---b: '%i'", b);

				Console_Print("%s::Test2, Type:%i, A:%i, B:%i", SCRIPT_XSE, base->kTypeID, a, b);
			}

		}


		namespace Drive
		{
			namespace IO
			{
				/// <summary>
				/// Gets the Fallout 4 base game directory path.
				/// </summary>
				/// <remarks>
				/// https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfilea
				/// https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findnextfilea
				/// https://docs.microsoft.com/en-us/cpp/standard-library/directory-iterator-class
				/// https://docs.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-win32_find_dataa
				/// http://www.cs.rpi.edu/courses/fall01/os/WIN32_FIND_DATA.html <-----
				/// </remarks>
				/// <param name="base"></param>
				/// <returns></returns>
				BSFixedString GetDirectoryCurrent(StaticFunctionTag* base)
				{
					const char* value = Papyrus::GetCurrentDirectory();

					_MESSAGE("Computer:Drive:IO::GetDirectoryCurrent()");
					_MESSAGE("+---kTypeID: '%i'", base->kTypeID);
					_MESSAGE("+---value: '%s'", value);

					Console_Print("%s::GetDirectoryCurrent, Type:%i, value:%s", SCRIPT_DRIVE_IO, base->kTypeID, value);
					return value;
				}
			}
		}

	}
}


/// <summary>
/// Gets the Fallout 4 base game directory path.
/// </summary>
/// <returns>The directory path.</returns>
const char* Papyrus::GetCurrentDirectory()
{
	char buffer[MAX_PATH];
	GetModuleFileNameA(NULL, buffer, MAX_PATH);
	std::string::size_type position = std::string(buffer).find_last_of("\\/");
	return std::string(buffer).substr(0, position).c_str();;
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

	VM->RegisterFunction(new NativeFunction0 <StaticFunctionTag, void>("Test", SCRIPT_XSE, Computer::XSE::Test, VM));
	VM->RegisterFunction(new NativeFunction2 <StaticFunctionTag, void, bool, bool>("Test2", SCRIPT_XSE, Computer::XSE::Test2, VM));
	VM->RegisterFunction(new NativeFunction0 <StaticFunctionTag, BSFixedString>("GetDirectoryCurrent", SCRIPT_DRIVE_IO, Computer::Drive::IO::GetDirectoryCurrent, VM));

	return true;
}

