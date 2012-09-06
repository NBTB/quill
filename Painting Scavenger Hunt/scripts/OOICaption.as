package scripts
{
	import flash.display.*;
	import flash.text.*;
	import flash.geom.*;
	
	public class OOICaption extends BaseMenu
	{
		private var nameText:TextField = null;				//name of object of interest
		private var infoSnippetText:TextField = null; 		//short description
		private var moreInfoHintText:TextField = null;		//hint to double click for more info
		
		public function OOICaption(objectName:String, infoSnippet:String)
		{
			//populate textfields
			nameText = new TextField();
			nameText.embedFonts = true;
			nameText.defaultTextFormat = BaseMenu.titleFormat;
			nameText.selectable = false;
			nameText.mouseEnabled = false;
			nameText.text = objectName;
			nameText.autoSize = TextFieldAutoSize.LEFT;
			infoSnippetText = new TextField();
			infoSnippetText.embedFonts = true;
			infoSnippetText.defaultTextFormat = BaseMenu.bodyFormat;			
			infoSnippetText.selectable = false;
			infoSnippetText.mouseEnabled = false;
			infoSnippetText.text = infoSnippet;
			infoSnippetText.autoSize = TextFieldAutoSize.LEFT;
			moreInfoHintText = new TextField();
			moreInfoHintText.embedFonts = true;
			moreInfoHintText.defaultTextFormat = BaseMenu.captionFormat;			
			moreInfoHintText.selectable = false;
			moreInfoHintText.mouseEnabled = false;
			moreInfoHintText.text = "Double-click for more info";
			moreInfoHintText.autoSize = TextFieldAutoSize.LEFT;
			
			//determine required width of pane
			var reqWidth:Number = 0;
			if(nameText.width > infoSnippetText.width && nameText.width > moreInfoHintText.width)
				reqWidth = nameText.width;
			else if(infoSnippetText.width > moreInfoHintText.width)
				reqWidth = infoSnippetText.width;
			else
				reqWidth = moreInfoHintText.width;
			
			//determine required height of pane
			var reqHeight:Number = nameText.height + infoSnippetText.height + moreInfoHintText.height;
			
			//call superclass's constructor
			super(0, 0, reqWidth + 10, reqHeight + 10, false, false, false);
			
			//add text fields to pane
			addContent(nameText, BaseMenu.LAST_PAGE, new Point(5, 5));
			addContent(infoSnippetText, BaseMenu.LAST_PAGE, new Point(5, nameText.y + nameText.height));
			addContent(moreInfoHintText, BaseMenu.LAST_PAGE, new Point(5, infoSnippetText.y + infoSnippetText.height));
		}
	}
}