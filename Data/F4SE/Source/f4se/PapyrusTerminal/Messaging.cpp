#include "Messaging.h"
#include "f4se/PluginAPI.h"
#include "F4SE/GameMenus.h"

// Messaging
// ---------------------------------------------

/// <summary>
/// The MenuOpenCloseEvent handler.
/// </summary>
class MenuOpenCloseHandler : public BSTEventSink<MenuOpenCloseEvent>
{
	public:
		virtual ~MenuOpenCloseHandler() { };

		/// <summary>
		/// The implementation for the MenuOpenCloseEvent handler.
		/// </summary>
		/// <param name="e">The MenuOpenCloseEvent to use.</param>
		/// <param name="dispatcher">The dispatcher to use.</param>
		/// <returns>The event result.</returns>
		virtual	EventResult	ReceiveEvent(MenuOpenCloseEvent* e, void* dispatcher) override
		{
			_MESSAGE("Messaging::MenuOpenCloseHandler.ReceiveEvent(): menuName: '%s', isOpen: `%s`", std::string(e->menuName), e->isOpen ? "true" : "false");

			static BSFixedString sTerminalHolotapeMenu("TerminalHolotapeMenu");
			if (e->menuName == sTerminalHolotapeMenu)
			{
				if (e->isOpen)
				{
					_MESSAGE("Messaging::MenuOpenCloseHandler.ReceiveEvent(): Opening the '%s' menu.", std::string(e->menuName));

					GFxValue dispatchEvent;
					GFxValue eventArgs[3];
					IMenu* pHolotapeMenu = (*g_ui)->GetMenu(sTerminalHolotapeMenu);
					auto* movieRoot = pHolotapeMenu->movie->movieRoot;
					movieRoot->CreateString(&eventArgs[0], "OnPapyrusTerminal"); // @as3
					eventArgs[1].SetBool(true);
					eventArgs[2].SetBool(false);
					movieRoot->CreateObject(&dispatchEvent, "flash.events.Event", eventArgs, 3);
					movieRoot->Invoke("root.dispatchEvent", nullptr, &dispatchEvent, 1);
				}
				else
				{
					_MESSAGE("Messaging::MenuOpenCloseHandler.ReceiveEvent(): Closing the '%s' menu.", std::string(e->menuName));
				}
			}
			else
			{
				_WARNING("Messaging::MenuOpenCloseHandler.ReceiveEvent(): The menu of '%s' was unhandled.", std::string(e->menuName));
			}
			return kEvent_Continue;
		};


		/// <summary>
		/// Register the event handler type.
		/// </summary>
		static void Register()
		{
			static auto* pHandler = new MenuOpenCloseHandler();
			(*g_ui)->menuOpenCloseEventSource.AddEventSink(pHandler);
		}
};


// XSE
// ---------------------------------------------

void Messaging::OnMessage(F4SEMessagingInterface::Message* message)
{
	if (message->type == F4SEMessagingInterface::kMessage_GameLoaded)
	{
		_MESSAGE("Messaging::OnMessage(): kMessage_GameLoaded");
		MenuOpenCloseHandler::Register();
	}
	else
	{
		_WARNING("Messaging::OnMessage(): The message of type %i was unhandled.", message->type);
	}
}
