#pragma once
#include "F4SE/ScaleformCallbacks.h"
#include "f4se/GameMenus.h"

#define COMPUTING_OS_SWF "Computer_OS.swf"

namespace Scaleform
{
	bool RegisterFunctions(GFxMovieView* view, GFxValue* F4SERoot);
}


class Computing_WriteLog : public GFxFunctionHandler
{
	public:
		virtual void Invoke(Args* args);
};

//
//class Computing_GetDirectoryCurrent : public GFxFunctionHandler
//{
//	public:
//		virtual void Invoke(Args* args);
//};

