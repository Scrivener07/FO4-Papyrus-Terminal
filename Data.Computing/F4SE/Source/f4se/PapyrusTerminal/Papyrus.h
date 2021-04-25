#pragma once
#include "f4se/PapyrusVM.h"

#define SCRIPT_KERNAL "PapyrusTerminal:KERNAL"

namespace Papyrus
{
	bool RegisterFunctions(VirtualMachine* VM);

	const char* GetCurrentDirectory();
}
