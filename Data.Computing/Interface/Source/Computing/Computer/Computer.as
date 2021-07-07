package Computer
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import System.Diagnostics.Debug;
	import System.Diagnostics.Utility;
	import F4SE.XSE;
	import PapyrusTerminal;
	import Computer.OS.DriveType;
	import Computer.OS.Kernel;

	public class Computer extends MovieClip
	{
		// Menu
		private var Terminal:PapyrusTerminal;

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
				Terminal = stage.getChildByName("root1") as PapyrusTerminal;
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
		// Supports the CLI command history.
		public function Invoke(path:*):void
		{
			Debug.WriteLine("[Computer]", "(Invoke)", String(path));
			Utility.TraceObject(path);
		}


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
			// TODO: This needs a path parameter to list directories other than current.
			return Drive.DirectoryList();
		}


		//@Papyrus
		// Prints a text file.
		public function TYPE(filename:String):Boolean
		{
			Debug.WriteLine("[Computer]", "(TYPE)", "filename: "+filename);
			var directory:String = Drive.GetDirectoryFull();
			var filepath:String = directory + "\\" + filename;

			Debug.WriteLine("[Computer]", "(TYPE)", "directory: "+directory);
			Debug.WriteLine("[Computer]", "(TYPE)", "filepath: "+filepath);

			var lines:Array = Kernel.GetFileText(filepath);
			if (lines)
			{
				var number:int = 1;
				for each (var line in lines)
				{
					Debug.WriteLine("[Computer]", "(TYPE)", "#"+number, line);
					Terminal.PrintLinePapyrus(String(line));
					number += 1;
				}
				return true;
			}
			else
			{
				Debug.WriteLine("[Computer]", "(TYPE)", "GetFileText: null or undefined");
				return false;
			}
		}


	}
}
