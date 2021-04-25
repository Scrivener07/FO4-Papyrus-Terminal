package Computer
{
	import System.Diagnostics.Debug;
	import System.Diagnostics.Utility;
	import F4SE.XSE;

	// Represents a device for storage such as RAM, Tape, Disk, etc.
	public class SystemDrive
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
		 *
		 * TODO: Possibly, the path seperators must be delimited, or xse functions will cause a crash.
		 * TODO: Possibly store this root path as a folder array.
		 *       This it can be joined in the correct format.
		 */
		private var RootPath:String;

		/** The root directory as an array of folder names. */
		private var RootArray:Vector.<String>;

		/** The current directory as an array of folder names. */
		private var Folders:Vector.<String>;


		// Initialize
		//---------------------------------------------

		public function SystemDrive()
		{
			Debug.WriteLine("[DRIVE]", "(CTOR)");
			RootPath = null;
			RootArray = new Vector.<String>();
			Folders = new Vector.<String>();
			Folders.push("Data");
		}


		// Paths
		//---------------------------------------------

		/**
		 * Set the full path to the root game directory.
		 * ex: `E:\Bethesda\steamapps\common\Fallout 4`
		*/
		public function Root(directory:String):void
		{
			RootPath = directory;
			Debug.WriteLine("[DRIVE]", "(Root)", "{directory: `"+directory+"`}", "{RootPath: '"+RootPath+"'}");
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


		/** This path is relative from this swf, to the current directory. */
		public function GetDirectoryAS3():String
		{
			var folders:Vector.<String> = Folders.concat(); // copy vector
			folders.shift();
			var value:String = folders.join("\\");
			Debug.WriteLine("[DRIVE]", "(GetDirectoryAS3)", "{value: '"+value+"'}");
			return value;
		}


		// Change
		//---------------------------------------------

		public function DirectoryChange(path:String):void
		{
			if (path)
			{
				Debug.WriteLine("[DRIVE]", "(DirectoryChange)", "path: '"+path+"'");

				if (path == SystemDrive.CD)
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
					if (fldr == SystemDrive.CD_UP)
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

					if (folder == SystemDrive.CD)
					{
						// current directory
						break;
					}


					if (folder == SystemDrive.CD_UP) {}
					else if (folder == SystemDrive.CD_ROOT)
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

		public function DirectoryList(path:String):*
		{
			try
			{
				var directory:String = GetDirectoryFull();

				var listing:Array = XSE.API.GetDirectoryListing(directory, "*", false);
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


	}
}
