#pragma once
#include "f4se/PluginAPI.h"
#include "F4SE/GameMenus.h"
#include "F4SE/ScaleformCallbacks.h"
//---------------------------------------------

namespace SNE
{
	namespace AS3
	{
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


	class HolotapeProgram
	{
		public:

		/// <summary>
		/// The swf file for this holotape program.
		/// </summary>
		static const char* SWF;

		/// <summary>
		/// The AS3 code object to use.
		/// </summary>
		static const char* AS3;

		/// <summary>
		/// Register the Scaleform XSE code object.
		/// </summary>
		/// <param name="scaleform"></param>
		static void Scaleform(F4SEScaleformInterface* scaleform);

		static bool IsProgram(GFxMovieRoot* movieRoot);


		private:

		/// <summary>
		/// Register native functions which are accessible in Scaleform AS3 via the XSE code object.
		/// </summary>
		/// <param name="view">The scaleform movie view to use.</param>
		/// <param name="F4SERoot">The root Scaleform XSE code object to use.</param>
		/// <returns>true on success</returns>
		static bool Register(GFxMovieView* view, GFxValue* F4SERoot);
	};


}
