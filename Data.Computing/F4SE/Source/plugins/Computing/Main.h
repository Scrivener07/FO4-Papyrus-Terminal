#pragma once
//---------------------------------------------

#define PLUGIN_NAME               "Computing"
#define PLUGIN_VERSION            1
#define PLUGIN_LOG_FILE           "\\My Games\\Fallout4\\F4SE\\Computing.log"
#define MINIMUM_RUNTIME_VERSION   RUNTIME_VERSION_1_10_163

namespace Computing
{
	namespace Papyrus
	{

		/// <summary>
		/// Registers the native papyrus functions for this XSE plugin.
		/// </summary>
		/// <param name="vm">The virtual machine to use.</param>
		/// <returns>true on success</returns>
		bool RegisterPapyrus(VirtualMachine* VM);

	}


	namespace Scaleform
	{
		/// <summary>
		/// Register native functions which are accessible in Scaleform AS3 via the XSE code object.
		/// </summary>
		/// <param name="view">The scaleform movie view to use.</param>
		/// <param name="F4SERoot">The root Scaleform XSE code object to use.</param>
		/// <returns>true on success</returns>
		bool RegisterScaleform(GFxMovieView* view, GFxValue* F4SERoot);


		/// <summary>
		/// Exposes the XSE log tracing method to Scaleform.
		/// </summary>
		/// <param name="args">The arguments to use.</param>
		class Computer_WriteLog : public GFxFunctionHandler
		{
			public:
			virtual void Invoke(Args* arguments);
		};


	}

	/// <summary>
	/// Handle the F4SE provided plugin messages.
	/// Sent after the game has finished loading.
	/// This is only sent once.
	/// </summary>
	/// <param name="message"></param>
	void OnF4SE(F4SEMessagingInterface::Message* message);

}
