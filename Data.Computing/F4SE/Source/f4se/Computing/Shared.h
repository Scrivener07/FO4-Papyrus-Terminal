#pragma once
#include "F4SE/ScaleformCallbacks.h"
#include "f4se/PluginAPI.h"

namespace Computing
{

	class Time
	{
		public:
		static const char* GetTime();
		static const char* GetDay();
		static const char* GetMonth();
		static const char* GetYear();
		static const char* GetDateTime();
	};


	namespace Scaleform
	{
		void RegisterUnmanagedString(GFxValue* dst, const char* name, const char* str);
		void RegisterString(GFxValue* dst, GFxMovieRoot* root, const char* name, const char* str);
		void RegisterNumber(GFxValue* dst, const char* name, double value);
		void RegisterInt(GFxValue* dst, const char* name, int value);
		void RegisterBool(GFxValue* dst, const char* name, bool value);
	}

}

const char* MessageToString(F4SEMessagingInterface::Message* message);
