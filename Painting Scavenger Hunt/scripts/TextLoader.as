package scripts
{
	import flash.events.*;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class TextLoader extends EventDispatcher
	{
		private var textFiles:Array = null;			//list of text fils that have been read in (cleared on load completion)
		private var textImports:Array = null;		//list of imported text strings (cleared on load completion)
		private var sectionTrackers:Array = null;	//list of numbers that track the next section to read in each text string (cleared on load completion)
		private var whichFile:String = null;
		var myArrayListeners:Array=[];								//Array of Event Listeners in BaseMenu
		
		public function TextLoader()
		{
			textFiles = new Array();
			textImports = new Array();
			sectionTrackers = new Array();
		}
		
		public function returnFile():String
		{
			return whichFile;
		}
		
		public function importText(filename:String):void
		{
			//determine if the given file has already been loaded
			var loaded:Boolean = false;
			
			whichFile = filename;
			
			for(var i:int = 0; i < textFiles.length && !loaded; i++)
				if(filename == textFiles[i])
					loaded = true;
			
			//if the file given has not been read before, import it
			if(!loaded)
			{				
				//load new text file
				var textLoader:URLLoader = new URLLoader();
				textLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																			 {
																				//add new entry to lists
																				textFiles.push(filename);
																				textImports.push(e.target.data);
																				sectionTrackers.push(0);
																				
																				//dispatch completion event
																				dispatchEvent(new TextLoaderEvent(filename, TextLoaderEvent.TEXT_FILE_IMPORTED));
																			 });
				textLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																			 {				
																			 	//post alert in debug trace
																				trace("Text file " + filename + " failed to load");
																				
																				//dispatch error event
																				dispatchEvent(new TextLoaderEvent(filename, TextLoaderEvent.TEXT_FILE_IMPORT_FAILED));
																			 });
				textLoader.load(new URLRequest(filename));
			}
			//otherwise, skip the reimport and dispatch a completion event
			else
				dispatchEvent(new Event(TextLoaderEvent.TEXT_FILE_IMPORTED));
		}
		
		public function parseText(filename:String = null, section:int = -1, headerString:String = "##"):String
		{
			//if no text files have been imported, return a failure
			if(!textFiles)
				return null;
			
			//imported file to use
			var importNumber:int = -1;
			
			//if no file was given, use the last file imported
			if(!filename)
			{
				importNumber = textFiles.length - 1;			
				filename = textFiles[importNumber];	
			}
			//otherwise, attempt to find the given filename in the list of already loaded files
			else
				for(var i:int = 0; i < textFiles.length && importNumber < 0; i++)
					if(filename == textFiles[i])
						importNumber = i;
			
			//if the file given has not been read before, return a failure
			if(importNumber < 0)
				return null;
			
			//final result string
			var resultString:String = null;
			
			//address the current text string
			var importedText:String = textImports[importNumber];
			
			//if an no section was given, refer the the current section tracker
			if(section < 0)
				section = sectionTrackers[importNumber];
				
			//track start of substring
			var substringStart:int = 0;
			
			//if anything but the first section is being read, start the substring at the beginning of the current section
			if(section > 0)
			{
				//find section header
				substringStart = findSectionHeader(importedText, section, headerString);
				
				//if the starting index could not be found or the string ends with the header, return a failure
				if(substringStart < 0)
					return null;
				
				//start substring after section header
				substringStart += headerString.length;
				
				//while the first character of the substring would be a new line, move to the next character
				var textLength = importedText.length;
				while(substringStart < textLength && (importedText.charAt(substringStart) == '\n' || importedText.charAt(substringStart) == '\r'))
					substringStart++;				
			}
			//track the end of substring
			var substringEnd = findSectionHeader(importedText, section + 1, headerString) - 1;
			
			//while the last character of the substring would be a new line, move to the prvious character
			while(substringEnd >= 0 && (importedText.charAt(substringEnd) == '\n' || importedText.charAt(substringEnd) == '\r'))
				substringEnd--;	
			
			//if the substring end could be found, substring between start and end indices
			if(substringEnd >= 0)
				resultString = importedText.substr(substringStart, substringEnd - substringStart);
			//otherwise, substring from the start index to the end of the text
			else
				resultString = importedText.substr(substringStart);
				
			//update the current section tracker
			sectionTrackers[importNumber] = section + 1;
			return resultString;
		}
		
		private function findSectionHeader(fullText:String, sectionNumber:int, headerString:String):int
		{
			//start index at the beginning of text
			var index:int = 0;
			
			//find the desired section header
			for(var i:int = 0; i < sectionNumber && index >= 0; i++)
				index = fullText.indexOf(headerString, index+1);
			return index;
		}
		
		override public function addEventListener (type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void 
		{ 
			super.addEventListener (type, listener, useCapture, priority, useWeakReference);
			myArrayListeners.push({type:type, listener:listener, useCapture:useCapture});
		}
		
		function clearEvents():void 
		{
			for (var i:Number=0; i < myArrayListeners.length; i++) 
			{
				if (this.hasEventListener(myArrayListeners[i].type)) 
				{
					this.removeEventListener(myArrayListeners[i].type, myArrayListeners[i].listener);
				}
			}
			myArrayListeners=null;
		}
	}
}