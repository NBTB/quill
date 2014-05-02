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
		
		private var widthThreshold:Number = 5; //If we've unlocked more clues than this, we need to make the bars less wide so they fit on-screen
		
		private var sections:Array;
		
		public function ProgressBar(width:Number, height:Number, max:Number, unlocked:Number) 
		{
			barHeight = height;
			barWidth = width;
			bar = new Sprite();
			bar.graphics.moveTo(0, 0);
			addChild(bar);
			bar.graphics.beginFill(0xbfc7aa, 0);
			bar.graphics.drawRect(0, 0, barWidth, barHeight);
			bar.graphics.endFill();
			draw(max, unlocked);
			sections = new Array();
		}
		
		//We represent the clues as sections. Locked ones are grey/empty, found ones are green/full
		public function draw(max:Number, unlocked:Number):void {
				for(var section in sections) {
					sections[section].graphics.clear();
				}
				for(var i = 0; i < max; i++) {
				bar = new Sprite();
				bar.graphics.moveTo(0, 0);
				addChild(bar);
				sections.push(bar);
				bar.graphics.lineStyle(2, 0x949494);
				bar.graphics.beginFill(0xc7c7c7, 1);
				if(unlocked > widthThreshold) {
					bar.graphics.drawRect(i * 25, 0, 15, barHeight);
				}
				else {
					bar.graphics.drawRect(i * 60, 0, 40, barHeight);
				}
				bar.graphics.endFill();
				if(unlocked > i) {
					bar = new Sprite();
					bar.graphics.moveTo(0, 0);
					addChild(bar);
					sections.push(bar);
					bar.graphics.lineStyle(2, 0x78942e);
					bar.graphics.beginFill(0x7cc845, 1);
					if(unlocked > widthThreshold) {
						bar.graphics.drawRect(i * 25, 0, 15, barHeight);
					}
					else {
						bar.graphics.drawRect(i * 60, 0, 40, barHeight);
					}
					bar.graphics.endFill();	
				}
			}
		}
	}

}