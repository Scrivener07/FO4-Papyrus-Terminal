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
#include "f4se_common/SafeWrite.h"

// F4SE - Common
#include <common/IDirectoryIterator.h>

// Papyrus
#include "f4se/PapyrusObjects.h"
#include "f4se/PapyrusVM.h"
#include "f4se/PapyrusArgs.h"
#include "f4se/PapyrusNativeFunctions.h"
#include "f4se/PapyrusInstanceData.h"
#include "f4se/PapyrusEvents.h"

// Scaleform
#include "F4SE/GameMenus.h"
#include "F4SE/ScaleformCallbacks.h"

// Game
#include "f4se/GameTypes.h"
#include "f4se/GameForms.h"
#include "f4se/GameObjects.h"
#include "f4se/GameReferences.h"
#include "f4se/GameData.h"
#include "f4se/GameExtraData.h"

// Plugin - Xtensions
#include "plugins/Xtensions/Common.h"
#include "plugins/Xtensions/XSE.h"
#include "plugins/Xtensions/Bethesda.h"
#include "plugins/Xtensions/SystemTime.h"

// SNE
#include "Main.h"
#include "Menu.h"
#include "INV.h"
#include "HolotapeProgram.h"
#include "PapyrusKernel.h"
#include "PapyrusText.h"

//---------------------------------------------

IDebugLog                   gLog;
PluginHandle                g_pluginHandle = kPluginHandle_Invalid;
F4SEMessagingInterface*     g_messaging = NULL;
F4SEPapyrusInterface*       g_papyrus   = NULL;
F4SEScaleformInterface*     g_scaleform = NULL;
F4SESerializationInterface* g_serialization = NULL;
F4SEObjectInterface*        g_object = NULL;


namespace SNE
{

	#pragma region Events

	class MenuOpenCloseEventHandler : public BSTEventSink<MenuOpenCloseEvent>
	{
		public:
		virtual ~MenuOpenCloseEventHandler() { };

		/// <summary>
		/// The implementation for the MenuOpenCloseEvent handler.
		/// </summary>
		/// <param name="e">The MenuOpenCloseEvent to use.</param>
		/// <param name="dispatcher">The dispatcher to use.</param>
		/// <returns>The event result.</returns>
		virtual	EventResult	ReceiveEvent(MenuOpenCloseEvent* e, void* dispatcher) override
		{
			_MESSAGE("MenuOpenCloseEventHandler: menuName: '%s', isOpen: `%s`", std::string(e->menuName).c_str(), BoolToString(e->isOpen));

			// The script event registrations are no longer valid at this point since
			// a holotape is moved from the player inventory to a terminal inventory.

			static BSFixedString sConsoleMenu(MenuName::ConsoleMenu);
			static BSFixedString sTerminalHolotapeMenu(MenuName::TerminalHolotapeMenu);
			static BSFixedString sPipboyHolotapeMenu(MenuName::PipboyHolotapeMenu);

			if (e->menuName == sConsoleMenu && e->isOpen) // TODO: testing only
			{
				_MESSAGE("%s: Opening the menu.", std::string(e->menuName).c_str());
				INV();
				return kEvent_Continue;
			}
			else if (e->menuName == sTerminalHolotapeMenu)
			{
				if (e->isOpen)
				{
					_MESSAGE("%s: Opening the menu.", std::string(e->menuName).c_str());
					SNE::KernelScript::SendEventStartup();
				}
				else
				{
					_MESSAGE("%s: Closing the menu.", std::string(e->menuName).c_str());
					SNE::KernelScript::SendEventShutdown();
				}
			}
			else if (e->menuName == sPipboyHolotapeMenu)
			{
				if (e->isOpen)
				{
					_MESSAGE("%s: Opening the menu.", std::string(e->menuName).c_str());
					SNE::KernelScript::SendEventStartup();
				}
				else
				{
					_MESSAGE("%s: Closing the menu.", std::string(e->menuName).c_str());
					SNE::KernelScript::SendEventShutdown();
				}
			}

			return kEvent_Continue;
		};


		/// <summary>
		/// Register the event handler type.
		/// </summary>
		static void Register()
		{
			_MESSAGE("MenuOpenCloseEventHandler::Register");
			static auto* pHandler = new MenuOpenCloseEventHandler();
			(*g_ui)->menuOpenCloseEventSource.AddEventSink(pHandler);
		}
	};




	// TODO: pipboy has no furniture event
	// TODO: A DYNAMIC_CAST call might be able to cast baseForm into a Terminal type.
	// TODO: A holotape is removed well after the Terminal sit-down event, this is too early.
	class TESFurnitureEventHandler : public BSTEventSink<TESFurnitureEvent>
	{
		public:
		virtual ~TESFurnitureEventHandler() { };

		virtual	EventResult	ReceiveEvent(TESFurnitureEvent* e, void* dispatcher) override
		{
			if (e->furniture->baseForm->formType == kFormType_TERM)
			{
				_MESSAGE("");
				_MESSAGE("TESFurnitureEventHandler|TERMINAL");
				_MESSAGE("TESFurnitureEventHandler|-->isGettingUp: %s", BoolToString(e->isGettingUp));

				TESObjectREFREx::Dump(e->furniture);
				ActorEx::Dump(e->actor);

				//if (e->isGettingUp)
				//{
				//	SNE::KernelScript::SendEventShutdown();
				//}
				//else
				//{
				//	SNE::KernelScript::SendEventStartup();
				//}

				_MESSAGE("");
			}

			return kEvent_Continue;
		}

		/// <summary>
		/// Register the event handler type.
		/// </summary>
		static void Register()
		{
			_MESSAGE("TESFurnitureEventHandler::Register");
			static auto handler = new TESFurnitureEventHandler();
			GetEventDispatcher<TESFurnitureEvent>()->AddEventSink(handler);
		}
	};


	class TESLoadGameHandler : public BSTEventSink<TESLoadGameEvent>
	{
		public:
		virtual ~TESLoadGameHandler() { };

		virtual EventResult ReceiveEvent(TESLoadGameEvent* e, void* dispatcher) override
		{
			_MESSAGE("TESLoadGameHandler::ReceiveEvent");
			return kEvent_Continue;
		}

		/// <summary>
		/// Register the event handler type.
		/// </summary>
		static void Register()
		{
			_MESSAGE("TESLoadGameHandler::Register");
			static auto handler = new TESLoadGameHandler();
			GetEventDispatcher<TESLoadGameEvent>()->AddEventSink(handler);
		}
	};


	class TESObjectLoadedEventHandler : public BSTEventSink<TESObjectLoadedEvent>
	{
		public:
		virtual ~TESObjectLoadedEventHandler() { };

		virtual	EventResult	ReceiveEvent(TESObjectLoadedEvent* e, void* dispatcher) override
		{
			_MESSAGE("TESObjectLoadedEventHandler: formid: '%i', loaded: %s", e->formId, BoolToString(IntToBool(e->loaded)));
			return kEvent_Continue;
		}

		/// <summary>
		/// Register the event handler type.
		/// </summary>
		static void Register()
		{
			_MESSAGE("TESObjectLoadedEventHandler::Register");
			static auto handler = new TESObjectLoadedEventHandler();
			GetEventDispatcher<TESObjectLoadedEvent>()->AddEventSink(handler);
		}
	};


	class TESInitScriptEventHandler : public BSTEventSink<TESInitScriptEvent>
	{
		public:
		virtual ~TESInitScriptEventHandler() { };

		virtual	EventResult	ReceiveEvent(TESInitScriptEvent* e, void* dispatcher) override
		{
			_MESSAGE("");
			_MESSAGE("TESInitScriptEventHandler|TESObjectREFR");
			_MESSAGE("TESInitScriptEventHandler|-->formID:%x", e->reference->formID);
			_MESSAGE("TESInitScriptEventHandler|-->GetFormType:%s", FormTypeEx::ToString(e->reference->GetFormType()));
			_MESSAGE("TESInitScriptEventHandler|-->GetEditorID:%s", e->reference->GetEditorID());
			_MESSAGE("TESInitScriptEventHandler|-->GetFullName:%s", e->reference->GetFullName());
			_MESSAGE("");

			return kEvent_Continue;
		}

		/// <summary>
		/// Register the event handler type.
		/// </summary>
		static void Register()
		{
			_MESSAGE("TESInitScriptEventHandler::Register");
			static auto handler = new TESInitScriptEventHandler();
			GetEventDispatcher<TESInitScriptEvent>()->AddEventSink(handler);
		}
	};

	#pragma endregion


	//---------------------------------------------

	#pragma region MenuModeChangeEventHandler

		//class MenuModeChangeEventHandler : public BSTEventSink<MenuModeChangeEvent>
		//{
		//	public:
		//	virtual ~MenuModeChangeEventHandler() { };

		//	virtual	EventResult	ReceiveEvent(MenuModeChangeEvent* e, void* dispatcher) override
		//	{
		//		_MESSAGE("MenuModeChangeEventHandler");
		//		return kEvent_Continue;
		//	}

		//	/// <summary>
		//	/// Register the event handler type.
		//	/// </summary>
		//	static void Register()
		//	{
		//		_MESSAGE("MenuModeChangeEventHandler::Register");
		//		static auto handler = new MenuModeChangeEventHandler();
		//		GetEventDispatcher<MenuModeChangeEvent>()->AddEventSink(handler);
		//	}
		//};

	#pragma endregion

	#pragma region InventoryEventHandler

		//class InventoryEventHandler : public BSTEventSink<BGSInventoryListEvent>
		//{
		//	public:
		//	virtual ~InventoryEventHandler() { };

		//	virtual EventResult ReceiveEvent(BGSInventoryListEvent* e, void* dispatcher) override
		//	{
		//		_MESSAGE("InventoryEventHandler::ReceiveEvent");
		//		return kEvent_Continue;
		//	}

		//	/// <summary>
		//	/// Register the event handler type.
		//	/// </summary>
		//	static void Register()
		//	{
		//		_MESSAGE("InventoryEventHandler::Register");
		//		static auto handler = new InventoryEventHandler();
		//		GetEventDispatcher<BGSInventoryListEvent>()->AddEventSink(handler);
		//	}
		//};

	#pragma endregion

	#pragma region BSSubGraphActivationUpdateHandler

		//class BSSubGraphActivationUpdateHandler : public BSTEventSink<BSSubGraphActivationUpdate>
		//{
		//	public:
		//	virtual ~BSSubGraphActivationUpdateHandler() { };

		//	virtual	EventResult	ReceiveEvent(BSSubGraphActivationUpdate* e, void* dispatcher) override
		//	{
		//		_MESSAGE("BSSubGraphActivationUpdateHandler");
		//		return kEvent_Continue;
		//	}

		//	/// <summary>
		//	/// Register the event handler type.
		//	/// </summary>
		//	static void Register()
		//	{
		//		_MESSAGE("BSSubGraphActivationUpdateHandler::Register");
		//		static auto handler = new BSSubGraphActivationUpdateHandler();
		//		GetEventDispatcher<BSSubGraphActivationUpdate>()->AddEventSink(handler);
		//	}
		//};

	#pragma endregion


	//---------------------------------------------


	void SNE::PluginContext::OnEvent(F4SEMessagingInterface::Message* message)
	{
		_MESSAGE("PluginContext::OnEvent(), type: %s", XSE_MessagingInterface::ToString(message->type));

		if (message->type == F4SEMessagingInterface::kMessage_GameDataReady)
		{ // Sent when the data handler is ready. Data is false before loading, true when finished loading.
			SNE::TESLoadGameHandler::Register();
			SNE::TESObjectLoadedEventHandler::Register();
		}
		else if (message->type == F4SEMessagingInterface::kMessage_GameLoaded)
		{ // Sent after the game has finished loading.
			//SNE::TESInitScriptEventHandler::Register();
			SNE::MenuOpenCloseEventHandler::Register();
			SNE::TESFurnitureEventHandler::Register();
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
			_FATALERROR("Main::Query(): Could not get the XSE-Papyrus interface.");
			return false;
		}

		// Query the scaleform interface
		g_scaleform = (F4SEScaleformInterface*)f4se->QueryInterface(kInterface_Scaleform);
		if (!g_scaleform)
		{
			_FATALERROR("Main::Query(): Could not get the XSE-Scaleform interface.");
			return false;
		}

		// Query the messaging interface
		g_messaging = (F4SEMessagingInterface*)f4se->QueryInterface(kInterface_Messaging);
		if (!g_messaging)
		{
			_FATALERROR("Main::Query(): Could not get the XSE-Messaging interface.");
			return false;
		}

		// Query the serialization interface
		g_serialization = (F4SESerializationInterface*)f4se->QueryInterface(kInterface_Serialization);
		if (!g_serialization)
		{
			_FATALERROR("Main::Query(): Could not get the XSE-Serialization interface.");
			return false;
		}

		// Query the object interface
		g_object = (F4SEObjectInterface*)f4se->QueryInterface(kInterface_Object);
		if (!g_object)
		{
			_FATALERROR("Main::Query(): Could not get the XSE-Object interface.");
			return false;
		}

		return true;
	}


	/// <summary>
	/// The XSE plugin load handler.
	/// </summary>
	/// <param name="f4se"></param>
	/// <returns>true on success</returns>
	bool F4SEPlugin_Load(const F4SEInterface * f4se)
	{
		_MESSAGE("Main::Load()");

		if (g_messaging->RegisterListener(g_pluginHandle, "F4SE", SNE::PluginContext::OnEvent))
		{
			_MESSAGE("Main::Load(): Registered for XSE messaging events.");
		}
		else
		{
			_FATALERROR("Main::Load(): Could not get the XSE-Messaging interface.");
			return false;
		}

		SNE::HolotapeProgram::Scaleform(g_scaleform);
		SNE::KernelScript::Papyrus(g_papyrus);
		SNE::TextScript::Papyrus(g_papyrus);

		return true;
	}


};
