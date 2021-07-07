#pragma once
// ---------------------------------------------

/// <remarks>
/// https://en.cppreference.com/w/c/chrono/localtime
/// https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/localtime-s-localtime32-s-localtime64-s
/// https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/strftime-wcsftime-strftime-l-wcsftime-l
/// https://docs.microsoft.com/en-us/cpp/c-runtime-library/c-run-time-library-reference
/// https://docs.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-3-c4996?view=msvc-160#unsafe-crt-library-functions
/// </remarks>
namespace Xtensions
{
	/// <summary>
	/// Provides methods for interacting with the current system date and time.
	/// </summary>
	class Time
	{
		public:

		/// <summary>
		/// Gets the current system date and time abbreviated with a 24 hour clock.
		/// </summary>
		/// <returns>The current date and time.</returns>
		/// <remarks>
		/// LEGACY: The `localtime` function requires a warning suppresion `_CRT_SECURE_NO_WARNINGS`.
		/// NOTE: This function returns a local which is not safe.
		/// </remarks>
		static const char* GetDateTime();

		/// <summary>
		/// Gets the current system time.
		/// </summary>
		/// <returns>The current time.</returns>
		/// <remarks>
		/// LEGACY: The `localtime` function requires a warning suppresion `_CRT_SECURE_NO_WARNINGS`.
		/// NOTE: This function returns a local which is not safe.
		/// </remarks>
		static const char* GetTime();

		/// <summary>
		/// Gets the current system day.
		/// </summary>
		/// <returns>The current day.</returns>
		/// <remarks>
		/// LEGACY: The `localtime` function requires a warning suppresion `_CRT_SECURE_NO_WARNINGS`.
		/// NOTE: This function returns a local which is not safe.
		/// </remarks>
		static const char* GetDay();

		/// <summary>
		/// Gets the current system month.
		/// </summary>
		/// <returns>The current month.</returns>
		/// <remarks>
		/// LEGACY: The `localtime` function requires a warning suppresion `_CRT_SECURE_NO_WARNINGS`.
		/// NOTE: This function returns a local which is not safe.
		/// </remarks>
		static const char* GetMonth();

		/// <summary>
		/// Gets the current system year.
		/// </summary>
		/// <returns>The current year.</returns>
		/// <remarks>
		/// LEGACY: The `localtime` function requires a warning suppresion `_CRT_SECURE_NO_WARNINGS`.
		/// NOTE: This function returns a local which is not safe.
		/// </remarks>
		static const char* GetYear();

	};
}
