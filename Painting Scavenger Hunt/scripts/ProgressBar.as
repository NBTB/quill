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
        private var bar2:Sprite;
		private var outline:Sprite;

		private var widthThreshold:Number = 5; //If we've unlocked more clues than this, we need to make the bars less wide so they fit on-screen

		private var sections:Array;

		public function ProgressBar(width:Number, height:Number, max:Number, unlocked:Number)
		{
			barHeight = height;
			barWidth = width;
			bar2 = new Sprite();
			bar2.graphics.moveTo(0, 0);
			addChild(bar2);
			bar2.graphics.beginFill(0xbfc7aa, 0);
			bar2.graphics.drawRect(0, 0, barWidth, barHeight);
			bar2.graphics.endFill();
            sections = new Array();
			draw(max, unlocked);
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
				bar.graphics.lineStyle(2, 0x988972, 0.5);
				bar.graphics.beginFill(0xb8a68a, 1);
				if(unlocked > widthThreshold) {
					bar.graphics.drawCircle(i * 25, 0, 10);
				}
				else {
					bar.graphics.drawCircle(i * 66, 0, 20);
				}
				bar.graphics.endFill();
				if(unlocked > i) {
					bar = new Sprite();
					bar.graphics.moveTo(0, 0);
					addChild(bar);
					sections.push(bar);
					bar.graphics.lineStyle(2, 0x4e463b);
					bar.graphics.beginFill(0x78942e, 1);
					if(unlocked > widthThreshold) {
						bar.graphics.drawCircle(i * 25, 0, 10);
					}
					else {
						bar.graphics.drawCircle(i * 66, 0, 20);
					}
					bar.graphics.endFill();
				}
			}
		}
	}

}
