#include "SystemTime.h"
#include <ctime>
// ---------------------------------------------

namespace Xtensions
{

	const char* Time::GetDateTime()
	{
		time_t now;
		time(&now);
		struct tm* timeNow = localtime(&now);

		static char characters[30];
		std::strftime(characters, sizeof(characters), "%c", timeNow);
		return characters;
	}


	const char* Time::GetTime()
	{
		time_t now;
		time(&now);
		struct tm* timeNow = localtime(&now);

		static char characters[30];
		std::strftime(characters, sizeof(characters), "%r", timeNow);
		return characters;
	}


	const char* Time::GetDay()
	{
		time_t now;
		time(&now);
		struct tm* timeNow = localtime(&now);

		static char characters[30];
		std::strftime(characters, sizeof(characters), "%A", timeNow);
		return characters;
	}


	const char* Time::GetMonth()
	{
		time_t now;
		time(&now);
		struct tm* timeNow = localtime(&now);

		static char characters[30];
		std::strftime(characters, sizeof(characters), "%B", timeNow);
		return characters;
	}


	const char* Time::GetYear()
	{
		time_t now;
		time(&now);
		struct tm* timeNow = localtime(&now);

		static char characters[30];
		std::strftime(characters, sizeof(characters), "%G", timeNow);
		return characters;
	}


}
