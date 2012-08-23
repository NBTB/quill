package scripts
{
	public class FileFinder
	{
		private static var directories:Array = null;
		
		public static const INTERFACE:int = 0;
		public static const GAME_INFO:int = 1;
		public static const OOI_IMAGES:int = 2;
		public static const OOI_INFO:int = 3;
		public static const END_GOAL_IMAGES:int = 4;
		
		public static function init()
		{
			directories = new Array(5);
		}
		
		//given a filename and desired directory, attempt to complete the path to an asset
		public static function completePath(desiredDirectory:int, filename:String):String
		{
			//if the desired directory exists, complete the path
			if(directories && desiredDirectory >= 0 && desiredDirectory < directories.length)
			{
				var directory:String = directories[desiredDirectory];
				if(directory)
				{
					//if the two string are already seperated by a forward slash, concatenate them
					if(directory.charAt(directory.length - 1) == "/" || filename.charAt(0))
						return directories[desiredDirectory] + filename;
					//otherwise add a forward slash in between
					else
						return directories[desiredDirectory] + "/" + filename;
				}
			}
			
			//by default, return the given filename
			return(filename);
		}
		
		public static function getDirectory(desiredDirectory:int):String
		{
			if(desiredDirectory >= 0 && desiredDirectory < directories.length)
				return directories[desiredDirectory];
			else
				return null;
		}
		
		public static function setDirectory(desiredDirectory:int, path:String):void
		{
			if(desiredDirectory >= 0 && desiredDirectory < directories.length)
				directories[desiredDirectory] = path;
		}
	}
}