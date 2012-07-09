package
{
	import flash.display.MovieClip;
	import flash.display.GradientType;
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
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
		
		public function place(center:Point, boundary:Rectangle = null)
		{
			//place magnifying glass at the given center point
			x = center.x;
			y = center.y;
			
			//if a boundary was given, ensure that the magnifying glass's center does not exceed it
			if(boundary)
			{
				var minX:Number = boundary.x;
				var maxX:Number = boundary.x + boundary.width;
				var minY:Number = boundary.y;
				var maxY:Number = boundary.y + boundary.height;
				if(x < minX)
					x = minX;
				else if(x > maxX)
					x = maxX;
				if(y < minY)
					y = minY;
				else if(y > maxY)
					y = maxY;
			}
		}
		
		public function magnifyBitmaps(bitmaps:Array, texturePoints:Array, zoom:Number = -1, radius:Number = -1)
		{
			//if the given zoom is negative or zero, use the default zoom
			if(zoom <= 0)
				zoom = defaultZoom;
			
			//if the given radius is negative, use the default radius
			if(radius < 0)
				radius = defaultRadius;
			
			//clear old graphics information
			graphics.clear();
			
			//magnify all given bitmaps
			for(var i:Number = 0; i < bitmaps.length; i++)
			{
				//adress current bitmap and coordinates
				var bitmap:Bitmap = Bitmap(bitmaps[i]);
				var s:Number = Number(texturePoints[i].x);
				var t:Number = Number(texturePoints[i].y);
				
				//create matrix to be used in bitmap sampling
				var samplingMatrix:Matrix = new Matrix();
				samplingMatrix.translate(-bitmap.bitmapData.width * s, -bitmap.bitmapData.height * t);
				samplingMatrix.scale(zoom, zoom);
				
				//fill lens with bitmap sample
				graphics.beginBitmapFill(bitmap.bitmapData, samplingMatrix, false);
				graphics.drawCircle(0, 0, radius * 0.9);
				graphics.endFill();
			}
			
			//fill border with gradient
			var gradientMatrix:Matrix = new Matrix();
			gradientMatrix.createGradientBox(2 * radius, 2 * radius, 0, -radius, -radius);
			graphics.beginGradientFill(GradientType.RADIAL, borderColors, borderAlphas, borderRatios, gradientMatrix);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
			
		}
		
		public function getDefaultZoom():Number		{	return defaultZoom;		}
		public function getDefaultRadius():Number	{	return defaultRadius;	}
		
		public function setDefaultZoom(defaultZoom:Number):void		{	this.defaultZoom = defaultZoom;		}
		public function setDefaultRadius(defaultRadius:Number):void	{	this.defaultRadius = defaultRadius;	}
	}
}