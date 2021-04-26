package FO4.Keyboard
{
	// Derivative of original code by registrator2000
	
   	//import Shared.AS3.COMPANIONAPP.CompanionAppMode;
   	import flash.display.Stage;
   	import flash.events.Event;
   	import flash.events.EventDispatcher;
   	import flash.events.IOErrorEvent;
   	import flash.events.KeyboardEvent;
   	import flash.net.URLLoader;
   	import flash.net.URLRequest;
   	import flash.ui.Keyboard;
   	import flash.utils.Dictionary;
   	import FO4.Keyboard.InputEvent;
   
    public class Input extends EventDispatcher
    {
		
 	  
	   	private static var _instance:FO4.Keyboard.Input;
	  
 	   	public static const BUILT_IN_KEYMAP:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?><keymap><map name=\"Forward\">w</map><map name=\"StrafeLeft\">a</map><map name=\"Back\">s</map><map name=\"StrafeRight\">d</map><map name=\"Shift-1\">!</map><map name=\"Shift-2\">@</map><map name=\"Shift-3\">#</map><map name=\"Shift-4\">$</map><map name=\"Shift-5\">%</map><map name=\"Shift-6\">^</map><map name=\"Shift-7\">&amp;</map><map name=\"Shift-8\">*</map><map name=\"Shift-9\">(</map><map name=\"Shift-0\">)</map><map name=\"Shift--\">_</map><map name=\"Shift-=\">+</map><map name=\"Shift-[\">{</map><map name=\"Shift-]\">}</map><map name=\"Shift-\\\">|</map><map name=\"Shift-;\">:</map><map name=\"Shift-\'\">&quot;</map><map name=\"Shift-,\">&lt;</map><map name=\"Shift-.\">&gt;</map><map name=\"Shift-/\">?</map><map name=\"Shift-`\">~</map></keymap>";
 	   	public static const KEYMAP_SHIFT_PREFIX:String = "Shift-";      
 	   	public static const KEYMAP_ALT_PREFIX:String = "Alt-";      
	   	public static const KEYMAP_XML_FILE:String = "PapyrusTerminal/Keymap.xml";	  
		   
	   	private var _stage:Stage;
	  
	  	// enable/disable text input
	  	private var _watchForText:Boolean = true;
	  
	  	// keymap related
	  	private var _keymapLoader:URLLoader;      
	  	private var _shiftVariantMap:Dictionary;      
	  	private var _altVariantMap:Dictionary;      
	  	private var _userEventMap:Dictionary;
	  
	  	// special keys
	  	private var _shiftKeyPressed:Boolean = false;      
	  	private var _altKeyPressed:Boolean = false;	  
	  	private var _ctrlKeyPressed:Boolean = false;
	  	private var _capsLockActive:Boolean = false;
		private var _UEstrafeLeftActive:Boolean = false;
		private var _UEstrafeRightActive:Boolean = false;
		private var _UEforwardActive:Boolean = false;
		private var _UEbackActive:Boolean = false;
	    private var _UEactivateActive:Boolean = false;
		private var _UEactivateFilterFirst:Boolean = false;
	  
	  	// filters
	  	private var _disabledKeysPressed:int = 0;      
	  	private var _filterCount:int = 0;
      
      public function Input(param1:Stage)
      {
         var mainStage:Stage = param1;
         this._shiftVariantMap = new Dictionary(true);
         this._altVariantMap = new Dictionary(true);
         this._userEventMap = new Dictionary(true);
         super();
         this._stage = mainStage;
         _instance = this;
         this.addKeyboardListeners();
         this._keymapLoader = new URLLoader();
         this._keymapLoader.addEventListener(Event.COMPLETE,this.handleKeymapLoaded,false,0,true);
         this._keymapLoader.addEventListener(IOErrorEvent.IO_ERROR,this.handleKeymapLoadFailed,false,0,true);
         try
         {
            trace("FO4.Keyboard.Input: INFO - Loading keymap..");
            this._keymapLoader.load(new URLRequest(KEYMAP_XML_FILE));
         }
         catch(e:Error)
         {
            trace("FO4.Keyboard.Input: ERROR - Exception thrown when trying to load keymap file.");
            trace("FO4.Keyboard.Input: " + e.name + " : " + e.message);
            handleKeymapLoadFailed();
         }
      }
      
      public static function get instance() : FO4.Keyboard.Input
      {
         return _instance;
      }
      
      public function get shiftKeyPressed() : Boolean
      {
         return this._shiftKeyPressed;
      }
	  
	  public function get ctrlKeyPressed() : Boolean
	  {
		  return this._ctrlKeyPressed;
	  }
	  
	  public function get capsLockActive() : Boolean
	  {
		  return this._capsLockActive;
	  }
      
      private function addKeyboardListeners() : void
      {
         if(this._stage)
         {
            this._stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown,false,int.MAX_VALUE,true);
            this._stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp,false,int.MAX_VALUE,true);
         }
      }
      
      private function removeKeyboardListeners() : void
      {
         if(this._stage)
         {
            this._stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
            this._stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
         }
      }
      
      private function handleKeymapLoaded(param1:Event) : void
      {
         trace("FO4.Keyboard.Input: INFO - Keymap loaded.");
         this.processKeymapXML(new XML(param1.target.data));
      }
      
      private function handleKeymapLoadFailed(param1:IOErrorEvent = null) : *
      {
         trace("FO4.Keyboard.Input: WARNING - No external keymap found. Loading internal keymap.");
         this.processKeymapXML(new XML(BUILT_IN_KEYMAP));
      }
      
      private function processKeymapXML(param1:XML) : void
      {
         var map:XML = null;
         var name:String = null;
         var shiftIndex:int = 0;
         var altIndex:int = 0;
         var keymapXML:XML = param1;
         try
         {
            for each(map in keymapXML.map)
            {
               name = map.@name;
               switch(name)
               {
                  case "Forward":
                  case "Back":
                  case "StrafeLeft":
                  case "StrafeRight":
                     this._userEventMap[name] = map;
               }
               shiftIndex = name.indexOf(KEYMAP_SHIFT_PREFIX);
               altIndex = name.indexOf(KEYMAP_ALT_PREFIX);
               if(shiftIndex > -1)
               {
                  this._shiftVariantMap[name.substring(shiftIndex + KEYMAP_SHIFT_PREFIX.length)] = map;
               }
               else if(altIndex > -1)
               {
                  this._altVariantMap[name.substring(altIndex + KEYMAP_ALT_PREFIX.length)] = map;
               }
            }
         }
         catch(e:Error)
         {
            trace("FO4.Keyboard.Input: ERROR - Exception thrown when trying process keymap file.");
            trace("FO4.Keyboard.Input: " + e.name + " : " + e.message);
         }
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
		 trace("FO4.Keyboard.Input: DEBUG - onKeyDown - Keycode=" + param1.keyCode + ", charCode=" + param1.charCode)
         var _loc2_:String = null;
         dispatchEvent(new InputEvent(InputEvent.KEY_DOWN,param1.keyCode,param1.charCode));
         if(this._filterCount > 0)
         {
            this._filterCount--
         }
         else
         {
			 switch(param1.keyCode)
			 {
				 case Keyboard.UP:
					if (this._UEforwardActive)
					{
						HandleForward();
						return;
					}
					break;
				 case Keyboard.DOWN:
					if (this._UEbackActive)
					{
						HandleBack();
						return;
					}
					break;
				 case Keyboard.LEFT:
					if (this._UEstrafeLeftActive)
					{
						HandleStrafeLeft();
						return;
					}
					break;
				 case Keyboard.RIGHT:
					if (this._UEstrafeRightActive)
					{
						HandleStrafeRight();
						return;
					}
					break;
				 case Keyboard.ENTER:
				 	if (this._UEactivateFilterFirst)
					{
						this._UEactivateFilterFirst = false;
						return;
					}
				    if (this._UEactivateActive)
					{
						HandleActivate();
						return;
					}
				    break;
			 }			 
			 if(this._disabledKeysPressed == 0)
			 {
				 dispatchEvent(new InputEvent(InputEvent.FILTERED_KEY_DOWN,param1.keyCode,param1.charCode)); 
			 }            
         }
         switch(param1.keyCode)
         {
            case Keyboard.SHIFT:
            	//Log.info("shift true");
               	this._shiftKeyPressed = true;
               	break;
            case Keyboard.ALTERNATE:
               	//Log.info("alt true");
               	this._altKeyPressed = true;
               	break;
			case Keyboard.CONTROL:
				this._ctrlKeyPressed = true;
				break;
            case Keyboard.LEFT:
				trace("Keyboard.LEFT");
				dispatchEvent(new InputEvent(InputEvent.MOVE_LEFT,param1.keyCode,param1.charCode));
               	break;
            case Keyboard.RIGHT:
				trace("Keyboard.RIGHT");
				dispatchEvent(new InputEvent(InputEvent.MOVE_RIGHT,param1.keyCode,param1.charCode));
               	break;
            case Keyboard.UP:
				trace("Keyboard.UP");
				dispatchEvent(new InputEvent(InputEvent.MOVE_UP,param1.keyCode,param1.charCode));
               	break;
            case Keyboard.DOWN:
               	trace("Keyboard.DOWN")
				dispatchEvent(new InputEvent(InputEvent.MOVE_DOWN,param1.keyCode,param1.charCode));
               	break;
            case Keyboard.BACKSPACE:
            case Keyboard.DELETE:
			case Keyboard.ENTER:
               break;
			case Keyboard.CAPS_LOCK:
				this._capsLockActive = !this.capsLockActive;
				break;
            default:
			   _loc2_ = String.fromCharCode(param1.charCode);
 			   if(_loc2_ != "" && param1.charCode != 0)
  			   {
 				  this.handleTextInput(_loc2_);
			   }
         }
      }
      
      private function handleTextInput(param1:String) : *
      {
         if(this._shiftKeyPressed || this._capsLockActive)
         {
            param1 = this.mapCharToShiftVariant(param1);
         }
         else if(this._altKeyPressed)
         {
            param1 = this.mapCharToAltVariant(param1);
         }
         dispatchEvent(new InputEvent(InputEvent.TEXT_INPUT, 0 ,param1.charCodeAt(0)));
      }
      
      private function mapCharToShiftVariant(param1:String) : String
      {
         if(this._shiftVariantMap[param1] != null)
         {
            return this._shiftVariantMap[param1];
         }
         switch(param1)
         {
            case "1":
               param1 = "!";
               break;
            case "/":
               param1 = "?";
               break;
            default:
               param1 = param1.toUpperCase();
         }
         return param1;
      }
      
      private function mapCharToAltVariant(param1:String) : String
      {
         if(this._altVariantMap[param1] != null)
         {
            return this._altVariantMap[param1];
         }
         return param1;
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
		 trace("FO4.Keyboard.Input: DEBUG - onKeyUp - Keycode=" + param1.keyCode + ", charCode=" + param1.charCode)
         switch(param1.keyCode)
         {
            case Keyboard.SHIFT:
               //Log.info("shift false");
               this._shiftKeyPressed = false;
               break;
            case Keyboard.ALTERNATE:
               this._altKeyPressed = false;
               break;
			case Keyboard.CONTROL:
				this._ctrlKeyPressed = false;
				break;
            case Keyboard.LEFT:
            case Keyboard.A:
            case Keyboard.RIGHT:
            case Keyboard.D:
            case Keyboard.UP:
            case Keyboard.W:
            case Keyboard.DOWN:
            case Keyboard.S:
               dispatchEvent(new InputEvent(InputEvent.STOP_MOVE,param1.keyCode,param1.charCode));
               break;
            case Keyboard.SPACE:
            case Keyboard.ENTER:
               dispatchEvent(new InputEvent(InputEvent.ACCEPT));
         }
      }
      
      public function dispose() : void
      {
         _instance = null;
         this.removeKeyboardListeners();
      }
      	  
      public function ProcessUserEvent(param1:String, param2:Boolean) : Boolean
      {
         trace("FO4.Keyboard.Input: DEBUG - PROCESS USER EVENT: " + param1 + " state: " + param2);
         if(param2)
         {
            dispatchEvent(new InputEvent(InputEvent.ACTION_DOWN,0,0,param1));
         }
         var _loc3_:Boolean = true;
         switch(param1)
         {
            case "DISABLED":
			   // the E / Activate key raises a DISABLED event for my install. not sure if that's universal, but it seems to work fine for other people.
			   this._UEactivateActive = param2			   
               if(param2)               
			   {
				   // hack to prevent from double counting the initial keystroke
				   this._UEactivateFilterFirst = true;
                  
				   ++this._disabledKeysPressed;
               }
               else
               {
				   // clear initial keystroke filter if key gets released
				  this._UEactivateFilterFirst = false;
                  
				  --this._disabledKeysPressed;
				  if (this._disabledKeysPressed < 0) { this._disabledKeysPressed = 0; }
               }
               return true;
            case "PrimaryAttack":
               if(param2)
               {
                  //Log.info("InputManager: Click.");
                  dispatchEvent(new InputEvent(InputEvent.MOUSE_DOWN));
               }
               else
               {
                  dispatchEvent(new InputEvent(InputEvent.MOUSE_UP));
               }
               return true;
            case "Activate":
               if(param2)
               {
				  this._filterCount++
               }
               return true;
            case "StrafeLeft":
               this._UEstrafeLeftActive = param2;
			   if(param2 && this._watchForText)
               {
                  //this._filterOn = true;
				  this._filterCount++				
				  HandleStrafeLeft();
               }
               return true;
            case "StrafeRight":
               this._UEstrafeRightActive = param2;
			   if(param2 && this._watchForText)
               {
				  this._filterCount++				  
				  HandleStrafeRight();
               }
               return true;
            case "Forward":
				this._UEforwardActive = param2;
               if(param2 && this._watchForText)
               {
				  this._filterCount++
				  HandleForward();
               }
               return true;
            case "Back":
				this._UEbackActive = param2;
               if(param2 && this._watchForText)
               {
				  this._filterCount++
				  HandleBack();
               }
               return true;
            case "Accept":
            case "Jump":
               if(param2)
               {
                  dispatchEvent(new InputEvent(InputEvent.ACCEPT));
               }
               return true;
            case "Left":
               if(param2)
               {
                  dispatchEvent(new InputEvent(InputEvent.MOVE_LEFT));
               }
               else
               {
                  dispatchEvent(new InputEvent(InputEvent.STOP_MOVE));
               }
               return true;
            case "Right":
               if(param2)
               {
                  dispatchEvent(new InputEvent(InputEvent.MOVE_RIGHT));
               }
               else
               {
                  dispatchEvent(new InputEvent(InputEvent.STOP_MOVE));
               }
               return true;
            case "Up":
			   if(param2)
               {
                  dispatchEvent(new InputEvent(InputEvent.MOVE_UP));
               }
               else
               {
                  dispatchEvent(new InputEvent(InputEvent.STOP_MOVE));
               }
               return true;
            case "Down":
               if(param2)
               {
                  dispatchEvent(new InputEvent(InputEvent.MOVE_DOWN));
               }
               else
               {
                  dispatchEvent(new InputEvent(InputEvent.STOP_MOVE));
               }
               return true;
            default:
               trace("Got unhandled UserEvent: " + param1);
			   _loc3_ = false;
         }
         return _loc3_;
      }
      
	  private function HandleStrafeRight()
	  {
      	if(this._userEventMap["StrafeRight"] != null)
        {
        	this.handleTextInput(this._userEventMap["StrafeRight"]);
        }
        else
        {
        	this.handleTextInput("d");
        }		  		  
	  }

	  private function HandleStrafeLeft()
	  {
      	if(this._userEventMap["StrafeLeft"] != null)
        {
        	this.handleTextInput(this._userEventMap["StrafeLeft"]);
        }
        else
        {
        	this.handleTextInput("a");
        }		  		  
	  }
	  
	  private function HandleForward()
	  {
		if(this._userEventMap["Forward"] != null)
        {
          	this.handleTextInput(this._userEventMap["Forward"]);
		}
        else
        {
          	this.handleTextInput("w");
		}
	  }
	  
	  private function HandleBack()
	  {
		if(this._userEventMap["Back"] != null)
        {
        	this.handleTextInput(this._userEventMap["Back"]);
		}
        else
        {
        	this.handleTextInput("s");
        }
	  }
	  
	  private function HandleActivate()
	  {
		  if (this._userEventMap["Activate"] != null)
		  {
			  this.handleTextInput(this._userEventMap["Activate"]);
		  }
		  else
		  {
			  this.handleTextInput("e");
		  }
	  }


	  
      public function ConfirmQuit() : void
      {
         trace("FO4.Keyboard.Input: DEBUG - ConfirmQuit() called.");
         dispatchEvent(new InputEvent(InputEvent.CANCEL));
      }
   }
}
