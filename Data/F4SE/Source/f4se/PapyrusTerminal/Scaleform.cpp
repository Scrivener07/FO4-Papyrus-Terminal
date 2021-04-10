#include "Scaleform.h"

void PapyrusTerminal_WriteLog::Invoke(Args* args)
{
	ASSERT(args->numArgs >= 1);
	ASSERT(args->args[0].GetType() == GFxValue::kType_String);
	_MESSAGE(args->args[0].GetString());
}
