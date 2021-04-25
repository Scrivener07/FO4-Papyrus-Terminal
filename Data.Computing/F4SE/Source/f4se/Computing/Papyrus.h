#pragma once
#include "f4se/PapyrusVM.h"



namespace Papyrus
{
	bool RegisterFunctions(VirtualMachine* VM);

	const char* GetCurrentDirectory();
}
