package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;	
    import flash.xml.*;
	import flash.geom.*;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
     
    public class HuntImporter extends EventDispatcher
    {     
		private var menuImportFile:String = null	
		private var aboutImportFile:String = null
		private var huntImportFile:String = null
		private var paintingImportFile:String = null
		private var ooiImportFile:String = null
		private var endGoalImportFile:String = null
	
	
		var myArrayListeners:Array=[];					//Array of Event Listeners in BaseMenu
	
        //event types
		public static const SPECS_AND_DIRECTORIES_FOUND:String = "Specification files found";
		public static const START_UP_LOADED:String = "Start-up loaded";
		public static const HUNT_LOADED:String = "Hunt loaded";
        public static const PAINTING_LOADED:String = "Painting loaded";
        public static const OBJECTS_LOADED:String = "Objects loaded";
        public static const END_GOAL_LOADED:String = "End goal loaded";
		
		//find specification files for importation with the XML of the given file
		public function findSpecFilesAndAssetDirectories(specListFilename:String, stageSize:Point, canvasRectangle:Rectangle)
		{
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																		{
																			//convert text to xml
																			var specList = new XML(e.target.data);
																			
																			//attempt to give loading screen a title
																			if(specList.hasOwnProperty("loading_title"))
																				LoadingMenu.loadingTitle = specList.loading_title;
																			
																			//attempt to parse stage size
																			if(specList.hasOwnProperty("stage_size"))
																			{
																				var sizeAttribs:XMLList = specList.stage_size.attributes();
																				for each(var sizeAttrib in sizeAttribs)
																				{
																					if(sizeAttrib.name() == "width")
																						stageSize.x = Number(sizeAttrib);
																					if(sizeAttrib.name() == "height")
																						stageSize.y = Number(sizeAttrib);
																				}
																			}
																			
																			//attempt to parse canvas rectangle
																			if(specList.hasOwnProperty("canvas_rectangle"))
																			{
																				var rectAttribs:XMLList = specList.canvas_rectangle.attributes();
																				for each(var rectAttrib in rectAttribs)
																				{
																					if(rectAttrib.name() == "x")
																						canvasRectangle.x = Number(rectAttrib);
																					if(rectAttrib.name() == "y")
																						canvasRectangle.y = Number(rectAttrib);
																					if(rectAttrib.name() == "width")
																						canvasRectangle.width = Number(rectAttrib);
																					if(rectAttrib.name() == "height")
																						canvasRectangle.height = Number(rectAttrib);
																				}
																			}
																			
																			//attempt to find spec files
																			if(specList.hasOwnProperty("menu"))
																				menuImportFile = specList.menu;
																			if(specList.hasOwnProperty("about"))
																				aboutImportFile = specList.about;
																			if(specList.hasOwnProperty("hunt"))
																				huntImportFile = specList.hunt;
																			if(specList.hasOwnProperty("painting"))
																				paintingImportFile = specList.painting;
																			if(specList.hasOwnProperty("objects_of_interest"))
																				ooiImportFile = specList.objects_of_interest;
																			if(specList.hasOwnProperty("end_goal"))
																				endGoalImportFile = specList.end_goal;
																				
																			//attempt to find asset directories
																			FileFinder.init();
																			if(specList.hasOwnProperty("Asset_Directories"))
																			{
																				var directoryList:XMLList = specList.Asset_Directories;
																				if(directoryList.hasOwnProperty("game_interface"))
																					FileFinder.setDirectory(FileFinder.INTERFACE, directoryList.game_interface);
																				if(directoryList.hasOwnProperty("game_info"))
																					FileFinder.setDirectory(FileFinder.GAME_INFO, directoryList.game_info);
																				if(directoryList.hasOwnProperty("object_of_interest_images"))
																					FileFinder.setDirectory(FileFinder.OOI_IMAGES, directoryList.object_of_interest_images);
																				if(directoryList.hasOwnProperty("object_of_interest_info"))
																					FileFinder.setDirectory(FileFinder.OOI_INFO, directoryList.object_of_interest_info);
																				if(directoryList.hasOwnProperty("end_goal_images"))
																					FileFinder.setDirectory(FileFinder.END_GOAL_IMAGES, directoryList.end_goal_images);	
																			}
																														   
																																							
																			//dispatch success
																			dispatchEvent(new Event(SPECS_AND_DIRECTORIES_FOUND));
																		});
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																			   {
																				   trace("Failed to load specification list.");
																				   dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
																			   });
			xmlLoader.load(new URLRequest(specListFilename));
		}
		
         
		//load XML start up specification
		public function importStartUp()
		{
			//track load status of menu parameters and info about game
			var menuParamsLoaded:Boolean = false;
			var aboutLoaded:Boolean = false;
			
			//load menu parameters
			var menuXMLLoader:URLLoader = new URLLoader();
            menuXMLLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																			{
																				parseMenu(new XML(e.target.data));																				
																				menuParamsLoaded = true;
																				if(menuParamsLoaded && aboutLoaded)
																					dispatchEvent(new Event(START_UP_LOADED));
																			});
			menuXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																				   {
																						trace("Failed to load menu parameters.");																					   
																				 	 	dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
																				   });
            menuXMLLoader.load(new URLRequest(menuImportFile));
			
			//load info about game
			var aboutXMLLoader:URLLoader = new URLLoader();
            aboutXMLLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																			 {
																				parseMenuContent(new XML(e.target.data));
																				aboutLoaded = true;
																				if(menuParamsLoaded && aboutLoaded)
																					dispatchEvent(new Event(START_UP_LOADED));
																			 });
			aboutXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																				    {
																					  	trace("Failed to load info about game.");
																						dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
																				    });
            aboutXMLLoader.load(new URLRequest(aboutImportFile));
		}
		
		
        //load XML scavenger hunt specification
        public function importHunt(paintingCanvas:PaintingCanvas, ooiManager:OOIManager, magnifyingGlass:MagnifyingGlass, endGoalMenu:EndGoalMenu, notificationTextColorNormal:ColorTransform, notificationTextColorNew:ColorTransform):void
        {			
			//track load status of hunt parameters and painting
			var huntLoaded:Boolean = false;
			var paintingLoaded:Boolean = false;
			
			//load hunt
            var huntXMLLoader:URLLoader = new URLLoader();			
            huntXMLLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																			{																				
																				addEventListener(HUNT_LOADED, function(e:Event):void
																															   {
																																	huntLoaded = true;
																																	if(huntLoaded && paintingLoaded)
																																		prepareToParseAssets(paintingCanvas, ooiManager, endGoalMenu);
																															   });
																				parseHunt(new XML(e.target.data), ooiManager, magnifyingGlass, notificationTextColorNormal, notificationTextColorNew);
																																	
																			});
			huntXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																				   {
																					   	trace("Failed to load hunt parameters.");
																						dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
																				   });
			huntXMLLoader.load(new URLRequest(huntImportFile));
			
			//load painting
            var paintingXMLLoader:URLLoader = new URLLoader();			
            paintingXMLLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																				{	
																					addEventListener(PAINTING_LOADED, function(e:Event):void
																																	   {
																																		   	paintingLoaded = true;
																																			if(huntLoaded && paintingLoaded)
																																				prepareToParseAssets(paintingCanvas, ooiManager, endGoalMenu);
																																	   });
																					parsePainting(new XML(e.target.data), paintingCanvas, magnifyingGlass);  
																				});
			paintingXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																					   {
																						  	trace("Failed to load painting.");
																							dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
																					   });
			paintingXMLLoader.load(new URLRequest(paintingImportFile));
        }
		
		//parse XML specification of menu parameters
		private function parseMenu(menuParams:XML)
		{
			// Create a new instance of the Font symbol from the document's library.
			var normalFont:Font = new NormalFont();
			var boldFont:Font = new BoldFont();
			var italicFont:Font = new ItalicFont();
			var boldItalicFont:Font = new BoldItalicFont();
			
			//attempt to retrieve standard menu parameters
			if(menuParams.hasOwnProperty("menu_color"))
				BaseMenu.menuColor = Number(menuParams.menu_color);
			if(menuParams.hasOwnProperty("menu_border"))
				BaseMenu.menuBorderColor = Number(menuParams.menu_border);
			if(menuParams.hasOwnProperty("menu_opacity"))
				BaseMenu.menuOpacity = Number(menuParams.menu_opacity);
			
			//attempt to create text formats
			if(menuParams.hasOwnProperty("text_format"))
			{
				
				
				var formats:XMLList = menuParams.text_format;
				for each(var formatParams in formats)
				{
					var attribs = formatParams.attributes();
					for each(var attrib in attribs)
					{
						if(attrib.name() == "name")
						{
							//parse format
							var formatName = attrib;
							var textFormats:XMLList = menuParams.text_format;
							var newFormat:TextFormat = new TextFormat();
							if(formatParams.hasOwnProperty("size"))
								newFormat.size = Number(formatParams.size);
							if(formatParams.hasOwnProperty("color") && formatParams.color != "null")
								newFormat.color = Number(formatParams.color);
							if(formatParams.hasOwnProperty("align"))
							{
								if(formatParams.align == "left")
									newFormat.align = TextFormatAlign.LEFT;
								else if(formatParams.align == "right")
									newFormat.align = TextFormatAlign.RIGHT;
								else if(formatParams.align == "center")
									newFormat.align = TextFormatAlign.CENTER;
								else if(formatParams.align == "justify")
									newFormat.align = TextFormatAlign.JUSTIFY;
							}
							if(formatParams.hasOwnProperty("bold") && formatParams.bold == "true")
								newFormat.bold = true;
							if(formatParams.hasOwnProperty("italic") && formatParams.italic == "true")
								newFormat.italic = true;
								
							//pick embedded font
							if(!newFormat.bold && !newFormat.italic)
								newFormat.font = normalFont.fontName;
							else if(!newFormat.italic)
								newFormat.font = boldFont.fontName;
							else if(!newFormat.bold)
								newFormat.font = italicFont.fontName;
							else
								newFormat.font = boldItalicFont.fontName;
								
							//store format
							if(formatName == "title")
								BaseMenu.titleFormat = newFormat;
							else if(formatName == "body")
								BaseMenu.bodyFormat = newFormat;
							else if(formatName == "caption")
								BaseMenu.captionFormat = newFormat;
							else if(formatName == "text_button")
								BaseMenu.textButtonFormat = newFormat;
							else if(formatName == "link_usable")
								BaseMenu.linkUsableFormat = newFormat;
							else if(formatName == "link_unusable")
								BaseMenu.linkUnusableFormat = newFormat;
							else if(formatName == "link_accentuated")
								BaseMenu.linkAccentuatedFormat = newFormat;
						}
					}
				}
			}
			
			//attempt to define up, over, and down state colors for clickable text
			if(menuParams.hasOwnProperty("up_color"))
				BaseMenu.textUpColor = Number(menuParams.up_color);
			if(menuParams.hasOwnProperty("over_color"))
				BaseMenu.textOverColor = Number(menuParams.over_color);
			if(menuParams.hasOwnProperty("down_color"))
				BaseMenu.textDownColor = Number(menuParams.down_color);													
		}
         
		//parse XML specification of menu content
		private function parseMenuContent(menuContent:XML)
		{					
			//parse welcome
			if(menuContent.hasOwnProperty("welcome_title"))
				IntroMenu.introTitle = menuContent.welcome_title;
			if(menuContent.hasOwnProperty("welcome_text_file"))
			{
				var welcomeLoader:TextLoader = new TextLoader();			
				welcomeLoader.addEventListener(TextLoaderEvent.TEXT_FILE_IMPORTED, function(e:Event):void	{	IntroMenu.introText = welcomeLoader.parseText();	});
				welcomeLoader.importText(FileFinder.completePath(FileFinder.GAME_INFO, menuContent.welcome_text_file));
			}		
		
			//parse objective page
			if(menuContent.hasOwnProperty("objective_title"))
				InstructionsMenu.objectiveTitle = menuContent.objective_title;
			if(menuContent.hasOwnProperty("objective_text_file"))
			{
				var objectiveLoader:TextLoader = new TextLoader();			
				objectiveLoader.addEventListener(TextLoaderEvent.TEXT_FILE_IMPORTED, function(e:Event):void	{	InstructionsMenu.objectiveText = objectiveLoader.parseText();	});
				objectiveLoader.importText(FileFinder.completePath(FileFinder.GAME_INFO, menuContent.objective_text_file));
			}			
			
			//parse clues page
			if(menuContent.hasOwnProperty("clues_title"))
				InstructionsMenu.cluesTitle = menuContent.clues_title;
			if(menuContent.hasOwnProperty("clues_text_file"))
			{
				var cluesLoader:TextLoader = new TextLoader();			
				cluesLoader.addEventListener(TextLoaderEvent.TEXT_FILE_IMPORTED, function(e:Event):void	{	InstructionsMenu.cluesText = cluesLoader.parseText();	});
				cluesLoader.importText(FileFinder.completePath(FileFinder.GAME_INFO, menuContent.clues_text_file));
			}	
			
			//parse objects page
			if(menuContent.hasOwnProperty("objects_title"))
				InstructionsMenu.objectsTitle = menuContent.objects_title;
			if(menuContent.hasOwnProperty("objects_text_file"))
			{
				var objectsLoader:TextLoader = new TextLoader();			
				objectsLoader.addEventListener(TextLoaderEvent.TEXT_FILE_IMPORTED, function(e:Event):void	{	InstructionsMenu.objectsText = objectsLoader.parseText();	});
				objectsLoader.importText(FileFinder.completePath(FileFinder.GAME_INFO, menuContent.objects_text_file));
			}	
			
			//parse end goal page
			if(menuContent.hasOwnProperty("end_goal_title"))
				InstructionsMenu.endGoalTitle = menuContent.end_goal_title;
			if(menuContent.hasOwnProperty("end_goal_text_file"))
			{
				var endGoalLoader:TextLoader = new TextLoader();			
				endGoalLoader.addEventListener(TextLoaderEvent.TEXT_FILE_IMPORTED, function(e:Event):void	{	InstructionsMenu.endGoalText = endGoalLoader.parseText();	});
				endGoalLoader.importText(FileFinder.completePath(FileFinder.GAME_INFO, menuContent.end_goal_text_file));
			}	
			
			//parse controls page
			if(menuContent.hasOwnProperty("controls_title"))
				InstructionsMenu.controlsTitle = menuContent.controls_title;
			if(menuContent.hasOwnProperty("controls_text_file"))
			{
				var controlsLoader:TextLoader = new TextLoader();			
				controlsLoader.addEventListener(TextLoaderEvent.TEXT_FILE_IMPORTED, function(e:Event):void	{	InstructionsMenu.controlsText = controlsLoader.parseText();	});
				controlsLoader.importText(FileFinder.completePath(FileFinder.GAME_INFO, menuContent.controls_text_file));
			}	
			
			//parse about page
			if(menuContent.hasOwnProperty("about_title"))
				InstructionsMenu.aboutTitle = menuContent.about_title;
			if(menuContent.hasOwnProperty("about_text_file"))
			{
				var aboutLoader:TextLoader = new TextLoader();			
				aboutLoader.addEventListener(TextLoaderEvent.TEXT_FILE_IMPORTED, function(e:Event):void	{	InstructionsMenu.aboutText = aboutLoader.parseText();	});
				aboutLoader.importText(FileFinder.completePath(FileFinder.GAME_INFO, menuContent.about_text_file));
			}	
			
			//parse credits page
			if(menuContent.hasOwnProperty("credits_title"))
				InstructionsMenu.creditsTitle = menuContent.credits_title;
			if(menuContent.hasOwnProperty("credits_text_file"))
			{
				var creditsLoader:TextLoader = new TextLoader();			
				creditsLoader.addEventListener(TextLoaderEvent.TEXT_FILE_IMPORTED, function(e:Event):void	{	InstructionsMenu.creditsText = creditsLoader.parseText();	});
				creditsLoader.importText(FileFinder.completePath(FileFinder.GAME_INFO, menuContent.credits_text_file));
			}			
			
			//parse restart menu
			if(menuContent.hasOwnProperty("restart_text"))
				RestartMenu.restartText = menuContent.restart_text;
			
			//parse ending
			if(menuContent.hasOwnProperty("ending_text"))
				Ending.endingText = menuContent.ending_text;
		}
		 
        //parse XML specification of scavenger hunt parameters
        private function parseHunt(hunt:XML, ooiManager:OOIManager, magnifyingGlass:MagnifyingGlass, notificationTextColorNormal:ColorTransform, notificationTextColorNew:ColorTransform):void
        {              
            //parse hunt attributes
            var mgZoom:Number = 1;
            var mgRadius:Number = 100;
            var huntCount:int = -1;
            var huntAttribs:XMLList = hunt.attributes();
            for each(var attrib in huntAttribs)
            {
                if(attrib.name() == "magnify_scale")
                    mgZoom = Number(attrib);
                if(attrib.name() == "magnify_radius")
                    mgRadius = Number(attrib);
                if(attrib.name() == "hunt_count")
                    huntCount = int(Number(attrib));
            }
			
            //set magnifying glass defaults
            magnifyingGlass.setDefaultZoom(mgZoom);
            magnifyingGlass.setDefaultRadius(mgRadius);
             
            //set number of number of usable objects of interest
            ooiManager.setSolvableOOICount(huntCount);      			
			
			//attempt to parse final two clue menu outputs
			if(hunt.hasOwnProperty("final_clue"))
				CluesMenu.finalClue = hunt.final_clue;
			if(hunt.hasOwnProperty("congratulations_clue"))
				CluesMenu.congratulations = hunt.congratulations_clue;			
			
			//attempt to parse notification colors
			if(hunt.hasOwnProperty("notification_normal_color"))
				notificationTextColorNormal.color = Number(hunt.notification_normal_color);
			if(hunt.hasOwnProperty("notification_new_color"))
				notificationTextColorNew.color = Number(hunt.notification_new_color);
				
			//dispatch hunt loaded event
			dispatchEvent(new Event(HUNT_LOADED));
        }
         
        //parse XML specification of painting to be applied to canvas
        private function parsePainting(painting:XML, paintingCanvas:PaintingCanvas, magnifyingGlass:MagnifyingGlass)
        {
			//track the load status of interactive and non-interactive paintings
			var interactiveLoaded:Boolean = false;
			var nonInteractiveLoaded:Boolean = false;
			
            //load interactive painting
            var ibitmapLoader:Loader = new Loader();
            ibitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
                                                                                              {                 
																							  	//attach painting to canvas
																								paintingCanvas.attachPainting(Bitmap(LoaderInfo(e.target).content));
																							  
                                                                                               	//display painting on canvas
                                                                                                paintingCanvas.displayPainting();
                                                                                                 
                                                                                                //if both versions of the painting are loaded, dispatch event for painting importation completion
																								interactiveLoaded = true
																								if(interactiveLoaded && nonInteractiveLoaded)
                                                                                                	dispatchEvent(new Event(PAINTING_LOADED));
                                                                                              });
			ibitmapLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																										    {	
																												trace("Failed to load painting (interactive)");
																												dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
																										    });
            ibitmapLoader.load(new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, painting.interactive_filename)));
			
			//load non-interactive painting
            var nbitmapLoader:Loader = new Loader();
            nbitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
                                                                                              {     
																							  	//attach non-interacive painting to canvas
																								paintingCanvas.attachNonInteractivePainting(Bitmap(LoaderInfo(e.target).content));
																							  
                                                                                                //if both versions of the painting are loaded, dispatch event for painting importation completion
																								nonInteractiveLoaded = true
																								if(interactiveLoaded && nonInteractiveLoaded)
                                                                                                	dispatchEvent(new Event(PAINTING_LOADED));
                                                                                              });
			nbitmapLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																										    {	
																												trace("Failed to load painting (non-interactive)");
																												dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
																										    });
            nbitmapLoader.load(new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, painting.non_interactive_filename)));
        }
		
		//prepare to parse objects of interest and end goal pieces
		private function prepareToParseAssets(paintingCanvas:PaintingCanvas, ooiManager:OOIManager, endGoalMenu:EndGoalMenu)
		{
			//flags of completion
			var objectsLoaded:Boolean = false;
			var endGoalLoaded:Boolean = false;
			
			//listen for all of the objects to be fully loaded
			addEventListener(OBJECTS_LOADED, function(e:Event):void
														  {
																objectsLoaded = true;
																if(objectsLoaded && endGoalLoaded)
																dispatchEvent(new Event(Event.COMPLETE));
														  });
			
			//load and parse objects of interest to be used in hunt
			var ooiXMLLoader:URLLoader = new URLLoader();
			ooiXMLLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																	   {
																			var ooiXML:XML = new XML(e.target.data);
																			if(ooiXML.hasOwnProperty("Object_Of_Interest"))
																				parseObjectsOfInterest(ooiXML.children(), ooiManager, paintingCanvas.getPaintingScale(), new Rectangle(paintingCanvas.x, paintingCanvas.y, paintingCanvas.getPaintingWidth(), paintingCanvas.getPaintingHeight())); 
																			else
																				dispatchEvent(new Event(OBJECTS_LOADED));
																	   });
			ooiXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																			  {
																				  trace("Failed to load objects of interest specification file.");
																				  dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
																			  });
			ooiXMLLoader.load(new URLRequest(ooiImportFile));
			
			
			//listen for all of the end goal pieces to be fully loaded
			addEventListener(END_GOAL_LOADED, function(e:Event):void
														  {
															endGoalLoaded = true;
															if(objectsLoaded && endGoalLoaded)
																dispatchEvent(new Event(Event.COMPLETE));
														  });
			
			//load and end goal pieces to be used in hunt
			var endGoalXMLLoader:URLLoader = new URLLoader();
			endGoalXMLLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																		   {
																				var endGoalXML:XML = new XML(e.target.data);
																				if(endGoalXML.hasOwnProperty("End_Goal_Piece"))
																					parseEndGoalPieces(endGoalXML.children(), endGoalMenu);  
																				else
																					dispatchEvent(new Event(END_GOAL_LOADED));
																				
																		   });
			endGoalXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																				  {
																					  trace("Failed to load end goal specification file.");
																					  dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
																				  });
			endGoalXMLLoader.load(new URLRequest(endGoalImportFile));
		}
                 
        //parse XML specification of obejcts of interest
        private function parseObjectsOfInterest(objectsOfInterest:XMLList, ooiManager:OOIManager, ooiScaleFactor:Number, canvasRectangle:Rectangle)
        {			
            //object of interest loading counters
            var objectsParsed:Number = 0;
            var objectsLoaded:Number = 0;
            var objectsFailed:Number = 0;
             
            //flag noting if all objects have been parsed
            var allObjectsParsed:Boolean = false;
            for each(var ooi in objectsOfInterest)
            {
				//parse default object of interest info pane position and size
				if(ooi.name() == "default_info_rect")
				{
					var defaultInfoRect:XML = ooi;
					ObjectOfInterest.defaultInfoRect = new Rectangle();
					if(defaultInfoRect.hasOwnProperty("x"))
						ObjectOfInterest.defaultInfoRect.x = defaultInfoRect.x;
					if(defaultInfoRect.hasOwnProperty("y"))
						ObjectOfInterest.defaultInfoRect.y = defaultInfoRect.y;
					if(defaultInfoRect.hasOwnProperty("width"))
						ObjectOfInterest.defaultInfoRect.width = defaultInfoRect.width;
					if(defaultInfoRect.hasOwnProperty("height"))
						ObjectOfInterest.defaultInfoRect.height = defaultInfoRect.height;
				}
				
                else if(ooi.name() == "Object_Of_Interest" && ooi.hasOwnProperty("name") && ooi.hasOwnProperty("info_snippet") && ooi.hasOwnProperty("hitmap_filename") && ooi.hasOwnProperty("highlight_filename") && ooi.hasOwnProperty("solved_image_filename") && ooi.hasOwnProperty("x") && ooi.hasOwnProperty("y") && ooi.hasOwnProperty("clue"))
                {					
                    //increment the number of objects parsed
                    objectsParsed++;
                     
                    //if information for the object's info pane has been provided, create a loader
                    var ooiInfoLoader:OOIInfoImporter = null;
                    if(ooi.hasOwnProperty("info"))                       
						ooiInfoLoader = new OOIInfoImporter(ooi.info);
                     
                    //create new object of interest
                    var newObject:ObjectOfInterest = new ObjectOfInterest(ooi.name, 
																		  ooi.info_snippet, 
																		  ooi.clue, 
																		  FileFinder.completePath(FileFinder.OOI_IMAGES, ooi.hitmap_filename), 
																		  FileFinder.completePath(FileFinder.OOI_IMAGES, ooi.highlight_filename), 
																		  FileFinder.completePath(FileFinder.OOI_IMAGES, ooi.solved_image_filename), 
																		  ooiInfoLoader, 
																		  canvasRectangle.x + Number(ooi.x) * canvasRectangle.width, 
																		  canvasRectangle.y + Number(ooi.y) * canvasRectangle.height, 
																		  ooiScaleFactor, 
																		  new Point(canvasRectangle.x, canvasRectangle.y), 
																		  new Point(canvasRectangle.x + canvasRectangle.width, canvasRectangle.y + canvasRectangle.height));
                     
                    //set the display position of the object of interest's info pane
                    var infoPaneX:Number = 0;
                    var infoPaneY:Number = 0;
                    if(ooi.hasOwnProperty("info_pane_x"))
                        infoPaneX = canvasRectangle.x + ooi.info_pane_x * canvasRectangle.width;
                    if(ooi.hasOwnProperty("info_pane_y"))
                        infoPaneY = canvasRectangle.y + ooi.info_pane_y * canvasRectangle.height;
                    newObject.setInfoPanePosition(new Point(infoPaneX, infoPaneY));
                     
                     
                    //listen for the completion of the new object
                    newObject.addEventListener(Event.COMPLETE, function(e:Event):void  
                                                                                {  
                                                                                    //increment the number of successfully loaded obejcts
                                                                                    objectsLoaded++;
                                                                                     
                                                                                    //add the object to the painting canvas
                                                                                    ooiManager.addObjectOfInterest(ObjectOfInterest(e.target));
                                                                                     
                                                                                    //if this was the last object of interest to load, dispatch event
                                                                                    if(allObjectsParsed && objectsLoaded + objectsFailed >= objectsParsed)
                                                                                        dispatchEvent(new Event(OBJECTS_LOADED));
                                                                                });
                     
                    //listen of an IO error cause by the new object (signifies a failure to load file)
                    newObject.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
                                                                                              {
                                                                                                //increment the number of failed objects
                                                                                                objectsFailed++;   
                                                                                                 
                                                                                                //if this was the last object of interest to load, dispatch event
                                                                                                if(allObjectsParsed && objectsLoaded + objectsFailed >= objectsParsed)
                                                                                                    dispatchEvent(new Event(OBJECTS_LOADED));
                                                                                              });
                     
                    //begin loading the components of the new object of interest
                    newObject.loadComponents();
                }
            }
             
            //flag that all objects have been parsed (not necessarily fully loaded)
            allObjectsParsed = true;
             
            //if no objects are left to load, initalize the clue list
            if(objectsLoaded + objectsFailed >= objectsParsed)
                dispatchEvent(new Event(OBJECTS_LOADED));
        }
         
        //parse XML specification of pieces of the end goal
        private function parseEndGoalPieces(pieces:XMLList, endGoalMenu:EndGoalMenu)
        {
            //object of interest loading counters
            var piecesParsed:Number = 0;
            var piecesLoaded:Number = 0;
            var piecesFailed:Number = 0;
              
            //flag nothing if all objects have been parsed
            var allPiecesParsed:Boolean = false;
             
            for each(var piece in pieces)
            {
				//parse end goal overlay parameters
				if(piece.name() == "heading_text_color")
					EndGoalMenu.headingTextColor = Number(piece);
				else if(piece.name() == "goal_heading_text")
					EndGoalMenu.goalOverlayText = piece;
				else if(piece.name() == "hidden_heading_text")
					EndGoalMenu.hiddenOverlayText = piece;
					
				//parse number of rewards given freely at beginning 
				else if(piece.name() == "free_reward_count")
					EndGoalMenu.freeRewardCount = Number(piece);
					
				//parse end goal piece
                else if(piece.hasOwnProperty("name") && piece.hasOwnProperty("filename") && piece.hasOwnProperty("x") &&  piece.hasOwnProperty("y") && piece.hasOwnProperty("reward_notification"))
                {
                    //increment the number of objects parsed
                    piecesParsed++;
  
                    //create new object of interest
                    var newPiece:EndGoalPiece = new EndGoalPiece(piece.name, FileFinder.completePath(FileFinder.END_GOAL_IMAGES, piece.filename), Number(piece.x), Number(piece.y), piece.reward_notification);
                       
                    //listen for the completion of the new object
                    newPiece.addEventListener(Event.COMPLETE, function(e:Event):void
                                                                                {
                                                                                    //increment the number of successfully loaded obejcts
                                                                                    piecesLoaded++;
																					
                                                                                    //add the object to the painting canvas
                                                                                    endGoalMenu.addPiece(EndGoalPiece(e.target));   
																					
																					//if this was the last end goal piece to load, dispatch event
                                                                                    if(allPiecesParsed && piecesLoaded + piecesFailed >= piecesParsed)
                                                                                        dispatchEvent(new Event(END_GOAL_LOADED));
                                                                                });
                       
                    //listen of an IO error cause by the new object (signifies a failure to load file)
                    newPiece.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
                                                                                              {
																								
                                                                                                //increment the number of failed objects
                                                                                                piecesFailed++;  
																								
																								//if this was the last end goal piece to load, dispatch event
                                                                                                if(allPiecesParsed && piecesLoaded + piecesFailed >= piecesParsed)
                                                                                                    dispatchEvent(new Event(END_GOAL_LOADED));
                                                                                              });
                       
                    //begin loading the components of the new object of interest
                    newPiece.loadPiece();                 
                    newPiece.visible = false;
                      
                }
            }
               
            //flag that all objects have been parsed (not necessarily fully loaded)
            allPiecesParsed = true;
			
			 //if no pieces are left to load, initalize the clue list
            if(piecesLoaded + piecesFailed >= piecesParsed)
                dispatchEvent(new Event(END_GOAL_LOADED));
        }
		
		override public function addEventListener (type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void 
		{ 
			super.addEventListener (type, listener, useCapture, priority, useWeakReference);
			myArrayListeners.push({type:type, listener:listener, useCapture:useCapture});
		}
		
		function clearEvents():void 
		{
			for (var i:Number=0; i < myArrayListeners.length; i++) 
			{
				if (this.hasEventListener(myArrayListeners[i].type)) 
				{
					this.removeEventListener(myArrayListeners[i].type, myArrayListeners[i].listener);
				}
			}
			myArrayListeners=null;
		}
    }
}