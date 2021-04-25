#pragma once
#include "F4SE/ScaleformCallbacks.h"
#include "f4se/GameMenus.h"

#define PAPYRUS_TERMINAL_SWF "PapyrusTerminal.swf"

namespace Scaleform
{
	bool RegisterFunctions(GFxMovieView* view, GFxValue* F4SERoot);
}


class PapyrusTerminal_WriteLog : public GFxFunctionHandler
{
	public:
		virtual void Invoke(Args* args);
};

//
//class PapyrusTerminal_GetDirectoryCurrent : public GFxFunctionHandler
//{
//	public:
//		virtual void Invoke(Args* args);
//};

