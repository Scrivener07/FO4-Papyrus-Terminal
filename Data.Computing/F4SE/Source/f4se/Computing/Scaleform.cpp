#include "Scaleform.h"

namespace Scaleform
{
	void RegisterUnmanagedString(GFxValue* dst, const char* name, const char* str)
	{
		GFxValue	fxValue;
		fxValue.SetString(str);
		dst->SetMember(name, &fxValue);
	}

	void RegisterString(GFxValue* dst, GFxMovieRoot* root, const char* name, const char* str)
	{
		GFxValue fxValue;
		root->CreateString(&fxValue, str);
		dst->SetMember(name, &fxValue);
	}

	void RegisterNumber(GFxValue* dst, const char* name, double value)
	{
		GFxValue fxValue;
		fxValue.SetNumber(value);
		dst->SetMember(name, &fxValue);
	}

	void RegisterInt(GFxValue* dst, const char* name, int value)
	{
		GFxValue fxValue;
		fxValue.SetInt(value);
		dst->SetMember(name, &fxValue);
	}

	void RegisterBool(GFxValue* dst, const char* name, bool value)
	{
		GFxValue fxValue;
		fxValue.SetBool(value);
		dst->SetMember(name, &fxValue);
	}
}


// Functions
// ---------------------------------------------

/// <summary>
/// Exposes the XSE log tracing method to Scaleform.
/// </summary>
/// <param name="args">The arguments to use.</param>
void Computing_WriteLog::Invoke(Args* args)
{
	_MESSAGE("Computing_WriteLog()::Invoke");
	ASSERT(args->numArgs >= 1);
	ASSERT(args->args[0].GetType() == GFxValue::kType_String);
	_MESSAGE(args->args[0].GetString());
}


///// <summary>
///// Gets the current directory.
///// </summary>
///// <param name="args">The arguments to use.</param>
//void Computing_GetDirectoryCurrent::Invoke(Args* args)
//{
//	_MESSAGE("Computing_GetDirectoryCurrent()::Invoke, {E:\\Bethesda\\steamapps\\common\\Fallout 4}");
//
//	//GFxValue object;
//	//Scaleform::RegisterUnmanagedString(&object, "CurrentDirectory", "Scrivener");
//	//args->result->PushBack(&object);
//}


// XSE
// ---------------------------------------------

/// <summary>
/// Register native functions which are accessible in Scaleform AS3 via the XSE code object.
/// </summary>
/// <param name="view">The scaleform movie view to use.</param>
/// <param name="F4SERoot">The root Scaleform XSE code object to use.</param>
/// <returns>true on success</returns>
bool Scaleform::RegisterFunctions(GFxMovieView* view, GFxValue* F4SERoot)
{
	GFxMovieRoot* movieRoot = view->movieRoot;
	if (movieRoot)
	{
		GFxValue loaderInfo;
		if (movieRoot->GetVariable(&loaderInfo, "root.loaderInfo.url"))
		{
			// Get the swf file path.
			std::string sResult = loaderInfo.GetString();
			_MESSAGE("Scaleform::RegisterFunctions(): Checking: '%s'", sResult);

			// Check the resulting file path for the papyrus terminal swf.
			if (sResult.find(COMPUTING_OS_SWF) != std::string::npos)
			{
				_MESSAGE("Scaleform::RegisterFunctions(): Using: '%s'", sResult);

				RegisterFunction<Computing_WriteLog>(F4SERoot, view->movieRoot, "WriteLog");

				//RegisterFunction<Computing_GetDirectoryCurrent>(F4SERoot, view->movieRoot, "GetDirectoryCurrent");
			}
			else
			{
				_MESSAGE("Scaleform::RegisterFunctions(): The movie url does not match '%s'.", COMPUTING_OS_SWF);
			}
		}
		else
		{
			_MESSAGE("Scaleform::RegisterFunctions(): There is no valid movie url.");
		}
	}
	else
	{
		_MESSAGE("Scaleform::RegisterFunctions(): There is no valid movie root.");
	}

	return true;
}
