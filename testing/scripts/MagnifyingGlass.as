package
{
	import flash.display.MovieClip;
	import flash.display.GradientType;
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	
	public class MagnifyingGlass extends MovieClip
	{
		private var defaultRadius:Number;
		private var defaultZoom:Number;
		
		private static var borderColors:Array = new Array(0xffffff, 0xffffff, 0xffffff, 0xffffff);
		private static var borderAlphas:Array = new Array(0, 0, 0.5, 0);
		private static var borderRatios:Array = new Array(0, 255 * 0.85, 255 * 0.95, 255);
		
		public function MagnifyingGlass(defaultZoom:Number = 1,defaultRadius:Number = 100)
		{
			//ensure that zoom is greater than zero
			if(defaultZoom <= 0)
				this.defaultZoom = 1;
			else
				this.defaultZoom = defaultZoom;
				
			//ensure that radius is positive
			if(defaultRadius < 0)
				this.defaultRadius = 0;
			else
				this.defaultRadius = defaultRadius;
				
			//do not capture mouse input
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		public function magnifyBitmap(bitmap:Bitmap, s:Number, t:Number, zoom:Number = -1, radius:Number = -1)
		{
			//if the given zoom is negative or zero, use the default zoom
			if(zoom <= 0)
				zoom = defaultZoom;
			
			//if the given radius is negative, use the default radius
			if(radius < 0)
				radius = defaultRadius;
			
			//clamp texture coordinates [0, 1]
			if(s < 0)
				s = 0;
			else if(s > 1)
				s = 1;
			if(t < 0)
				t = 0;
			else if(t > 1)
				t = 1;
			
			//clear old graphics information
			graphics.clear();
			
			//create matrix to be used in bitmap sampling
			var samplingMatrix:Matrix = new Matrix();
			samplingMatrix.translate(-bitmap.bitmapData.width * s, -bitmap.bitmapData.height * t);
			samplingMatrix.scale(zoom, zoom);
			
			//fill lens with bitmap sample
			graphics.beginBitmapFill(bitmap.bitmapData, samplingMatrix);
			graphics.drawCircle(0, 0, radius * 0.9);
			graphics.endFill();
			
			//fill border with gradient
			var gradientMatrix:Matrix = new Matrix();
			gradientMatrix.createGradientBox(2 * radius, 2 * radius, 0, -radius, -radius);
			graphics.beginGradientFill(GradientType.RADIAL, borderColors, borderAlphas, borderRatios, gradientMatrix);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
		}
	}
}