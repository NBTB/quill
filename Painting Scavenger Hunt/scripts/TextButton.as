package scripts
{
	import flash.text.*;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public class TextButton extends SimpleButton
	{
		private var text:String = null;
		private var upTextField = null;
		private var overTextField = null;
		private var downTextField = null;
		
		public function TextButton(text:String, hitbox:Rectangle, upFormat:TextFormat, overFormat:TextFormat, downFormat:TextFormat)
		{
			//create up state
			upTextField = new TextField();
			upTextField.defaultTextFormat = upFormat;
			upTextField.autoSize = TextFieldAutoSize.LEFT;
			
			//create over state
			overTextField = new TextField();
			overTextField.defaultTextFormat = overFormat;
			overTextField.autoSize = TextFieldAutoSize.LEFT;
			
			//create down state
			downTextField = new TextField();
			downTextField.defaultTextFormat = downFormat;
			downTextField.autoSize = TextFieldAutoSize.LEFT;
			
			//populate states with text
			setText(text);
			
			//create hitbox (default size to largest state)
			var hit:Sprite = new Sprite();
			hit.graphics.beginFill(0,1);
			if(!hitbox)
			{
				//determine maximum dimensions between the states
				var hitWidth = (downTextField.width > upTextField.width && downTextField.width > overTextField.width) ? downTextField.width : (overTextField.width > upTextField.width) ? overTextField.width : upTextField.width;
				var hitHeight = (downTextField.height > upTextField.height && downTextField.height > overTextField.height) ? downTextField.height : (overTextField.height > upTextField.height) ? overTextField.height : upTextField.height;
				
				//draw rectangle to fit current states
				hit.graphics.drawRect(0, 0, hitWidth, hitHeight);
			}
			else
				hit.graphics.drawRect(hitbox.x, hitbox.y, hitbox.width, hitbox.height);
			hit.graphics.endFill();
			
			//construct superclass
			super(upTextField, overTextField, downTextField, hit);
		}
		
		public function getText():String	{	return text;	}
		public function setText(newText:String):void
		{
			text = newText;
			upTextField.text = text;
			overTextField.text = text;
			downTextField.text = text;
		}
	}
}