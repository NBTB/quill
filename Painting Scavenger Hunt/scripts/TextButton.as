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
		private var autoFit = false;
		
		public static const UP_STATE = 0;
		public static const OVER_STATE = 1;
		public static const DOWN_STATE = 2;
		
		public function TextButton(text:String, format:TextFormat, upColor:uint, overColor:uint, downColor:uint, hitbox:Rectangle = null, alignment:String = TextFieldAutoSize.LEFT)
		{			
			//create up state
			upTextField = new TextField();
			upTextField.selectable = false;
			upTextField.defaultTextFormat = format;
			upTextField.textColor = upColor;
			upTextField.autoSize = alignment;
			upTextField.embedFonts = true;
			
			//create over state
			overTextField = new TextField();
			overTextField.selectable = false;
			overTextField.defaultTextFormat = format;
			overTextField.textColor = overColor;
			overTextField.autoSize = alignment;
			overTextField.embedFonts = true;
			
			//create down state
			downTextField = new TextField();
			downTextField.selectable = false;
			downTextField.defaultTextFormat = format;
			downTextField.textColor = downColor;
			downTextField.autoSize = alignment;
			downTextField.embedFonts = true;
			
			//populate states with text
			setText(text);
			
			//create hitbox (default size to largest state)
			var hit:Sprite = new Sprite();
			hit.graphics.beginFill(0,1);
			if(!hitbox)
			{
				hit.graphics.drawRect(0, 0, upTextField.width, upTextField.height);
				autoFit = true;
			}
			else
			{
				hit.graphics.drawRect(hitbox.x, hitbox.y, hitbox.width, hitbox.height);
				autoFit = false;
			}
			hit.graphics.endFill();
			
			//construct superclass
			super(upTextField, overTextField, downTextField, hit);
			useHandCursor = true;
		}
		
		//resize the hit test state to tightly fit the largest text
		public function fitHitboxToText()
		{
			//draw rectangle to fit current states
			var hit:Sprite = new Sprite();
			hit.graphics.beginFill(0,1);
			hit.graphics.drawRect(0, 0, upState.width, upState.height);
			hit.graphics.endFill();
			hitTestState = hit;
			
			//flag auto fit
			autoFit = true;
		}
		
		public function getText():String		{	return text;						}
		public function getFormat():TextFormat	{	return upTextField.getTextFormat();	}
		public function getColor(buttonState:int):uint
		{
			switch(buttonState)
			{
				case UP_STATE:
					return upTextField.textColor;
				case OVER_STATE:
					return upTextField.textColor;
				case DOWN_STATE:
					return upTextField.textColor;
				default:
					return 0;
			}
		}
		public function getHitbox():Rectangle	{	return new Rectangle(hitTestState.x, hitTestState.y, hitTestState.width, hitTestState.height)	}
		
		public function setText(newText:String):void
		{
			//update text 
			text = newText;
			upTextField.text = text;
			overTextField.text = text;
			downTextField.text = text;
			
			//if necessary auto fit hit box to text
			if(autoFit)
				fitHitboxToText();
		}
		public function setFormat(format:TextFormat)
		{
			//update up state
			var oldColor:uint = upTextField.textColor;
			upTextField.setTextFormat(format);
			upTextField.textColor = oldColor ;
			
			//update over state
			oldColor = overTextField.textColor;
			overTextField.setTextFormat(format);
			overTextField.textColor = oldColor;
			
			//update down state
			oldColor = downTextField.textColor;
			downTextField.setTextFormat(format);
			downTextField.textColor = oldColor;
			
			//if necessary auto fit hit box to text
			if(autoFit)
				fitHitboxToText();
		}
		public function setColor(buttonState:int, color:uint)
		{
			switch(buttonState)
			{
				case UP_STATE:
					upTextField.textColor = color;
				case OVER_STATE:
					overTextField.textColor = color;
				case DOWN_STATE:
					downTextField.textColor = color;
			}
		}
		public function setHitbox(hitbox:Rectangle):void
		{
			//draw new rectangle
			var hit:Sprite = new Sprite();
			hit.graphics.beginFill(0,1);
			hit.graphics.drawRect(hitbox.x, hitbox.y, hitbox.width, hitbox.height);
			hit.graphics.endFill();
			hitTestState = hit;
			
			//flag no auto fit
			autoFit = false;
		}
	}
}