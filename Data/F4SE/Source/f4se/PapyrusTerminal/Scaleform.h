#pragma once
#include "F4SE/ScaleformCallbacks.h"
#include "f4se/GameMenus.h"

namespace Scaleform
{
	bool RegisterFunctions(GFxMovieView* view, GFxValue* F4SERoot);
}


class PapyrusTerminal_WriteLog : public GFxFunctionHandler
{
	public:
		virtual void Invoke(Args* args);
};
