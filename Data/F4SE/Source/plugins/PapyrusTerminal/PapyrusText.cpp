#include "PapyrusText.h"
#include "f4se/PapyrusArgs.h"
#include "f4se/PapyrusEvents.h"
#include "f4se/PapyrusNativeFunctions.h"
//---------------------------------------------

namespace SNE
{
	const char* SNE::TextScript::SCRIPTNAME = "Computer:Text";


	void SNE::TextScript::Split(StaticFunctionTag* self, BSFixedString line, BSFixedString separator)
	{
		_MESSAGE("TextScript::Split(): '%s' | '%s'", line.c_str(), separator.c_str());
	}



	bool SNE::TextScript::OnRegister(VirtualMachine* vm)
	{
		_MESSAGE("TextScript::OnRegister()");
		vm->RegisterFunction(new NativeFunction2 <StaticFunctionTag, void, BSFixedString, BSFixedString>("Split", TextScript::SCRIPTNAME, TextScript::Split, vm));
		return true;
	}


	void SNE::TextScript::Papyrus(F4SEPapyrusInterface* papyrus)
	{
		if (papyrus->Register(TextScript::OnRegister))
		{
			_MESSAGE("TextScript::Papyrus(): Registered the text script.");
		}
	}


}
