#pragma once

/// <summary>
/// Returns the string representation of a boolean value.
/// </summary>
/// <param name="boolean">The boolean to use.</param>
/// <returns>The string representation of the given value.</returns>
inline const char* const BoolToString(bool boolean)
{
	return boolean ? "true" : "false";
}


/// <summary>
/// Returns the boolean representation of an integer value.
/// </summary>
/// <param name="integer"></param>
/// <returns>Returns true when the integer is greater than or equal to 1.</returns>
inline bool const IntToBool(UInt32 integer)
{
	if (integer >= 1)
	{
		return true;
	}
	else
	{
		return false;
	}
}
