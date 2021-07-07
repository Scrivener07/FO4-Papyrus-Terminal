#include "INV.h"
#include "f4se/GameTypes.h"
#include "f4se/GameForms.h"
#include "f4se/GameReferences.h"
#include "plugins/Xtensions/Common.h"
//---------------------------------------------

namespace SNE
{

	void SNE::INV()
	{
		BGSInventoryList* inventory = (*g_player)->inventoryList;
		if (inventory)
		{
			_MESSAGE("PLAYER::INVENTORY");
			_MESSAGE("-> count: %i", inventory->items.count);
			_MESSAGE("-> inventoryWeight: %f", inventory->inventoryWeight);

			_MESSAGE("Looking for NOTE items...");
			// thread safe, lock inventory changes
			inventory->inventoryLock.LockForRead();
			for (size_t index = 0; index < inventory->items.count; index++)
			{
				BGSInventoryItem item = inventory->items[index];

				TESForm* form = item.form;
				BGSInventoryItem::Stack* stack = item.stack;

				if (form)
				{
					if (form->formType == kFormType_NOTE)
					{
						_MESSAGE("\n");
						_MESSAGE("NOTE");
						item.Dump();

						// Form
						UInt32 formID = form->formID;
						UInt8 formType = form->GetFormType();
						UInt32 flags = form->flags;
						const char* editorID = form->GetEditorID();
						const char* fullname = form->GetFullName();
						bool playerKnows = form->GetPlayerKnows();
						auto classname = GetObjectClassName(form);

						_MESSAGE("-> fullname: %s", fullname);
						_MESSAGE("-> classname: %s", classname);
						_MESSAGE("-> formType: %i", formType);
						_MESSAGE("-> formID: %x", formID);
						_MESSAGE("-> editorID: %s", editorID);
						_MESSAGE("-> flags: %i", flags);
						_MESSAGE("-> playerKnows: %s", BoolToString(playerKnows));

						if (stack)
						{
							_MESSAGE("STACK of %i notes.", stack->count);
							stack->Visit([&](BGSInventoryItem::Stack* element)
								{
									if (element)
									{
										bool isEquipped = element->flags & element->kFlagEquipped;
										_MESSAGE("ELEMENT");
										_MESSAGE("-> isEquipped: %s", BoolToString(isEquipped));
										_MESSAGE("-> count: %i", element->count);
										_MESSAGE("-> m_refCount: %i", element->m_refCount);
										_MESSAGE("-> flags: %i", element->flags);
										_MESSAGE("-> extraData: %s", BoolToString(element->extraData));
									}
									else
									{
										_MESSAGE("The stack element here is null.");
									}
									return true;
								});
						}
						else
						{
							_MESSAGE("No item stack.");
						}
					}
					else
					{
						// ignore, wrong type
					}
				}
				else
				{
					// ignore, no form
				}
			}
			inventory->inventoryLock.UnlockRead();
		}
		else
		{
			_MESSAGE("The player inventory is unavailable.");
		}
	}


}