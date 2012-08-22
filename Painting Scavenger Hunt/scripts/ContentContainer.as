package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	public class ContentContainer extends MovieClip
	{
		protected var contentHead:Point = null;						//top-leftmost point of content
		protected var contentTail:Point = null;						//bottom-rightmost point of content
		protected var autoContentPadding:Number = 0;				//padding put between content when added to head or tail
		protected var focalRectangle:Rectangle = null;				//rectangle in which content is expected to appear
		protected var scrollBar:ScrollBar = null;					//attached scroll bar
		protected var hideUnecessaryScrollBar:Boolean = false;		//flag if scroll bar should be hidden when not needed
		protected var scrolledDistance:Point = null;				//distance content has been scrolled
		
		
		public function ContentContainer(autoContentPadding:Number = 0, focalRectangle:Rectangle = null, scrollBar:ScrollBar = null, hideUnecessaryScrollBar:Boolean = true)
		{
			this.autoContentPadding = autoContentPadding;
			this.focalRectangle = focalRectangle;
			this.scrollBar = scrollBar;
			this.hideUnecessaryScrollBar = hideUnecessaryScrollBar;
			this.scrolledDistance = new Point(0, 0);		
			
			//if a scroll bar has been attached, listen for the scrolling of the scroll bar
			if(scrollBar)
			{
				scrollBar.addEventListener(ScrollBar.SCROLLED, trackScrollBar);
			}
		}
	
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{						
			//if the new content is the first content, update the content head			
			if(numChildren < 1)
			{
				
				contentHead = new Point(child.x, child.y);				
				contentTail = new Point(child.x + child.width, child.y + child.height);
				
			}
			//otherwise if the new content appears before all other content, update the content head
			else
			{
				if(child.x < contentHead.x)
					contentHead.x = child.x;
				if(child.y < contentHead.y)
					contentHead.y = child.y;
			}
			
			//add to child list
			super.addChildAt(child, index);
			
			//ensure that tail is current
			contentTail.x = contentHead.x + width;
			contentTail.y = contentHead.y + height;
			
			//if a scroll bar is attached, keep it up to date
			if(scrollBar)
				updateScrollBar();
				
			return child;
		}
	
		override public function addChild(child:DisplayObject):DisplayObject	{	return addChildAt(child, numChildren);	}
		
		public function addChildToHead(child:DisplayObject, repositionContent:Boolean = true):DisplayObject
		{
			//if other content exists, place new child at the top
			if(numChildren > 0)
				child.y = contentHead.y;
			//otherwise, just add child
			else
				return addChild(child);
			
			//if other content is not being repositioned, add new content and return
			if(!repositionContent)
				return addChild(child);
				
			//determine how much other content will have to be moved
			var displacement = child.height + autoContentPadding;
			
			//push other content down
			for(var i:int = 0; i < numChildren; i++)
				getChildAt(i).y += displacement;
				
			//add the child to the list
			return addChild(child);	
		}
		
		public function addChildToTail(child:DisplayObject):DisplayObject
		{
			//if no content exists, place new child at the bottom
			if(numChildren > 0)
				child.y = contentTail.y + autoContentPadding;
			//otherwise, just add new child
			else
				return addChild(child);
			
			//add the new child below other content and return
			return addChild(child);
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject
		{				
			//remove child
			super.removeChild(child);
		
			//keep head and tail current
			if(numChildren > 0)
			{
				var newHead = new Point(contentTail.x, contentTail.y);
				var newTail = new Point(contentHead.x, contentHead.y);
				for(var i:int = 0; i < numChildren; i++)
				{
					var checkChild:DisplayObject = getChildAt(i);
					if(newHead.x > checkChild.x)
						newHead.x = checkChild.x;
					if(newHead.y > checkChild.y)
						newHead.y = checkChild.y;
					if(newTail.x < checkChild.x + checkChild.width)
						newTail.x = checkChild.x + checkChild.width;
					if(newTail.y < checkChild.y + checkChild.height)
						newTail.y = checkChild.y + checkChild.height;					
				}
				contentHead = newHead;
				contentTail = newTail;
			}
			else
			{
				contentHead = null;
				contentTail = null;
			}
			
			//if a scroll bar is attached, keep it up to date
			if(scrollBar)
				updateScrollBar();
							
			return child;
		}
		
		override public function removeChildAt(index:int):DisplayObject	{	return removeChild(getChildAt(index));	}
		
		private function trackScrollBar(e:Event)
		{
			//if content is valid, compute how much content must be scrolled
			if(contentHead && contentTail)
			{
				var scrollFactor:Number = scrollBar.getScrolledPercentage();
				if(scrollFactor >= 0)
				{
					scrollFactor *= (contentTail.y - contentHead.y) - focalRectangle.height + autoContentPadding;

					scrollFactor -= scrolledDistance.y;	
					
					scrollContent(new Point(0, scrollFactor));
				}
			}
		}
		
		private function updateScrollBar():void
		{			
			//update scroller bar height
			scrollBar.setContentHeight(contentTail.y);
			
			//determine if scroll bar should be visible
			if((contentHead.y + y < focalRectangle.y) || (contentTail.y + y > focalRectangle.y + focalRectangle.height))
				scrollBar.visible = true;	
			else if(hideUnecessaryScrollBar)
				scrollBar.visible = false;
				
			//move scroller back to top
			scrollBar.resetScroller();
		}
		
		//determine if a piece of content resides in the container
		public function contentResidesHere(child:DisplayObject)
		{
			
			return (child && child.parent == this);
		}
		
		//translate content for scrolling (note that content moves opposite scroll)
		private function scrollContent(distance:Point):void
		{			
			//translate children in the opposite direction of scrolling
			var childCount:int = numChildren;
			for(var i:int = 0; i < childCount; i++)
			{
				var child:DisplayObject = getChildAt(i);
				child.x -= distance.x;
				child.y -= distance.y;
			}
			
			//track scrolling
			scrolledDistance.x += distance.x;
			scrolledDistance.y += distance.y;
		}
		
		//attach a scroll bar to be tracked (will replace existing scroll bar)
		public function attachScrollBar(scrollBar:ScrollBar):void		{	this.scrollBar = scrollBar;	}
		
		//detach scroll bar so it is not tracked
		public function detachScrollBar():void							{	this.scrollBar = null;	}
	}
}