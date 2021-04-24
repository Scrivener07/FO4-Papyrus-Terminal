package
{
	import Computer.SystemDrive;
	import PapyrusTerminal;
	import System.Diagnostics.Debug;
	import System.Diagnostics.Utility;
	import System.Display;
	import F4SE.XSE;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.*;

	public class OS extends MovieClip
	{
		// Menu
		private var MenuRoot:PapyrusTerminal;

		// External Events
		private const COMMAND_TYPE_LoadCompleteEvent:String = "PapyrusTerminal:COMMAND_TYPE_LoadCompleteEvent";

		// OS Components
		private var Drive:SystemDrive;


		// Initialize
		//---------------------------------------------

		public function OS()
		{
			Debug.Prefix = "PapyrusTerminal";
			Debug.WriteLine("[OS]", "(CTOR)");
			Drive = new SystemDrive();
			addEventListener(Event.ADDED_TO_STAGE, this.OnAddedToStage);
		}


		protected function OnAddedToStage(e:Event):void
		{
			Debug.WriteLine("[OS]", "(OnAddedToStage)", "swf:"+stage.loaderInfo.url);

			try
			{
				MenuRoot = stage.getChildByName("root1") as PapyrusTerminal;
				XSE.API = PapyrusTerminal.F4SE;
			}
			catch (error:Error)
			{
				Debug.WriteLine("[OS]", "(OnAddedToStage)", "Exception", String(error));
			}
		}


		// Commands
		//---------------------------------------------

		public function HOME(directory:String):void
		{
			Debug.WriteLine("[OS]", "(Root)", "directory: '"+directory+"'");
			Drive.Root(directory);
		}


		//@Papyrus
		// Displays the name of or changes the current directory.
		// Note: A null path argument string is allowed.
		public function CD(path:String):String
		{
			Debug.WriteLine("[OS]", "(CD)", "path: '"+path+"'");

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
			return Drive.DirectoryList(path);
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

			Debug.WriteLine("[OS]", "(TYPE)");
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
			Debug.WriteLine("[OS]", "(TYPE)", "(OnTypeCommand_LoadError)", "e:"+String(e), e.toString());
		}

		private function OnTypeCommand_LoadComplete(e:Event):void
		{
			Debug.WriteLine("[OS]", "(TYPE)", "(OnTypeCommand_LoadComplete)", "e:"+String(e), e.toString(), "length:"+lines.length);

			var index:int = 0;
			var lines:Array = e.target.data.split(/\n/);
			for each (var line in lines)
			{
				Debug.WriteLine("[OS]", "(TYPE)", "(OnTypeCommand_LoadComplete)", "@"+index, "line:", line);
				MenuRoot.PrintLinePapyrus(String(line));
				index += 1;
			}

			XSE.API.SendExternalEvent(COMMAND_TYPE_LoadCompleteEvent, lines);
		}


		// Debug
		//---------------------------------------------

		private function TraceFileEntries(directory:String, result:Array):void
		{
			if (result.length > 0)
			{
				for each (var entry in result)
				{
					Debug.WriteLine("(CD)", "'"+directory+"'", "+ name:         ", entry.name);
					Debug.WriteLine("(CD)", "'"+directory+"'", "+ -- nativePath: ", entry.nativePath);
					Debug.WriteLine("(CD)", "'"+directory+"'", "+ -- isDirectory:", entry.isDirectory);
					Debug.WriteLine("(CD)", "'"+directory+"'", "+ -- isHidden:   ", entry.isHidden);
					Debug.WriteLine("");
				}
			}
		}


		private function Test_Kernal_WriteLog():void
		{
			Debug.WriteLine("[OS]", "(Test_Kernal_WriteLog)");
			try
			{
				XSE.API.plugins.Kernal.WriteLog("@AS3: Test_Kernal_WriteLog");
			}
			catch (error:Error)
			{
				Debug.WriteLine("[OS]", "(Test_Kernal_WriteLog)", "Exception", String(error));
			}
		}


		// TODO: WARNING, the c++ will crash the game. I need to send string as the BGS fixed static string wrapper.
		// For now Im using the Papyrus xse api.
		private function Test_Kernal_GetDirectoryCurrent():void
		{
			Debug.WriteLine("[OS]", "(Test_Kernal_GetDirectoryCurrent)");
			try
			{
				var directoryCurrent = XSE.API.plugins.Kernal.GetDirectoryCurrent();
				if (directoryCurrent)
				{
					Utility.TraceObject(directoryCurrent);
					var cd:String = String(directoryCurrent);
					Debug.WriteLine("[OS]", "(Test_Kernal_GetDirectoryCurrent)", cd);
				}
				else
				{
					Debug.WriteLine("[OS]", "(Test_Kernal_GetDirectoryCurrent)", "{F4SE.plugins.Kernal.GetDirectoryCurrent}", "Returned a null or undefined value.");
				}
			}
			catch (error:Error)
			{
				Debug.WriteLine("[OS]", "(Test_Kernal_GetDirectoryCurrent)", "Exception", String(error));
			}
		}


	}
}
