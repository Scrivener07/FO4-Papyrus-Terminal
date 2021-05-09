// Standard
//#include <cstring>

// Windows
#include <shlobj.h>	// CSIDL_MYCODUMENTS

// F4SE
#include "f4se/PluginAPI.h"
#include "f4se_common/f4se_version.h"
#include "f4se_common/Utilities.h"

// Papyrus
#include "f4se/PapyrusArgs.h"
#include "f4se/PapyrusNativeFunctions.h"

// Scaleform
#include "F4SE/GameMenus.h"
#include "F4SE/ScaleformCallbacks.h"

// Project
#include "Main.h"
#include "Shared.h"
#include <common/IDirectoryIterator.h>


// Fields
// ---------------------------------------------

IDebugLog               gLog;
PluginHandle            g_pluginHandle = kPluginHandle_Invalid;
F4SEMessagingInterface* g_messaging = NULL;
F4SEPapyrusInterface*   g_papyrus   = NULL;
F4SEScaleformInterface* g_scaleform = NULL;


// Namespaces
// ---------------------------------------------

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


	/// <summary>
	/// The MenuOpenCloseEvent handler.
	/// </summary>
	class MenuOpenCloseHandler : public BSTEventSink<MenuOpenCloseEvent>
	{
		public:
		virtual ~MenuOpenCloseHandler() { };

		/// <summary>
		/// The implementation for the MenuOpenCloseEvent handler.
		/// </summary>
		/// <param name="e">The MenuOpenCloseEvent to use.</param>
		/// <param name="dispatcher">The dispatcher to use.</param>
		/// <returns>The event result.</returns>
		virtual	EventResult	ReceiveEvent(MenuOpenCloseEvent* e, void* dispatcher) override
		{
			_MESSAGE("MenuOpenCloseHandler: menuName: '%s', isOpen: `%s`", std::string(e->menuName).c_str(), e->isOpen ? "true" : "false");

			static BSFixedString sTerminalHolotapeMenu(Computing::Scaleform::TerminalHolotapeMenu);
			if (e->menuName == sTerminalHolotapeMenu)
			{
				if (e->isOpen)
				{
					_MESSAGE("MenuOpenCloseHandler: Opening the '%s' menu.", std::string(e->menuName).c_str());
				}
				else
				{
					_MESSAGE("MenuOpenCloseHandler: Closing the '%s' menu.", std::string(e->menuName).c_str());
				}
			}

			return kEvent_Continue;
		};


		/// <summary>
		/// Register the event handler type.
		/// </summary>
		static void Register()
		{
			static auto* pHandler = new MenuOpenCloseHandler();
			(*g_ui)->menuOpenCloseEventSource.AddEventSink(pHandler);
		}


	};


	namespace XSE
	{
		void OnF4SE(F4SEMessagingInterface::Message* message)
		{
			_MESSAGE("XSE::OnF4SE(), type: %s", MessageToString(message));

			if (message->type == F4SEMessagingInterface::kMessage_GameLoaded)
			{
				Computing::MenuOpenCloseHandler::Register();

				// Testing Only
				//-------------------------
				_MESSAGE("Game::GetDirectory: %s", GetRuntimeDirectory().c_str());
				_MESSAGE("Time::GetTime: %s", Computing::Time::GetTime());
				_MESSAGE("Time::GetDay: %s", Computing::Time::GetDay());
				_MESSAGE("Time::GetMonth: %s", Computing::Time::GetMonth());
				_MESSAGE("Time::GetYear: %s", Computing::Time::GetYear());
				_MESSAGE("Time::GetDateTime: %s", Computing::Time::GetDateTime());

			}
		}


		/// <summary>
		/// Handle the PapyrusTerminal plugin messages.
		/// </summary>
		/// <param name="message"></param>
		void OnPapyrusTerminal(F4SEMessagingInterface::Message* message)
		{
			_MESSAGE("XSE::OnPapyrusTerminal()");
		}


		/// <summary>
		/// Register for plugin messages.
		/// </summary>
		/// <param name="messaging"></param>
		void Messaging(F4SEMessagingInterface* messaging)
		{
			if (messaging->RegisterListener(g_pluginHandle, "F4SE", Computing::XSE::OnF4SE))
			{
				_MESSAGE("XSE::Messaging(): Registered for F4SE messaging.");
			}

			if (messaging->RegisterListener(g_pluginHandle, "PapyrusTerminal", Computing::XSE::OnPapyrusTerminal))
			{
				_MESSAGE("XSE::Messaging(): Registered for PapyrusTerminal messaging.");
			}
		}

		/// <summary>
		/// Register the Scaleform XSE code object.
		/// </summary>
		/// <param name="scaleform"></param>
		void Scaleform(F4SEScaleformInterface* scaleform)
		{
			if (scaleform->Register("Computer", Computing::Scaleform::RegisterScaleform))
			{
				_MESSAGE("XSE::Scaleform(): Registered Scaleform");
			}
		}

		/// <summary>
		/// Register the Papyrus scripts & functions.
		/// </summary>
		/// <param name="papyrus"></param>
		void Papyrus(F4SEPapyrusInterface* papyrus)
		{
			if (papyrus->Register(Computing::Papyrus::RegisterPapyrus))
			{
				_MESSAGE("XSE::Papyrus(): Registered Papyrus");
			}
		}


	}

}


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
			_MESSAGE("Main::F4SEPlugin_Query(): Loaded in editor, marking as incompatible.");
			return false;
		}
		else if (f4se->runtimeVersion < MINIMUM_RUNTIME_VERSION)
		{
			_MESSAGE("Main::F4SEPlugin_Query(): Unsupported runtime version %d", f4se->runtimeVersion);
			return false;
		}

		// Query the papyrus interface
		g_papyrus = (F4SEPapyrusInterface*)f4se->QueryInterface(kInterface_Papyrus);
		if (!g_papyrus)
		{
			_FATALERROR("Main::F4SEPlugin_Query(): Could not get the XSE Papyrus interface.");
			return false;
		}

		// Query the scaleform interface
		g_scaleform = (F4SEScaleformInterface*)f4se->QueryInterface(kInterface_Scaleform);
		if (!g_scaleform)
		{
			_FATALERROR("Main::F4SEPlugin_Query(): Could not get the XSE Scaleform interface.");
			return false;
		}

		// Query the messaging interface
		g_messaging = (F4SEMessagingInterface*)f4se->QueryInterface(kInterface_Messaging);
		if (!g_messaging)
		{
			_FATALERROR("Main::F4SEPlugin_Query(): Could not get the XSE Messaging interface.");
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
		Computing::XSE::Messaging(g_messaging);
		Computing::XSE::Scaleform(g_scaleform);
		Computing::XSE::Papyrus(g_papyrus);

		return true;
	}


};
