package Computer.OS
{
	import System.Diagnostics.Debug;
	import F4SE.XSE;

	public class Kernel
	{

		public static function GetDirectoryGame():String
		{
			try
			{
				return XSE.API.plugins.Computer.GetDirectoryGame();
			}
			catch (error:Error)
			{
				Debug.WriteLine("[Computer.OS.Kernel]", "(GetDirectoryGame)", "Exception", String(error));
			}

			return null;
		}


		public static function GetListing(directory:String, filter:String, recursive:Boolean):*
		{
			try
			{
				return XSE.API.plugins.Computer.GetDirectoryListing(directory, filter, recursive);
			}
			catch (error:Error)
			{
				Debug.WriteLine("[Computer.OS.Kernel]", "(GetListing)", "Exception", String(error));
			}
		}


		public static function GetFileText(filepath:String):Array
		{
			try
			{
				return XSE.API.plugins.Computer.GetFileText(filepath);
			}
			catch (error:Error)
			{
				Debug.WriteLine("[Computer.OS.Kernel]", "(GetFileText)", "Exception", String(error));
			}

			return null;
		}


	}
}