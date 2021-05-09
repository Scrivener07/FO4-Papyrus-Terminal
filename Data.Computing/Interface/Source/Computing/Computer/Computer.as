package Computer
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import System.Diagnostics.Debug;
	import System.Diagnostics.Utility;
	import System.Display;
	import Computer.OS.DriveType;
	import PapyrusTerminal;
	import F4SE.XSE;

	public class Computer extends MovieClip
	{
		// Menu
		private var MenuRoot:PapyrusTerminal;

		// External Events
		private const COMMAND_TYPE_LoadCompleteEvent:String = "Computing:COMMAND_TYPE_LoadCompleteEvent";

		// Computer Components
		private var Drive:DriveType;


		// Initialize
		//---------------------------------------------

		public function Computer()
		{
			Debug.Prefix = "Computing";
			Debug.WriteLine("[Computer]", "(CTOR)");
			Drive = new DriveType();
			addEventListener(Event.ADDED_TO_STAGE, this.OnAddedToStage);
		}


		protected function OnAddedToStage(e:Event):void
		{
			Debug.WriteLine("[Computer]", "(OnAddedToStage)", "swf:"+stage.loaderInfo.url);

			try
			{
				MenuRoot = stage.getChildByName("root1") as PapyrusTerminal;
				XSE.API = PapyrusTerminal.F4SE;
				Utility.TraceObject(XSE.API);
			}
			catch (error:Error)
			{
				Debug.WriteLine("[Computer]", "(OnAddedToStage)", "Exception", String(error));
			}

			Drive.Setup();
		}


		// Commands
		//---------------------------------------------

		//@Papyrus
		// Displays the name of or changes the current directory.
		// Note: A null path argument string is allowed.
		public function CD(path:String):String
		{
			Debug.WriteLine("[Computer]", "(CD)", "path: '"+path+"'");

			if (path)
			{
				Drive.DirectoryChange(path);
			}

			return "Fallout 4\\" + Drive.GetDirectory();
		}


		//@Papyrus
		// Displays a list of files and subdirectories in a directory.
		public function DIR(path:String):*
		{
			// This needs a path parameter to list directories other than current.
			return Drive.DirectoryList();
		}


		//@Papyrus
		// Prints a text file.
		// TODO:
		//   A relative path which target the root directory.
		//   The problem is the scaleform loader is rooted to `Programs\`.
		//   Attempt to move up a directory results in `Programs\..\path\to\file.txt`
		//   This may need to be handled with XSE.
		// TODO:
		//   Check if file exists using the xse directory listing.
		public function TYPE(filename:String):Boolean
		{
			var directory:String = Drive.GetDirectory();
			var filepath:String = "..\\" + directory + "\\" + filename;

			Debug.WriteLine("[Computer]", "(TYPE)");
			Debug.WriteLine("+----", "filename: "+filename);
			Debug.WriteLine("+----", "directory: "+directory);
			Debug.WriteLine("+----", "filepath: "+filepath);

			var fileLoader:URLLoader = new URLLoader();
			fileLoader.addEventListener(IOErrorEvent.IO_ERROR, this.OnTypeCommand_LoadError);
			fileLoader.addEventListener(Event.COMPLETE, this.OnTypeCommand_LoadComplete);
			fileLoader.load(new URLRequest(filepath));
			return true;
		}

		private function OnTypeCommand_LoadError(e:IOErrorEvent):void
		{
			Debug.WriteLine("[Computer]", "(TYPE)", "(OnTypeCommand_LoadError)", "e:"+String(e), e.toString());
		}

		private function OnTypeCommand_LoadComplete(e:Event):void
		{
			Debug.WriteLine("[Computer]", "(TYPE)", "(OnTypeCommand_LoadComplete)", "e:"+String(e), e.toString(), "length:"+lines.length);

			var index:int = 0;
			var lines:Array = e.target.data.split(/\n/);
			for each (var line in lines)
			{
				Debug.WriteLine("[Computer]", "(TYPE)", "(OnTypeCommand_LoadComplete)", "@"+index, "line:", line);
				MenuRoot.PrintLinePapyrus(String(line));
				index += 1;
			}

			XSE.API.SendExternalEvent(COMMAND_TYPE_LoadCompleteEvent, lines);
		}


	}
}
