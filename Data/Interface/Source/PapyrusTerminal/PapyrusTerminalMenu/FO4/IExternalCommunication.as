package FO4
{
   public interface IExternalCommunication
   {
	  // special keyboard- and other events sent by game
      function ProcessUserEvent(param1:String, param2:Boolean) : Boolean;
      
	  // startup iniializer called by game
      function InitProgram() : void;
      
	  // pause function called by game
      function Pause(param1:Boolean) : void;
	  
	  // function called when player quits holotape with TAB
	  function ConfirmQuit(forceQuit:Boolean = false) : void
   }
}
