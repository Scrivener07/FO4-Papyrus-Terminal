package Computer.OS
{
	import System.Diagnostics.Debug;
	import Computer.OS.Kernel;

	/**
	 * Represents a device for storage such as RAM, Tape, Disk, etc.
	*/
	public class DriveType
	{
		/** Navigation */
		//---------------------------------------------
		public static const CD:String = ".";       // current directory
		public static const CD_UP:String = "..";   // go up a directory
		public static const CD_ROOT:String = "\\"; // drive root

		// Directory
		//---------------------------------------------

		/** The full path string to the root game directory.
		 * ex: `E:\Bethesda\steamapps\common\Fallout 4`
		 */
		private var RootPath:String;

		/** The root directory as an array of folder names. */
		private var RootArray:Vector.<String>;

		/** The current directory as an array of folder names. */
		private var Folders:Vector.<String>;


		// Initialize
		//---------------------------------------------

		public function DriveType()
		{
			Debug.WriteLine("[DRIVE]", "(CTOR)");
			RootPath = null;
			RootArray = new Vector.<String>();
			Folders = new Vector.<String>();
			Folders.push("Data");
		}


		// Paths
		//---------------------------------------------

		/** Setup the root drive path.*/
		public function Setup():void
		{
			RootPath = Kernel.GetDirectoryGame();
			Debug.WriteLine("[DRIVE]", "(Setup)", "{RootPath: '"+RootPath+"'}");
		}


		/** The current root directory as a string.*/
		public function GetDirectory():String
		{
			var value:String = Folders.join("\\");
			Debug.WriteLine("[DRIVE]", "(GetDirectory)", "'"+value+"'");
			return value;
		}


		/** The current full directory as a string.*/
		public function GetDirectoryFull():String
		{
			var value:String = RootPath + "\\" + Folders.join("\\");
			Debug.WriteLine("[DRIVE]", "(GetDirectoryFull)", "{value: '"+value+"'}");
			return value;
		}


		// Directory Change
		//---------------------------------------------

		public function DirectoryChange(path:String):void
		{
			if (path)
			{
				Debug.WriteLine("[DRIVE]", "(DirectoryChange)", "path: '"+path+"'");

				if (path == DriveType.CD)
				{
					// does not really change the current directory
					return;
				}

				// Split path string into folder array.
				var folders:Array = path.split("\\");
				var index:int = 0;

				// use a reverse `for` loop to check for `..` first
				var length:int = folders.length;
				for (index = 0; index < length; index++)
				{
					var fldr:String = folders[index];
					Debug.WriteLine("[DRIVE]", "{PATH}", "    @"+index+" | "+(index + 1)+" of "+folders.length, "{path: '"+path+"'}", "{fldr: '"+fldr+"'}");
					if (fldr == DriveType.CD_UP)
					{
						Folders.pop();
						Debug.WriteLine("[DRIVE]", "{PATH:UP}", "popped!");
					}
				}

				// Populate
				index = 0;
				for each (var folder in folders)
				{
					Debug.WriteLine("[DRIVE]", "(DirectoryChange)", "    @"+index+" | "+(index + 1)+" of "+folders.length, "{path: '"+path+"'}", "{folder: '"+folder+"'}");

					if (folder == DriveType.CD)
					{
						// current directory
						break;
					}

					if (folder == DriveType.CD_UP) {}
					else if (folder == DriveType.CD_ROOT)
					{
						if (Folders.length == 1)
						{
							Debug.WriteLine("[DRIVE]", "(DirectoryChange:PATH)", "Breaking for last directory.");
							break;
						}
						else
						{
							// Remove folder..
							Folders.pop();
						}
					}
					else
					{
						// Add folder
						Folders.push(folder);
					}

					index += 1;
				}
			}
			else
			{
				Debug.WriteLine("[DRIVE]", "(DirectoryChange)", "The argument 'path' cannot be null.");
			}
		}


		// List
		//---------------------------------------------


		// TODO: verify return type
		public function DirectoryList():*
		{
			try
			{
				var directory:String = GetDirectoryFull();
				var listing:Array = Kernel.GetListing(directory, "*", false);
				Debug.WriteLine("[DRIVE]", "(DirectoryList)", "{Directory: '"+directory+"'}", "{listing.length: ", listing.length+"}");

				var values:Array = new Array(listing.length);
				if (listing.length > 0)
				{
					var index:int = 0;
					while(index < listing.length)
					{
						var isDirectory:String = "  ";
						if (listing[index].isDirectory)
						{
							isDirectory = "<DIR>";
						}
						else
						{
							isDirectory = "     ";
						}

						listing[index].name = listing[index].name.replace(directory, ""); // shorten path


						values[index] = isDirectory + "  "+listing[index].name;
						index += 1;
					}
				}
				return values;
			}
			catch (error:Error)
			{
				Debug.WriteLine("[DRIVE]", "(DirectoryList)", "Exception", String(error));
			}

			return null;
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
