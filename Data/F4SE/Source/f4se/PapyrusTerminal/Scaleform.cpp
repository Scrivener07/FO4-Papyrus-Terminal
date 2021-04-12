#include "Scaleform.h"

void PapyrusTerminal_WriteLog::Invoke(Args* args)
{
	ASSERT(args->numArgs >= 1);
	ASSERT(args->args[0].GetType() == GFxValue::kType_String);
	_MESSAGE(args->args[0].GetString());
}


namespace Scaleform
{
}


// XSE
// ---------------------------------------------

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
				_MESSAGE("Main:ScaleformCallback(), Using Movie: TerminalHolotapeMenu.swf");
				RegisterFunction<PapyrusTerminal_WriteLog>(F4SERoot, view->movieRoot, "WriteLog");
			}

			if (sResult.find("PapyrusTerminal.swf") != std::string::npos)
			{
				_MESSAGE("Main:ScaleformCallback(), Using Movie: PapyrusTerminal.swf");
				RegisterFunction<PapyrusTerminal_WriteLog>(F4SERoot, view->movieRoot, "WriteLog");
			}
		}
	}
	return true;
}
