#pragma once
#include "f4se/GameData.h"
#include "f4se/GameForms.h"
#include "f4se/GameReferences.h"
//---------------------------------------------

class ModInfoEx
{
	public:
	static void Dump(ModInfo* modInfo);
};


class TESFormEx
{
	public:
	static void Dump(TESForm* form);
};


class TESObjectREFREx
{
	public:
	static void Dump(TESObjectREFR* reference);
};


class ActorEx
{
	public:
	static void Dump(Actor* actor);
};


class FormTypeEx
{
	public:
	static const char* ToString(UInt8 type);
};
