// Standard
#include <shlobj.h>
#include<string.h>
#include<stdlib.h>
#include<iostream>
#include<fstream>

// F4SE
#include "f4se/PluginAPI.h"
#include "f4se_common/f4se_version.h"
#include "f4se_common/Utilities.h"

// F4SE - Papyrus
#include "f4se/PapyrusArgs.h"
#include "f4se/PapyrusNativeFunctions.h"

// F4SE - Scaleform
#include "F4SE/GameMenus.h"
#include "F4SE/ScaleformCallbacks.h"

// F4SE - Common
#include <common/IDirectoryIterator.h>

// Xtensions
#include "plugins/Xtensions/XSE.h"
#include "plugins/Xtensions/SystemTime.h"

// Computing
#include "Main.h"

//---------------------------------------------

IDebugLog               gLog;
PluginHandle            g_pluginHandle = kPluginHandle_Invalid;
F4SEMessagingInterface* g_messaging = NULL;
F4SEPapyrusInterface*   g_papyrus   = NULL;
F4SEScaleformInterface* g_scaleform = NULL;


// Namespaces
//---------------------------------------------

/// <summary>
/// The primary namespace to use.
/// </summary>
namespace Computing
{
	namespace Papyrus
	{
		namespace Computer_XSE
		{
			/// <summary>
			/// The script name to use.
			/// </summary>
			constexpr auto SCRIPT = "Computer:XSE";


			/// <summary>
			/// The implementation for this papyrus function.
			/// </summary>
			void Test(StaticFunctionTag* base)
			{
				_MESSAGE("Computer:XSE::Test()");
				_MESSAGE("+---kTypeID: '%i'", base->kTypeID);

				Console_Print("%s::Test, Type:%i", SCRIPT, base->kTypeID);
			}


			/// <summary>
			/// The implementation for this papyrus function has two boolean parameters.
			/// </summary>
			void Test2(StaticFunctionTag* base, bool a, bool b)
			{
				_MESSAGE("Computer:XSE::Test2()");
				_MESSAGE("+---kTypeID: '%i'", base->kTypeID);
				_MESSAGE("+---a: '%i'", a);
				_MESSAGE("+---b: '%i'", b);

				Console_Print("%s::Test2, Type:%i, A:%i, B:%i", SCRIPT, base->kTypeID, a, b);
			}

		}


		bool RegisterPapyrus(VirtualMachine* VM)
		{
			_MESSAGE("Papyrus::RegisterFunctions()");
			VM->RegisterFunction(new NativeFunction0 <StaticFunctionTag, void>("Test", Computer_XSE::SCRIPT, Computer_XSE::Test, VM));
			VM->RegisterFunction(new NativeFunction2 <StaticFunctionTag, void, bool, bool>("Test2", Computer_XSE::SCRIPT, Computer_XSE::Test2, VM));
			return true;
		}
	}


	namespace Scaleform
	{
		/// <summary>
		/// The host menu for holotape programs.
		/// </summary>
		constexpr auto TerminalHolotapeMenu = "TerminalHolotapeMenu";

		/// <summary>
		/// The target holotape progran swf used for injection.
		/// </summary>
		constexpr auto PAPYRUS_TERMINAL_SWF = "PapyrusTerminal.swf";

		/// <summary>
		/// The swf file to use.
		/// </summary>
		constexpr auto COMPUTER_OS_SWF = "Computer_OS.swf";

		/// <summary>
		/// The AS3 code object to use.
		/// </summary>
		constexpr auto COMPUTER_AS3 = "Computer";


		void Computer_WriteLog::Invoke(Args* arguments)
		{
			ASSERT(arguments->numArgs >= 1);
			ASSERT(arguments->args[0].GetType() == GFxValue::kType_String);
			_MESSAGE("AS3@WriteLog: %s", arguments->args[0].GetString());
		}


		class Computer_GetDirectoryGame : public GFxFunctionHandler
		{
			public:
			virtual void Invoke(Args* arguments)
			{
				std::string	sDirectory = GetRuntimeDirectory();
				arguments->movie->movieRoot->CreateString(arguments->result, sDirectory.c_str());
				_MESSAGE("AS3@GetDirectoryGame()::Invoke {%s}", sDirectory.c_str());
			}
		};


		class Computer_GetDirectoryListing : public GFxFunctionHandler
		{
			public:
			virtual void Invoke(Args* arguments)
			{
				ASSERT(arguments->numArgs >= 1);
				ASSERT(arguments->args[0].GetType() == GFxValue::kType_String);

				const char* directory = arguments->args[0].GetString();
				const char* match = nullptr;
				if (arguments->numArgs >= 2)
				{
					match = arguments->args[1].GetString();
				}

				arguments->movie->movieRoot->CreateArray(arguments->result);

				_MESSAGE("AS3@GetDirectoryListing()::Invoke {%s}", directory);
				for (IDirectoryIterator iter(directory, match); !iter.Done(); iter.Next())
				{
					std::string	path = iter.GetFullPath();
					WIN32_FIND_DATA* fileData = iter.Get();

					GFxValue fileInfo;
					arguments->movie->movieRoot->CreateObject(&fileInfo);
					{
						GFxValue filePath;
						arguments->movie->movieRoot->CreateString(&filePath, path.c_str());
						fileInfo.SetMember("nativePath", &filePath);

						GFxValue fileName;
						arguments->movie->movieRoot->CreateString(&fileName, fileData->cFileName);
						fileInfo.SetMember("name", &filePath);

						// Time Stamp
						SYSTEMTIME systemTime;
						FileTimeToSystemTime(&fileData->ftLastWriteTime, &systemTime);

						GFxValue date;
						GFxValue parameters[7];
						parameters[0].SetNumber(systemTime.wYear);
						parameters[1].SetNumber(systemTime.wMonth - 1); // Flash Month is 0-11, System time is 1-12
						parameters[2].SetNumber(systemTime.wDay);
						parameters[3].SetNumber(systemTime.wHour);
						parameters[4].SetNumber(systemTime.wMinute);
						parameters[5].SetNumber(systemTime.wSecond);
						parameters[6].SetNumber(systemTime.wMilliseconds);
						arguments->movie->movieRoot->CreateObject(&date, "Date", parameters, 7);
						fileInfo.SetMember("lastModified", &date);

						FileTimeToSystemTime(&fileData->ftCreationTime, &systemTime);
						parameters[0].SetNumber(systemTime.wYear);
						parameters[1].SetNumber(systemTime.wMonth - 1); // Flash Month is 0-11, System time is 1-12
						parameters[2].SetNumber(systemTime.wDay);
						parameters[3].SetNumber(systemTime.wHour);
						parameters[4].SetNumber(systemTime.wMinute);
						parameters[5].SetNumber(systemTime.wSecond);
						parameters[6].SetNumber(systemTime.wMilliseconds);
						arguments->movie->movieRoot->CreateObject(&date, "Date", parameters, 7);
						fileInfo.SetMember("creationDate", &date);

						fileInfo.SetMember("isDirectory", &GFxValue((fileData->dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) == FILE_ATTRIBUTE_DIRECTORY));
						fileInfo.SetMember("isHidden", &GFxValue((fileData->dwFileAttributes & FILE_ATTRIBUTE_HIDDEN) == FILE_ATTRIBUTE_HIDDEN));
					};
					arguments->result->PushBack(&fileInfo);

				}
			}
		};


		class Computer_GetFileText : public GFxFunctionHandler
		{
			public:
			virtual void Invoke(Args* arguments)
			{
				ASSERT(arguments->numArgs >= 1);
				ASSERT(arguments->args[0].GetType() == GFxValue::kType_String);
				const char* filepath = arguments->args[0].GetString();

				arguments->movie->movieRoot->CreateArray(arguments->result);

				// File
				std::ifstream file(filepath);

				std::string line;
				while (std::getline(file, line))
				{
					GFxValue content;
					arguments->movie->movieRoot->CreateString(&content, line.c_str());
					arguments->result->PushBack(&content);
				}

				// Return
				_MESSAGE("AS3@Computer_GetFileText()::Invoke(%s) -> {%i}", filepath, arguments->result->GetArraySize());
			}
		};



		bool RegisterScaleform(GFxMovieView* view, GFxValue* f4se)
		{
			GFxMovieRoot* movieRoot = view->movieRoot;
			if (movieRoot)
			{
				GFxValue loaderInfo;
				if (movieRoot->GetVariable(&loaderInfo, "root.loaderInfo.url"))
				{

					// Get the swf file path.
					std::string sResult = loaderInfo.GetString();

					// Check the resulting file path for the papyrus terminal swf.
					if (sResult.find(PAPYRUS_TERMINAL_SWF) != std::string::npos)
					{
						RegisterFunction<Computer_WriteLog>(f4se, movieRoot, "WriteLog");
						RegisterFunction<Computer_GetDirectoryGame>(f4se, movieRoot, "GetDirectoryGame");
						RegisterFunction<Computer_GetDirectoryListing>(f4se, movieRoot, "GetDirectoryListing");
						RegisterFunction<Computer_GetFileText>(f4se, movieRoot, "GetFileText");

						_MESSAGE("Scaleform::RegisterFunctions(): Using: '%s'", sResult.c_str());
					}

				}
				else
				{
					_MESSAGE("Scaleform::RegisterFunctions(): There is no valid movie url.");
				}
			}
			else
			{
				_MESSAGE("Scaleform::RegisterFunctions(): There is no valid movie root.");
			}

			return true;
		}
	}

	//---------------------------------------------

	void OnF4SE(F4SEMessagingInterface::Message* message)
	{
		_MESSAGE("OnF4SE(), type: %s", XSE_MessagingInterface::ToString(message->type));

		if (message->type == F4SEMessagingInterface::kMessage_GameLoaded)
		{
			//Computing::MenuOpenCloseHandler::Register();

			// Testing Only
			//-------------------------
			_MESSAGE("Game::GetDirectory: %s", GetRuntimeDirectory().c_str());
			_MESSAGE("Time::GetTime: %s", Xtensions::Time::GetTime());
			_MESSAGE("Time::GetDay: %s", Xtensions::Time::GetDay());
			_MESSAGE("Time::GetMonth: %s", Xtensions::Time::GetMonth());
			_MESSAGE("Time::GetYear: %s", Xtensions::Time::GetYear());
			_MESSAGE("Time::GetDateTime: %s", Xtensions::Time::GetDateTime());

		}
	}


	/// <summary>
	/// Handle the PapyrusTerminal plugin messages.
	/// </summary>
	/// <param name="message"></param>
	void OnPapyrusTerminal(F4SEMessagingInterface::Message* message)
	{
		_MESSAGE("OnPapyrusTerminal()");
	}


	/// <summary>
	/// Register for plugin messages.
	/// </summary>
	/// <param name="messaging"></param>
	void OnMessaging(F4SEMessagingInterface* messaging)
	{
		if (messaging->RegisterListener(g_pluginHandle, "F4SE", Computing::OnF4SE))
		{
			_MESSAGE("OnMessaging(): Registered for F4SE messaging.");
		}

		if (messaging->RegisterListener(g_pluginHandle, "PapyrusTerminal", Computing::OnPapyrusTerminal))
		{
			_MESSAGE("OnMessaging(): Registered for PapyrusTerminal messaging.");
		}
	}


	/// <summary>
	/// Register the Scaleform XSE code object.
	/// </summary>
	/// <param name="scaleform"></param>
	void OnScaleform(F4SEScaleformInterface* scaleform)
	{
		if (scaleform->Register("Computer", Computing::Scaleform::RegisterScaleform))
		{
			_MESSAGE("OnScaleform(): Registered Scaleform");
		}
	}


	/// <summary>
	/// Register the Papyrus scripts & functions.
	/// </summary>
	/// <param name="papyrus"></param>
	void OnPapyrus(F4SEPapyrusInterface* papyrus)
	{
		if (papyrus->Register(Computing::Papyrus::RegisterPapyrus))
		{
			_MESSAGE("OnPapyrus(): Registered Papyrus");
		}
	}

}


// XSE
// ---------------------------------------------

extern "C"
{
	/// <summary>
	/// The XSE plugin query handler.
	/// </summary>
	/// <param name="f4se">The XSE plugin interface to use.</param>
	/// <param name="info">The XSE plugin information to use.</param>
	/// <returns>true on success</returns>
	bool F4SEPlugin_Query(const F4SEInterface* f4se, PluginInfo* info)
	{
		// Configure debug logging
		gLog.OpenRelative(CSIDL_MYDOCUMENTS, PLUGIN_LOG_FILE);
		gLog.SetPrintLevel(IDebugLog::kLevel_Error);
		gLog.SetLogLevel(IDebugLog::kLevel_DebugMessage);

		// Populate the XSE plugin info structure
		info->infoVersion = PluginInfo::kInfoVersion;
		info->name = PLUGIN_NAME;
		info->version = PLUGIN_VERSION;

		// Aquire an XSE plugin identifier
		g_pluginHandle = f4se->GetPluginHandle();

		// Do a version check
		if (f4se->isEditor)
		{
			_MESSAGE("Main::Query(): Loaded in editor, marking as incompatible.");
			return false;
		}
		else if (f4se->runtimeVersion < MINIMUM_RUNTIME_VERSION)
		{
			_MESSAGE("Main::Query(): Unsupported runtime version %d", f4se->runtimeVersion);
			return false;
		}

		// Query the papyrus interface
		g_papyrus = (F4SEPapyrusInterface*)f4se->QueryInterface(kInterface_Papyrus);
		if (!g_papyrus)
		{
			_FATALERROR("Main::Query(): Could not get the XSE Papyrus interface.");
			return false;
		}

		// Query the scaleform interface
		g_scaleform = (F4SEScaleformInterface*)f4se->QueryInterface(kInterface_Scaleform);
		if (!g_scaleform)
		{
			_FATALERROR("Main::Query(): Could not get the XSE Scaleform interface.");
			return false;
		}

		// Query the messaging interface
		g_messaging = (F4SEMessagingInterface*)f4se->QueryInterface(kInterface_Messaging);
		if (!g_messaging)
		{
			_FATALERROR("Main::Query(): Could not get the XSE Messaging interface.");
			return false;
		}

		return true;
	}


	/// <summary>
	/// The XSE plugin load handler.
	/// </summary>
	/// <param name="f4se">The F4SE interface to use.</param>
	/// <returns>true on success</returns>
	bool F4SEPlugin_Load(const F4SEInterface * f4se)
	{
		_MESSAGE("Main::Load()");

		Computing::OnMessaging(g_messaging);
		Computing::OnScaleform(g_scaleform);
		Computing::OnPapyrus(g_papyrus);

		return true;
	}


};
