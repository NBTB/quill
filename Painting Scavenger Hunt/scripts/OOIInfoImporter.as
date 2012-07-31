package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.xml.*;
	import flash.text.*;
	
	public class OOIInfoImporter extends EventDispatcher
	{	
		private var xmlData:XMLList = null; 	//XML specifications
	
		public function OOIInfoImporter(xmlData:XMLList)
		{
			this.xmlData = xmlData;
		}
	
		public function loadInfoToOOI(targetOOI:ObjectOfInterest)
		{
			/*NEED to make asynchronos in order handle events, may need helper methods and class fields*/
			
			//create text loader and listen for when it finishes importing a file
			var textLoader:TextLoader = new TextLoader();
			textLoader.addEventListener(TextLoader.TEXT_FILE_IMPORTED, function(e:Event):void
																						{
																							/*TODO take in section number*/
																							//parse text file
																							var newText:String = textLoader.parseText();
																							
																							//if text was found, add a textfield to the object's info pane
																							if(newText)
																							{
																								var newTextField:TextField = new TextField();
																								newTextField.defaultTextFormat = OOIInfoPane.getTitleFormat();
																								newTextField.text = newText;	
																								newTextField.width = 180;
																								newTextField.wordWrap = true;
																								newTextField.selectable = false;
																								targetOOI.addInfoToPaneTail(newTextField);
																							}
																						});
			
			//extract list of children
			var children:XMLList = xmlData.children();
			
			//add content to the object of interest's info
			for each(var child:XML in children)
			{
				//if the child is a text file, load the text
				if(child.name() == "text_file")
				{
					//import text file
					textLoader.importText(child);
				}
			}
		}
	}
}