package scripts
{
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	/**
	 * ...
	 * @author Robert Cigna
	 */
	public class ProgressBar extends Sprite
	{
		private var barWidth:Number;
		private var barHeight:Number;
		
		private var barMask:Sprite;
		private var bar:Sprite;
		private var outline:Sprite;
		
		public function ProgressBar(width:Number, height:Number) 
		{
			barHeight = height;
			barWidth = width;
			bar = new Sprite();
			bar.graphics.moveTo(0, 0);
			addChild(bar);
			bar.graphics.lineStyle(2, 0x78942e);
			bar.graphics.beginFill(0xbfc7aa, 1);
			bar.graphics.drawRect(0, 0, barWidth, barHeight);
			bar.graphics.endFill();
			outline = new Sprite();
			addChild(outline);
		}
		
		public function draw(progress:Number):void {
			bar.graphics.beginFill(0xbfc7aa, 1);
			bar.graphics.endFill();
			outline.graphics.clear();
			outline.graphics.moveTo(0, 0);
			outline.graphics.beginFill(0x78942e, 1);
			outline.graphics.drawRect(1, 1, (barWidth * progress) - 2, barHeight - 2);
			outline.graphics.endFill();
			
		}
	}

}