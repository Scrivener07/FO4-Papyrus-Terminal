#pragma once
//---------------------------------------------

// Manufacture: NISTRON SNE
#define PLUGIN_NAME               "PapyrusTerminal"
#define PLUGIN_VERSION            1
#define PLUGIN_LOG_FILE           "\\My Games\\Fallout4\\F4SE\\PapyrusTerminal.log"
#define MINIMUM_RUNTIME_VERSION   RUNTIME_VERSION_1_10_163

namespace SNE
{
	/// <summary>
	/// The context for this XSE plugin.
	/// </summary>
	class PluginContext
	{

		public:

		/// <summary>
		/// Handle the F4SE provided plugin messages.
		/// Sent after the game has finished loading.
		/// This is only sent once.
		/// </summary>
		/// <param name="message"></param>
		static void OnEvent(F4SEMessagingInterface::Message* message);

	};
}
