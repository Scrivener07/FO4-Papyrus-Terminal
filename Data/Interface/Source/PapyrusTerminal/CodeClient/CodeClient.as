package
{
	import PapyrusTerminal;
	import System.Diagnostics.Debug;
	import System.Diagnostics.Utility;
	import System.Display;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	// https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfilea
	// https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findnextfilea
	// https://docs.microsoft.com/en-us/cpp/standard-library/directory-iterator-class
	// https://docs.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-win32_find_dataa
	// http://www.cs.rpi.edu/courses/fall01/os/WIN32_FIND_DATA.html <---

	public class CodeClient extends MovieClip
	{
		// Menu
		private var MenuRoot:PapyrusTerminal;

		// Directories
		private var CurrentDirectory:Vector.<String>;
		private function get CurrentPath():String
		{
			return CurrentDirectory.join("\\");
		}

		private function get CurrentPathNative():String
		{
			var collection:Vector.<String> = CurrentDirectory.concat();
			collection.shift();
			var value:String = collection.join("\\");
			Debug.WriteLine("[CMD]", "(CurrentPathNative)", "'"+value+"'");
			return value;
		}

		// External Events
		private const TYPE_LoadCompleteEvent:String = "PapyrusTerminal:Example03:TYPE_LoadCompleteEvent";


		// Initialize
		//---------------------------------------------

		public function CodeClient()
		{
			Debug.Prefix = "PapyrusTerminal";
			Debug.WriteLine("[CMD]", "(CTOR)");
			CurrentDirectory = new Vector.<String>();
			addEventListener(Event.ADDED_TO_STAGE, this.OnAddedToStage);
		}


		protected function OnAddedToStage(e:Event):void
		{
			Debug.WriteLine("[CMD]", "(OnAddedToStage)", "swf:"+stage.loaderInfo.url);
			CurrentDirectory.push("Fallout 4");

			try
			{
				MenuRoot = stage.getChildByName("root1") as PapyrusTerminal;
				// Utility.TraceDisplayList(stage); // its huge
				Utility.TraceObject(PapyrusTerminal.F4SE);
				Utility.TraceObject(PapyrusTerminal.F4SE.plugins.Kernal);

				PapyrusTerminal.F4SE.plugins.Kernal.WriteLog("Hello world from AS3!");
			}
			catch (error:Error)
			{
				Debug.WriteLine("[CMD]", "(OnAddedToStage)", "Exception", String(error));
			}
		}


		// Commands
		//---------------------------------------------

		//@Papyrus
		// Displays the name of or changes the current directory.
		public function CD(path:String):String
		{
			Debug.WriteLine("[CMD]", "(CD)", "path:"+path);

			// Parameters
			if (!path)
			{
				path = "."
			}

			// Path
			var elements:Array = path.split("\\");

			// Populate
			var index:int = 0;
			for each (var element in elements)
			{
				Debug.WriteLine("[CMD]", "(CD)", "    @"+index+"|"+elements.length, "'"+path+"':", "'"+element+"'");

				if (element == ".")
				{
					// current
					break;
				}
				else if (element == "..")
				{
					if (CurrentDirectory.length == 1)
					{
						Debug.WriteLine("[CMD]", "(CD:PATH)", "Breaking for last directory.");
						break;
					}
					else
					{
						CurrentDirectory.pop();
					}
				}
				else
				{
					CurrentDirectory.push(element);
				}

				index += 1;
			}

			return CurrentPath;
		}


		//@Papyrus
		// Displays a list of files and subdirectories in a directory.
		public function DIR(directory:String):*
		{
			try
			{
				var result:Array = PapyrusTerminal.F4SE.GetDirectoryListing(CurrentPathNative, "*", false);
				Debug.WriteLine("[CMD]", "(DIR)", "CurrentPath:"+CurrentPath, "result.length:", result.length);

				var values:Array = new Array(result.length);
				if(result.length > 0)
				{
					var index:int = 0;
					while(index < result.length)
					{
						var isDirectory:String = "  ";
						if(result[index].isDirectory)
						{
							isDirectory = "<DIR>";
						}

						values[index] = result[index].lastModified + "  "+isDirectory + "  "+result[index].name;
						index += 1;
					}
				}
				return values;
			}
			catch (error:Error)
			{
				Debug.WriteLine("[CMD]", "(DIR)", "Exception", String(error));
			}

			return null;
		}


		//@Papyrus
		// Prints a text file.
		public function TYPE(filename:String):Boolean
		{
			var fullpath:String = CurrentPathNative + "\\" + filename;
			Debug.WriteLine("[CMD]", "(TYPE)", "filename: "+filename, "FULL: "+fullpath);

			var fileLoader:URLLoader = new URLLoader();
			fileLoader.addEventListener(Event.COMPLETE, this.TYPE_OnLoaded);
			fileLoader.load(new URLRequest(CurrentPathNative));
			return true;
		}


		private function TYPE_OnLoaded(e:Event):void
		{
			Debug.WriteLine("[CMD]", "(TYPE:OnLoaded)", "length:"+lines.length);

			var index:int = 0;
			var lines:Array = e.target.data.split(/\n/);
			for each (var line in lines)
			{
				Debug.WriteLine("[CMD]", "(TYPE:OnLoaded)", "@"+index, "line:", line);
				MenuRoot.PrintLinePapyrus(String(line));
				index += 1;
			}


			PapyrusTerminal.F4SE.SendExternalEvent(TYPE_LoadCompleteEvent, lines);
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


	}
}
