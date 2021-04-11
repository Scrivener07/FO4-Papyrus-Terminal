package FO4.Keyboard
{
   import flash.events.Event;
   
   public class InputEvent extends Event
   {
      public static const KEY_DOWN:String = "KEY_DOWN";
      public static const TEXT_INPUT:String = "TEXT_INPUT";
	  public static const CRTL_INPUT:String = "CTRL_INPUT";
      public static const FILTERED_KEY_DOWN:String = "FILTERED_KEY_DOWN";
      public static const ACTION_DOWN:String = "ACTION_DOWN";
      public static const MOUSE_DOWN:String = "MOUSE_DOWN";
      public static const MOUSE_UP:String = "MOUSE_UP";
      public static const ACCEPT:String = "Accept";
      public static const CANCEL:String = "Cancel";
      public static const MOVE_LEFT:String = "MoveLeft";
      public static const MOVE_RIGHT:String = "MoveRight";
      public static const MOVE_UP:String = "MoveUp";
      public static const MOVE_DOWN:String = "MoveDown";
      public static const STOP_MOVE:String = "StopMove";
      public static const PAUSE:String = "Pause";
      
      public var keyCode:uint;
      public var charCode:uint;
      public var action:String;
      
      public function InputEvent(param1:String, param2:uint = 0, param3:uint = 0, param4:String = null)
      {
         super(param1,false,false);
         this.keyCode = param2;
         this.charCode = param3;
         this.action = param4;
      }
   }
}
