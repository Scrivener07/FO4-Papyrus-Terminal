#include "Scaleform.h"

namespace Scaleform { }

/// <summary>
/// Exposes the XSE log tracing method to Scaleform.
/// </summary>
/// <param name="args">The arguments to use.</param>
void PapyrusTerminal_WriteLog::Invoke(Args* args)
{
	ASSERT(args->numArgs >= 1);
	ASSERT(args->args[0].GetType() == GFxValue::kType_String);
	_MESSAGE(args->args[0].GetString());
}


// XSE
// ---------------------------------------------

/// <summary>
/// Registers the Scaleform functions for this XSE plugin.
/// </summary>
/// <param name="view">The scaleform movie view to use.</param>
/// <param name="F4SERoot">The root Scaleform XSE code object to use.</param>
/// <returns>true on success</returns>
bool Scaleform::RegisterFunctions(GFxMovieView* view, GFxValue* F4SERoot)
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
				_MESSAGE("Scaleform::RegisterFunctions(): Using Movie: TerminalHolotapeMenu.swf");
				RegisterFunction<PapyrusTerminal_WriteLog>(F4SERoot, view->movieRoot, "WriteLog");
			}

			if (sResult.find("PapyrusTerminal.swf") != std::string::npos)
			{
				_MESSAGE("Scaleform::RegisterFunctions(): Using Movie: PapyrusTerminal.swf");
				RegisterFunction<PapyrusTerminal_WriteLog>(F4SERoot, view->movieRoot, "WriteLog");
			}
		}
	}
	return true;
}
