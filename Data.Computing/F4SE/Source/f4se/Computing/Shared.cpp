#include "Shared.h"
#include <ctime>
#include "f4se/PluginAPI.h"

/// <remarks>
/// Note: The f4se file system objects (AS3) are derived from these types.
/// http://www.cs.rpi.edu/courses/fall01/os/WIN32_FIND_DATA.html <-----
/// https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfilea
/// https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findnextfilea
/// https://docs.microsoft.com/en-us/cpp/standard-library/directory-iterator-class
/// https://docs.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-win32_find_dataa
/// </remarks>
namespace Computing
{

	/// <summary>
	/// Gets the current system date and time abbreviated with a 24 hour clock.
	/// </summary>
	/// <returns>The current date and time.</returns>
	/// <remarks>
	/// https://en.cppreference.com/w/c/chrono/localtime
	/// https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/localtime-s-localtime32-s-localtime64-s
	/// https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/strftime-wcsftime-strftime-l-wcsftime-l
	/// https://docs.microsoft.com/en-us/cpp/c-runtime-library/c-run-time-library-reference
	/// https://docs.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-3-c4996?view=msvc-160#unsafe-crt-library-functions
	/// LEGACY: The `localtime` function requires a warning suppresion `_CRT_SECURE_NO_WARNINGS`.
	/// NOTE: This function returns a local which is not safe.
	/// </remarks>
	const char* Time::GetDateTime()
	{
		time_t now;
		time(&now);
		struct tm* timeNow = localtime(&now);

		static char characters[30];
		std::strftime(characters, sizeof(characters), "%c", timeNow);
		return characters;
	}


	/// <summary>
	/// Gets the current system time.
	/// </summary>
	/// <returns>The current time.</returns>
	/// <remarks>
	/// LEGACY: The `localtime` function requires a warning suppresion `_CRT_SECURE_NO_WARNINGS`.
	/// NOTE: This function returns a local which is not safe.
	/// </remarks>
	const char* Time::GetTime()
	{
		time_t now;
		time(&now);
		struct tm* timeNow = localtime(&now);

		static char characters[30];
		std::strftime(characters, sizeof(characters), "%r", timeNow);
		return characters;
	}

	/// <summary>
	/// Gets the current system day.
	/// </summary>
	/// <returns>The current day.</returns>
	/// <remarks>
	/// LEGACY: The `localtime` function requires a warning suppresion `_CRT_SECURE_NO_WARNINGS`.
	/// NOTE: This function returns a local which is not safe.
	/// </remarks>
	const char* Time::GetDay()
	{
		time_t now;
		time(&now);
		struct tm* timeNow = localtime(&now);

		static char characters[30];
		std::strftime(characters, sizeof(characters), "%A", timeNow);
		return characters;
	}

	/// <summary>
	/// Gets the current system month.
	/// </summary>
	/// <returns>The current month.</returns>
	/// <remarks>
	/// LEGACY: The `localtime` function requires a warning suppresion `_CRT_SECURE_NO_WARNINGS`.
	/// NOTE: This function returns a local which is not safe.
	/// </remarks>
	const char* Time::GetMonth()
	{
		time_t now;
		time(&now);
		struct tm* timeNow = localtime(&now);

		static char characters[30];
		std::strftime(characters, sizeof(characters), "%B", timeNow);
		return characters;
	}

	/// <summary>
	/// Gets the current system year.
	/// </summary>
	/// <returns>The current year.</returns>
	/// <remarks>
	/// LEGACY: The `localtime` function requires a warning suppresion `_CRT_SECURE_NO_WARNINGS`.
	/// NOTE: This function returns a local which is not safe.
	/// </remarks>
	const char* Time::GetYear()
	{
		time_t now;
		time(&now);
		struct tm* timeNow = localtime(&now);

		static char characters[30];
		std::strftime(characters, sizeof(characters), "%G", timeNow);
		return characters;
	}


	namespace Scaleform
	{
		void RegisterUnmanagedString(GFxValue* dst, const char* name, const char* str)
		{
			GFxValue fxValue;
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
}


const char* MessageToString(F4SEMessagingInterface::Message* message)
{
	if (message->type == F4SEMessagingInterface::kMessage_PostLoad)
	{
		return "PostLoad";
	}
	else if (message->type == F4SEMessagingInterface::kMessage_PostPostLoad)
	{
		return "PostPostLoad";
	}
	else if (message->type == F4SEMessagingInterface::kMessage_PreLoadGame)
	{
		return "PreLoadGame";
	}
	else if (message->type == F4SEMessagingInterface::kMessage_PostLoadGame)
	{
		return "PostLoadGame";
	}
	else if (message->type == F4SEMessagingInterface::kMessage_PreSaveGame)
	{
		return "PreSaveGame";
	}
	else if (message->type == F4SEMessagingInterface::kMessage_PostSaveGame)
	{
		return "PostSaveGame";
	}
	else if (message->type == F4SEMessagingInterface::kMessage_DeleteGame)
	{
		return "DeleteGame";
	}
	else if (message->type == F4SEMessagingInterface::kMessage_InputLoaded)
	{
		return "InputLoaded";
	}
	else if (message->type == F4SEMessagingInterface::kMessage_NewGame)
	{
		return "NewGame";
	}
	else if (message->type == F4SEMessagingInterface::kMessage_GameLoaded)
	{
		return "GameLoaded";
	}
	else if (message->type == F4SEMessagingInterface::kMessage_GameDataReady)
	{
		return "GameDataReady";
	}
	else
	{
		return "";
	}
}
