#pragma once
#include "F4SE/ScaleformCallbacks.h"

class PapyrusTerminal_WriteLog : public GFxFunctionHandler
{
public:
	virtual void Invoke(Args* args);
};
