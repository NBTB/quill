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
		
		public function ContentContainer(autoContentPadding:Number = 0, focalRectangle:Rectangle = null, scrollBar:ScrollBar = null, hideUnecessaryScrollBar:Boolean = true)
		{
			this.autoContentPadding = autoContentPadding;
			this.focalRectangle = focalRectangle;
			this.scrollBar = scrollBar;
			this.hideUnecessaryScrollBar = hideUnecessaryScrollBar;
			
			//if a scroll bar has been attached, listen for the scrolling of the scroll bar
			if(scrollBar)
			{
				scrollBar.addEventListener(ScrollBar.SCROLLED, function(e:Event):void
																				{
																					//compute how much content must be scrolled
																					var scrollFactor:Number = scrollBar.getScrolledPercentage();
																					if(scrollFactor >= 0)
																					{
																						scrollFactor *= contentTail.y - contentHead.y;
																						scrollFactor += y;	
																					
																						//scroll content
																						scrollContent(new Point(0, scrollFactor));
																					}
																				});
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
			
			//add new content
			addChild(child);
			
			//if other content is not being repositioned, return
			if(!repositionContent)
				return child;
				
			//determine how much other content will have to be moved
			var displacement = child.height + autoContentPadding;
			
			//push other content down
			for(var i:int = 0; i < numChildren; i++)
			{
				var checkChild:DisplayObject = getChildAt(i);
				if(checkChild != child)
					checkChild.y += displacement;
			}
				
			//content was moved after tail was last updated, 
			//so if the new child is not responsible for the tail, move the tail down
			if(contentTail.y > child.y)
				contentTail.y += displacement;			
				
			trace(contentTail.y);
			if(numChildren > 0)
				trace(getChildAt(0).y + getChildAt(0).height);
			trace(focalRectangle.y + focalRectangle.height);
			trace("\n")
				
			return child;
		}
		
		public function addChildToTail(child:DisplayObject, repositionContent:Boolean = false):DisplayObject
		{
			//if no content exists, place new child at the bottom
			if(numChildren > 0);
				child.y = contentTail.y + autoContentPadding;
			
			//if content is not being displaced, simply add the new child below other content and return
			if(!repositionContent)
				return addChild(child);
			
			//add the child so that it ends at the bottom
			child.y -= child.height;
			addChild(child);
			
			//determine how much other content will have to be moved
			var displacement = child.height + autoContentPadding;
			
			//push other content up
			for(var i:int = 0; i < numChildren; i++)
			{
				var checkChild:DisplayObject = getChildAt(i);
				if(checkChild != child)
					checkChild.y -= displacement;
			}
				
			//content was moved after head was last updated, 
			//so if the new child is not responsible for the head, move the head up
			if(contentHead.y < child.y)
				contentHead.y -= displacement;			
			
			return child;
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
		
		private function updateScrollBar():void
		{
			//move scroller back to top
			scrollBar.resetScroller();
			
			//update scroller bar height
			scrollBar.setContentHeight(contentTail.y - contentHead.y);
			
			//determine if scroll bar should be visible
			if((contentHead.y < focalRectangle.y) || (contentTail.y > focalRectangle.y + focalRectangle.height))
				scrollBar.visible = true;	
			else if(hideUnecessaryScrollBar)
				scrollBar.visible = false;
		}
		
		//translate content for scrolling (note that content moves opposite scroll)
		private function scrollContent(distance:Point):void
		{			
			x -= distance.x;
			y -= distance.y;
		}
	}
}