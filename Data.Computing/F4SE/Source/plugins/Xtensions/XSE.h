#pragma once
#include "XSE.h"
#include "f4se/PluginAPI.h"
//---------------------------------------------

namespace XSE_MessagingInterface
{
	const char* ToString(UInt8 messageType)
	{
		if (messageType == F4SEMessagingInterface::kMessage_PostLoad)
		{
			return "PostLoad";
		}
		else if (messageType == F4SEMessagingInterface::kMessage_PostPostLoad)
		{
			return "PostPostLoad";
		}
		else if (messageType == F4SEMessagingInterface::kMessage_PreLoadGame)
		{
			return "PreLoadGame";
		}
		else if (messageType == F4SEMessagingInterface::kMessage_PostLoadGame)
		{
			return "PostLoadGame";
		}
		else if (messageType == F4SEMessagingInterface::kMessage_PreSaveGame)
		{
			return "PreSaveGame";
		}
		else if (messageType == F4SEMessagingInterface::kMessage_PostSaveGame)
		{
			return "PostSaveGame";
		}
		else if (messageType == F4SEMessagingInterface::kMessage_DeleteGame)
		{
			return "DeleteGame";
		}
		else if (messageType == F4SEMessagingInterface::kMessage_InputLoaded)
		{
			return "InputLoaded";
		}
		else if (messageType == F4SEMessagingInterface::kMessage_NewGame)
		{
			return "NewGame";
		}
		else if (messageType == F4SEMessagingInterface::kMessage_GameLoaded)
		{
			return "GameLoaded";
		}
		else if (messageType == F4SEMessagingInterface::kMessage_GameDataReady)
		{
			return "GameDataReady";
		}
		else
		{
			return "";
		}
	}
}
