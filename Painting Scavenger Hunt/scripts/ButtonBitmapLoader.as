package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	
	public class ButtonBitmapLoader extends SimpleButton
	{
		private var upImage:BitmapData = null;
		private var overImage:BitmapData = null;
		private var downImage:BitmapData = null;
		private var hittestImage:BitmapData = null;
		private var loading:Boolean = false;
		
		public static const IMAGE_LOAD_ERROR = "An image failed to load";
	
		public function loadBitmaps(upFilename:String = null, overFilename:String = null, downFilename:String = null, hittestFilename = null)
		{
			//flags that note if a state image needs to be loaded
			var upNeeded:Boolean = upFilename != null;
			var overNeeded:Boolean = overFilename != null;
			var downNeeded:Boolean = downFilename != null;
			var hittestNeeded:Boolean = hittestFilename != null;
			
			//flag as loading
			loading = true;
			
			//load up image if needed
			if(upNeeded)
			{
				var upLoader:Loader = new Loader();
				upLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void	
																		   {	
																				upNeeded = false;
																				completedBitmap(0, Bitmap(LoaderInfo(e.target).content), upNeeded, overNeeded, downNeeded, hittestNeeded)	
																		   });
				upLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void	
																		   {	
																				upNeeded = false;
																				errorBitmap(upFilename, 0, upNeeded, overNeeded, downNeeded, hittestNeeded)	
																		   });
				upLoader.load(new URLRequest(upFilename));
			}
			
			//load over image if needed
			if(overNeeded)
			{
				var overLoader:Loader = new Loader();
				overLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void	
																		   {	
																				overNeeded = false;
																				completedBitmap(1, Bitmap(LoaderInfo(e.target).content), upNeeded, overNeeded, downNeeded, hittestNeeded)	
																		   });
				overLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void	
																		   {	
																				overNeeded = false;
																				errorBitmap(overFilename, 1, upNeeded, overNeeded, downNeeded, hittestNeeded)	
																		   });
				overLoader.load(new URLRequest(overFilename));
			}
			
			//load down image if needed
			if(downNeeded)
			{
				var downLoader:Loader = new Loader();
				downLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void	
																		   {	
																				downNeeded = false;
																				completedBitmap(2, Bitmap(LoaderInfo(e.target).content), upNeeded, overNeeded, downNeeded, hittestNeeded)	
																		   });
				downLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void	
																		   {	
																				downNeeded = false;
																				errorBitmap(downFilename, 2, upNeeded, overNeeded, downNeeded, hittestNeeded)	
																		   });
				downLoader.load(new URLRequest(downFilename));
			}
			
			//load hittest image if needed
			if(hittestNeeded)
			{
				var hittestLoader:Loader = new Loader();
				hittestLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void	
																		   {	
																				hittestNeeded = false;
																				completedBitmap(3, Bitmap(LoaderInfo(e.target).content), upNeeded, overNeeded, downNeeded, hittestNeeded)	
																		   });
				hittestLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void	
																		   {	
																				hittestNeeded = false;
																				errorBitmap(hittestFilename, 3, upNeeded, overNeeded, downNeeded, hittestNeeded)	
																		   });
				hittestLoader.load(new URLRequest(hittestFilename));
			}
			
			
			
			
		}
		
		private function completedBitmap(stateIndex:int, image:Bitmap, upNeeded:Boolean, overNeeded:Boolean, downNeeded:Boolean, hittestNeeded:Boolean):void
		{
			//store loaded error
			switch(stateIndex)
			{
				case 0:
					upImage = image.bitmapData;
					break;
				case 1:
					overImage = image.bitmapData;
					break;
				case 2:
					downImage = image.bitmapData;
					break;
				case 3:
					hittestImage = image.bitmapData;
					break;
			}
			
			//if no more loading is required, dispatch a completion event and flag as not loading
			if(!(upNeeded || overNeeded || downNeeded || hittestNeeded))
			{
				loading = false;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		private function errorBitmap(stateFilename:String, stateIndex:int, upNeeded:Boolean, overNeeded:Boolean, downNeeded:Boolean, hittestNeeded:Boolean):void
		{
			//trace out which image failed to load
			var erroredState:String = null;
			switch(stateIndex)
			{
				case 0:
					erroredState = "Up-State";
					break;
				case 1:
					erroredState = "Over-State";
					break;
				case 2:
					erroredState = "Down-State";
					break;
				case 3:
					erroredState = "Hittest-State";
					break;
			}
			trace(erroredState + " image at " + stateFilename + " could not be loaded properly. Other images may still be accessible");
			
			//dispatch an error event
			dispatchEvent(new Event(IMAGE_LOAD_ERROR));
			
			//if no more loading is required, dispatch a completion event and flag as not loading
			if(!(upNeeded || overNeeded || downNeeded || hittestNeeded))
			{
				loading = false;
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function disposeOfBitmaps()
		{
			if(upImage)
				upImage.dispose();
			if(overImage)
				overImage.dispose();
			if(downImage)
				downImage.dispose();
			if(hittestImage)
				hittestImage.dispose();
		}
		
		public function getUpImage():BitmapData				{	return upImage;										}
		public function getOverImage():BitmapData			{	return (overImage) ? overImage : upImage;			}
		public function getDownImage():BitmapData			{	return (downImage) ? downImage : upImage;			}
		public function getHittestImage():BitmapData		{	return (hittestImage) ? hittestImage : upImage;		}
		public function isLoading():Boolean					{	return loading;										}
	}
}