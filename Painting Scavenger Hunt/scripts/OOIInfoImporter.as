package scripts
{
	import flash.events.*;
	import flash.events.EventDispatcher;
	import flash.xml.*;
	import flash.text.*;
	
	public class OOIInfoImporter extends EventDispatcher
	{	
		private var xmlData:XMLList = null; 		//XML specifications
		private var doneLoading:Boolean = false;	//flag if loading has been completed
		
		var myArrayListeners:Array=[];				//Array of Event Listeners in BaseMenu
	
		public function OOIInfoImporter(xmlData:XMLList)
		{
			this.xmlData = xmlData;
		}
	
		public function loadInfoToOOI(targetOOI:ObjectOfInterest)
		{
			//extract list of children
			var children:XMLList = xmlData.children();
			
			//child counter and total
			var childNum:int = 0;
			var childCount = children.length();
			
			//create text loader and listen for when it finishes importing a file (or fails to do so)
			var textLoader:TextLoader = new TextLoader();
			textLoader.addEventListener(TextLoaderEvent.TEXT_FILE_IMPORTED, function(e:Event):void
																							 {
																								//parse text file
																								var newText:String = textLoader.parseText();
																																													
																								//if text was found, add a textfield to the object's info pane
																								if(newText)
																								{
																									var newTextField:TextField = new TextField();
																									newTextField.defaultTextFormat = BaseMenu.getBodyFormat();
																									newTextField.text = newText;	
																									newTextField.width = 280;
																									newTextField.x = 5;
																									newTextField.wordWrap = true;
																									newTextField.autoSize = TextFieldAutoSize.LEFT;
																									newTextField.selectable = false;
																									newTextField.mouseWheelEnabled = false;
																									newTextField.embedFonts = true;
																									targetOOI.addInfoToPaneTail(newTextField);
																								}
																								
																								//access next child
																								childNum++;
																								accessChild(children, childNum, childCount, textLoader);
																							 });
			textLoader.addEventListener(TextLoaderEvent.TEXT_FILE_IMPORT_FAILED, function(e:IOErrorEvent):void
																										 {
																											//display error in debug trace
																											trace("Failed to load a piece of info about " + targetOOI.getObjectName());
																											
																											//access next child
																											childNum++;
																											accessChild(children, childNum, childCount, textLoader);
																										 });
																						
			
			//access first child of info list
			accessChild(children, childNum, childCount, textLoader);
		}
		
		//attempt to begin loading the next child of the info list
		private function accessChild(children:XMLList, childNum:int, childCount:int, textLoader:TextLoader)
		{
			//if the total number of children has been reached, flag and return before attempting to load any more
			if(childNum >= childCount)
			{
				doneLoading = true;
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			
			//extract child
			var child:XML = children[childNum];
			
			//if the child is a text file, load the text
			if(child.name() == "info_text_file")
			{
				//import text file
				textLoader.importText(FileFinder.completePath(FileFinder.OOI_INFO, child));
			}
		}
		
		public function isDone():Boolean	{	return doneLoading;	}
	}
}