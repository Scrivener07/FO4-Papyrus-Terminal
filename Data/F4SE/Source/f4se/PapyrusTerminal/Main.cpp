// https://github.com/kassent/BetterConsole

// F4SE
#include "f4se/PluginAPI.h"
#include "f4se/PapyrusNativeFunctions.h"
#include "F4SE/GameMenus.h"
#include "f4se/GameReferences.h"
#include "xbyak/xbyak.h"

// Common
#include "f4se_common/f4se_version.h"
#include <shlobj.h>	// CSIDL_MYCODUMENTS

// Project
#include "Scaleform.h"

static F4SEPapyrusInterface* g_papyrus = NULL;

IDebugLog               gLog;
PluginHandle            g_pluginHandle = kPluginHandle_Invalid;
F4SEScaleformInterface* g_scaleform = nullptr;
F4SEMessagingInterface* g_messaging = nullptr;


namespace Scripting
{
	void Test(StaticFunctionTag *base)
	{
		_MESSAGE("Papyrus: @Log TestClass.Test()");
		Console_Print("Papyrus: @Console TestClass.Test()");
	}
}

bool RegisterFuncs(VirtualMachine* vm)
{
	vm->RegisterFunction(new NativeFunction0 <StaticFunctionTag, void>("Test", "PapyrusTerminal:KERNAL", Scripting::Test, vm));
	return true;
}


bool ScaleformCallback(GFxMovieView* view, GFxValue* value)
{
	GFxMovieRoot* movieRoot = view->movieRoot;
	if (movieRoot)
	{
		GFxValue loaderInfo;
		if (movieRoot->GetVariable(&loaderInfo, "root.loaderInfo.url"))
		{
			std::string sResult = loaderInfo.GetString();
			if (sResult.find("TerminalHolotapeMenu.swf") != std::string::npos)
			{
				_MESSAGE("Using Movie: TerminalHolotapeMenu.swf");
				RegisterFunction<PapyrusTerminal_WriteLog>(value, view->movieRoot, "WriteLog");
			}

			if (sResult.find("PapyrusTerminal.swf") != std::string::npos)
			{
				_MESSAGE("Using Movie: PapyrusTerminal.swf");
				RegisterFunction<PapyrusTerminal_WriteLog>(value, view->movieRoot, "WriteLog");
			}
		}
	}
	return true;
}


class MenuOpenCloseHandler : public BSTEventSink<MenuOpenCloseEvent>
{
public:
	virtual ~MenuOpenCloseHandler() { };
	virtual	EventResult	ReceiveEvent(MenuOpenCloseEvent* evn, void* dispatcher) override
	{
		static BSFixedString sMenuName("TerminalHolotapeMenu");
		if (evn->menuName == sMenuName && evn->isOpen)
		{
			GFxValue dispatchEvent;
			GFxValue eventArgs[3];
			IMenu* pHolotapeMenu = (*g_ui)->GetMenu(sMenuName);
			auto* movieRoot = pHolotapeMenu->movie->movieRoot;
			movieRoot->CreateString(&eventArgs[0], "OnPapyrusTerminal"); // @as3
			eventArgs[1].SetBool(true);
			eventArgs[2].SetBool(false);
			movieRoot->CreateObject(&dispatchEvent, "flash.events.Event", eventArgs, 3);
			movieRoot->Invoke("root.dispatchEvent", nullptr, &dispatchEvent, 1);
		}
		return kEvent_Continue;
	};

	static void Register()
	{
		static auto* pHandler = new MenuOpenCloseHandler();
		(*g_ui)->menuOpenCloseEventSource.AddEventSink(pHandler);
	}
};

void F4SEMessageHandler(F4SEMessagingInterface::Message* msg)
{
	if (msg->type == F4SEMessagingInterface::kMessage_GameLoaded)
	{
		MenuOpenCloseHandler::Register();
	}
}


/* Plugin Query */
extern "C"
{
	bool F4SEPlugin_Query(const F4SEInterface* f4se, PluginInfo* info)
	{
		gLog.OpenRelative(CSIDL_MYDOCUMENTS, "\\My Games\\Fallout4\\F4SE\\PapyrusTerminal.log");
		gLog.SetPrintLevel(IDebugLog::kLevel_Error);
		gLog.SetLogLevel(IDebugLog::kLevel_DebugMessage);

		// populate info structure
		info->infoVersion = PluginInfo::kInfoVersion;
		info->name = "PapyrusTerminal";
		info->version = 1;

		g_pluginHandle = f4se->GetPluginHandle();


		if (f4se->isEditor)
		{
			_MESSAGE("loaded in editor, marking as incompatible");
			return false;
		}
		else if (f4se->runtimeVersion != RUNTIME_VERSION_1_10_163)
		{
			_MESSAGE("unsupported runtime version %d", f4se->runtimeVersion);
			return false;
		}

		g_scaleform = (F4SEScaleformInterface*)f4se->QueryInterface(kInterface_Scaleform);
		if (!g_scaleform)
		{
			_FATALERROR("couldn't get scaleform interface");
			return false;
		}

		g_messaging = (F4SEMessagingInterface*)f4se->QueryInterface(kInterface_Messaging);
		if (!g_messaging)
		{
			_FATALERROR("couldn't get messaging interface");
			return false;
		}

		_MESSAGE("F4SEPlugin_Query Loaded");

		// supported runtime version
		return true;
	}

	bool F4SEPlugin_Load(const F4SEInterface * f4se)
	{
		g_papyrus = (F4SEPapyrusInterface *)f4se->QueryInterface(kInterface_Papyrus);

		if (g_papyrus->Register(RegisterFuncs))
		{
			_MESSAGE("F4SEPlugin_Load Funcs Registered");
		}

		if (g_messaging != nullptr)
		{
			g_messaging->RegisterListener(g_pluginHandle, "F4SE", F4SEMessageHandler);
		}

		if (g_scaleform)
		{
			g_scaleform->Register("Kernal", ScaleformCallback);
		}

		_MESSAGE("F4SEPlugin_Load Loaded");
		return true;
	}

};
