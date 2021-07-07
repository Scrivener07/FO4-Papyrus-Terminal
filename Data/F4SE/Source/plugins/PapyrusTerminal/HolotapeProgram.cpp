#include "HolotapeProgram.h"
#include "f4se/PluginAPI.h"
#include "f4se/GameMenus.h"
#include "f4se/ScaleformCallbacks.h"
//---------------------------------------------

namespace SNE
{
	const char* SNE::HolotapeProgram::SWF = "PapyrusTerminal.swf";
	const char* SNE::HolotapeProgram::AS3 = "SNE";


	bool SNE::HolotapeProgram::IsProgram(GFxMovieRoot* movieRoot)
	{
		if (movieRoot)
		{
			GFxValue url;
			if (movieRoot->GetVariable(&url, "root.loaderInfo.url"))
			{
				// Get the full file path to the swf.
				std::string filepath = url.GetString();
				return filepath.find("PapyrusTerminal.swf") != std::string::npos;
			}
			else
			{
				_MESSAGE("IsProgram: There is no valid movie loader url.");
				return false;
			}
		}
		else
		{
			_MESSAGE("IsProgram: There is no valid movie root.");
			return false;
		}
	}


	bool SNE::HolotapeProgram::Register(GFxMovieView* view, GFxValue* f4se)
	{
		GFxMovieRoot* movieRoot = view->movieRoot;
		if (movieRoot)
		{
			if (IsProgram(movieRoot))
			{
				_MESSAGE("HolotapeProgram::OnRegister(): This is a Papyrus program.");
			}
			else
			{
				_MESSAGE("HolotapeProgram::OnRegister(): There is no valid movie url.");
			}
		}
		else
		{
			_MESSAGE("HolotapeProgram::OnRegister(): There is no valid movie root.");
		}

		return true;
	}


	void SNE::HolotapeProgram::Scaleform(F4SEScaleformInterface* scaleform)
	{
		if (scaleform->Register(SNE::HolotapeProgram::AS3, SNE::HolotapeProgram::Register))
		{
			_MESSAGE("HolotapeProgram::Scaleform(): Registered Scaleform");
		}
	}


}
