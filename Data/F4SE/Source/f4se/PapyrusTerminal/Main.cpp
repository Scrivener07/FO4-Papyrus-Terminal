// Common
#include "f4se_common/f4se_version.h"
#include <shlobj.h>	// CSIDL_MYCODUMENTS

// F4SE
#include "f4se/PluginAPI.h"

// Project
#include "Main.h"


// Fields
// ---------------------------------------------

IDebugLog               gLog;
PluginHandle            g_pluginHandle = kPluginHandle_Invalid;
//F4SEMessagingInterface* g_messaging = NULL;
//F4SEPapyrusInterface*   g_papyrus   = NULL;
//F4SEScaleformInterface* g_scaleform = NULL;


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


		return true;
	}


	/// <summary>
	/// The XSE plugin load handler.
	/// </summary>
	/// <param name="f4se"></param>
	/// <returns>true on success</returns>
	bool F4SEPlugin_Load(const F4SEInterface * f4se)
	{
		return true;
	}


};
