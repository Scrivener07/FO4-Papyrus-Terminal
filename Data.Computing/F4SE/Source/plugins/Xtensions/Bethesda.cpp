#include "Bethesda.h"
#include "f4se/GameData.h"
#include "f4se/GameForms.h"
#include "f4se/GameReferences.h"
#include <plugins/Xtensions/Common.h>
//---------------------------------------------

void ModInfoEx::Dump(ModInfo* modInfo)
{
	if (modInfo)
	{
		_MESSAGE("ModInfo");
		_MESSAGE("->name: %s", modInfo->name);
		_MESSAGE("->author: %s", modInfo->author.Get() + '\0');
		_MESSAGE("->description: %s", modInfo->description.Get() + '\0');
		_MESSAGE("->directory: %s", modInfo->directory);
		_MESSAGE("->file: %s", modInfo->file);
		_MESSAGE("->recordFlags: %i", modInfo->recordFlags);
		_MESSAGE("->flags: %i", modInfo->flags);
		_MESSAGE("->flags:None %s", BoolToString(modInfo->flags & modInfo->kRecordFlags_None));
		_MESSAGE("->flags:ESM %s", BoolToString(modInfo->flags & modInfo->kRecordFlags_ESM));
		_MESSAGE("->flags:ESL %s", BoolToString(modInfo->flags & modInfo->kRecordFlags_ESL));
		_MESSAGE("->flags:Active %s", BoolToString(modInfo->flags & modInfo->kRecordFlags_Active));
		_MESSAGE("->flags:Localised %s", BoolToString(modInfo->flags & modInfo->kRecordFlags_Localized));
		_MESSAGE("->IsActive: %s", BoolToString(modInfo->IsActive()));
		_MESSAGE("->IsLight: %s", BoolToString(modInfo->IsLight()));
		_MESSAGE("->PartialIndex: %i", modInfo->GetPartialIndex());
		_MESSAGE("->lightIndex: %i", modInfo->lightIndex);
		_MESSAGE("->modIndex: %i", modInfo->modIndex);
		_MESSAGE("->numRefMods: %i", modInfo->numRefMods);
	}
	else
	{
		_MESSAGE("The mod info is null.");
	}
}


void TESFormEx::Dump(TESForm* form)
{
	if (form)
	{
		_MESSAGE("TESForm");
		_MESSAGE("->FullName: %s", form->GetFullName());
		_MESSAGE("->EditorID: %s", form->GetEditorID());
		_MESSAGE("->FormType: %s", FormTypeEx::ToString(form->GetFormType()));
		_MESSAGE("->formID: %x", form->formID);
		//ModInfoEx::Dump(form->GetLastModifiedMod());
	}
	else
	{
		_MESSAGE("The form is null.");
	}
}


void TESObjectREFREx::Dump(TESObjectREFR* reference)
{
	if (reference)
	{
		_MESSAGE("TESObjectREFR");
		_MESSAGE("->ReferenceName: %s", reference->_GetReferenceName_GetPtr());
		_MESSAGE("->CarryWeight: %f", reference->_GetCarryWeight_GetPtr());
		_MESSAGE("->Inventory.Weight: %f", reference->_GetInventoryWeight_GetPtr());
		if (reference->inventoryList)
		{
			_MESSAGE("->Inventory.Count: %i", reference->inventoryList->items.count);
		}

		TESFormEx::Dump(reference);
		TESFormEx::Dump(reference->baseForm);
	}
	else
	{
		_MESSAGE("The reference is null.");
	}
}

void ActorEx::Dump(Actor* actor)
{
	if (actor)
	{
		_MESSAGE("Actor");
		_MESSAGE("->IsWeaponDrawn: %s", BoolToString(actor->actorState.IsWeaponDrawn()));
		TESObjectREFREx::Dump(actor);
	}
	else
	{
		_MESSAGE("The actor is null.");
	}
}



const char* FormTypeEx::ToString(UInt8 type)
{
	if (type == FormType::kFormType_NONE)
	{ // nothing
		return "None";
	}
	else if (type == FormType::kFormType_REFR)
	{ // REFR	64	TESObjectREFR / Actor
		return "REFR";
	}
	else if (type == FormType::kFormType_ACHR)
	{ // ACHR	65	Character / PlayerCharacter
		return "ACHR";
	}
	else if (type == FormType::kFormType_NOTE)
	{ // NOTE	50	BGSNote
		return "NOTE";
	}
	else if (type == FormType::kFormType_TERM)
	{ // TERM	55	BGSTerminal
		return "TERM";
	}
	else
	{
		return std::to_string(type).c_str();
	}
}
