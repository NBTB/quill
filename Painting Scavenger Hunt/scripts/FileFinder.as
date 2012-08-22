package
{
	public class FileFinder
	{
		private static var directories:Array = new Array(5); 	//list of known directories
		
		public static const INTERFACE:int = 0;
		public static const GAME_INFO:int = 1;
		public static const OOI_IMAGES:int = 2;
		public static const OOI_INFO:int = 3;
		public static const END_GOAL_IMAGES:int = 4;
		
		//given a filename and desired directory, attempt to complete the path to an asset
		public static function completePath(filename:String, desiredDirectory:int)
		{
			//if the desired directory exists, complete the path
			var directory:String = directories[desiredDirectory];
			if(directory)
			{
				//if the two string are already seperated by a forward slash, concatenate them
				if(directory.charAt(directory.length - 1) == "/" || filename.charAt(0))
					return desiredDirectory + filename;
				//otherwise add a forward slash in between
				else
					return desiredDirectory + "/" + filename;
			}
		}
	}
}