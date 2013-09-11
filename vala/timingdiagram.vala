/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: timingdiagram.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class TimingDiagram : Gtk.Window {
	private Gtk.Box vBox;
	private Gtk.MenuBar menubar;
		private Gtk.MenuItem menuFile;
			private Gtk.Menu menuFileMenu;
			private Gtk.MenuItem menuFileExport;
				private Gtk.Menu menuFileExportMenu;
				private Gtk.MenuItem menuFileExportPng;
				private Gtk.MenuItem menuFileExportPdf;
				private Gtk.MenuItem menuFileExportSvg;
			private Gtk.MenuItem menuFileSeparator1;
			private Gtk.MenuItem menuFileExit;
		private Gtk.MenuItem menuRecording;
			private Gtk.Menu menuRecordingMenu;
			private Gtk.MenuItem menuRecordingReset;
		private Gtk.MenuItem menuView;
			private Gtk.Menu menuViewMenu;
			private Gtk.CheckMenuItem menuViewAlwaysontop;
			private Gtk.MenuItem menuViewSeparator1;
			private Gtk.CheckMenuItem menuViewShowgrid;
			private Gtk.MenuItem menuViewSeparator2;
			private Gtk.MenuItem menuViewReset;
	private Gtk.Toolbar toolbar;
		private Gtk.RadioToolButton toolScroll;
			private Gtk.Image toolScrollImage;
		private Gtk.RadioToolButton toolZoom;
			private Gtk.Image toolZoomImage;
		private Gtk.SeparatorToolItem toolSeparator1;
		private Gtk.RadioToolButton toolMove;
			private Gtk.Image toolMoveImage;
		private Gtk.RadioToolButton toolDelete;
			private Gtk.Image toolDeleteImage;
		private Gtk.RadioToolButton toolAdjust;
			private Gtk.Image toolAdjustImage;
	private Gtk.EventBox controller;
	private Gtk.DrawingArea display;
	
	private Cairo.Surface diagramCache;
	private Cairo.Surface offScreenSurface;
	private int largestLengthCache;
//	private int lastGraphRenderTime;
	
	
	private WireState[] wireStates;
	private string[] labels;
	
	/**
	 * Actions to perform when the mouse button is released.
	 */
	private enum MouseMode {
		SCROLL,
		ZOOM,
		MOVE,
		DELETE,
		ADJUST
	}
	
	/**
	 * The x position where the user drags on the display area from.
	 */
	private int xMouseStart;
	/**
	 * The y position where the user drags on the display area from.
	 */
	private int yMouseStart;
	/**
	 * Specifies the action to perform when the mouse button is released.
	 */
	private MouseMode mouseMode = MouseMode.SCROLL;
	
	/**
	 * Display grid on the diagram area.
	 */
	private bool showGrid = true;
	
	public bool alwaysOnTop = true;
	
	/**
	 * Where the user's view is centred around (x).
	 */
	private int xView = 0;
	/**
	 * Where the user's view is centred around (y).
	 */
	private int yView = 0;
	
	private float xZoom = 1;
	private float yZoom = 25;
	
	private double barPosition = 0;
	
	private CompiledCircuit compiledCircuit;
	
	private int iterationCountOffset = 0;
	
	
	public TimingDiagram (CompiledCircuit compiledCircuit) {
		this.compiledCircuit = compiledCircuit;
		populate ();
	}
	
	/**
	 * Populate the window with widgets.
	 */
	public void populate () {
		stdout.printf ("Timing Diagram Window Created\n");
		
		set_default_size (800, 400);
		set_border_width (0);
		delete_event.connect (hide_diagram);
		set_title (Core.programName + " - Timing Diagram");
		
		try {
			icon = new Gdk.Pixbuf.from_file (Config.resourcesDir + "images/icons/smartsim64.png");
		} catch {
			stderr.printf ("Could not load window image.\n");
		}
		
		vBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
		add (vBox);
		
		//Menus
		
		menubar = new Gtk.MenuBar ();
		vBox.pack_start (menubar, false, true, 0);
			
			menuFile = new Gtk.MenuItem.with_label ("File");
			menubar.append (menuFile);
			menuFileMenu = new Gtk.Menu ();
			menuFile.set_submenu (menuFileMenu);
				
				menuFileExport = new Gtk.MenuItem.with_label ("Export");
				menuFileMenu.append (menuFileExport);
				menuFileExportMenu = new Gtk.Menu ();
				menuFileExport.set_submenu (menuFileExportMenu);
					
					menuFileExportPng = new Gtk.MenuItem.with_label ("Diagram Image as PNG Image");
					menuFileExportMenu.append (menuFileExportPng);
					menuFileExportPng.activate.connect (export_png);
					
					menuFileExportPdf = new Gtk.MenuItem.with_label ("Diagram Image as PDF Document");
					menuFileExportMenu.append (menuFileExportPdf);
					menuFileExportPdf.activate.connect (export_pdf);
					
					menuFileExportSvg = new Gtk.MenuItem.with_label ("Diagram Image as SVG Image");
					menuFileExportMenu.append (menuFileExportSvg);
					menuFileExportSvg.activate.connect (export_svg);
					
				menuFileSeparator1 = new Gtk.SeparatorMenuItem ();
				menuFileMenu.append (menuFileSeparator1);
				
				menuFileExit = new Gtk.MenuItem.with_label ("Close Timing Diagram");
				menuFileMenu.append (menuFileExit);
				menuFileExit.activate.connect (() => {hide_diagram();});
					
			menuRecording = new Gtk.MenuItem.with_label ("Recording");
			menubar.append (menuRecording);
			menuRecordingMenu = new Gtk.Menu ();
			menuRecording.set_submenu (menuRecordingMenu);
				
				menuRecordingReset = new Gtk.MenuItem.with_label ("Reset");
				menuRecordingMenu.append (menuRecordingReset);
				menuRecordingReset.activate.connect (() => {reset_timings();});
				
			menuView = new Gtk.MenuItem.with_label ("View");
			menubar.append (menuView);
			menuViewMenu = new Gtk.Menu ();
			menuView.set_submenu (menuViewMenu);
				
				menuViewAlwaysontop = new Gtk.CheckMenuItem.with_label ("Always On Top");
				menuViewMenu.append (menuViewAlwaysontop);
				menuViewAlwaysontop.active = true;
				menuViewAlwaysontop.toggled.connect ((menuItem) => {set_keep_above (menuItem.active); alwaysOnTop = menuItem.active;});
				
				menuViewSeparator1 = new Gtk.SeparatorMenuItem ();
				menuViewMenu.append (menuViewSeparator1);
				
				menuViewShowgrid = new Gtk.CheckMenuItem.with_label ("Show Grid");
				menuViewMenu.append (menuViewShowgrid);
				menuViewShowgrid.active = true;
				menuViewShowgrid.toggled.connect ( 
					(menuItem) => {
						showGrid = menuItem.active;
						diagramCache = null;
						render (true);
					});
				
				menuViewSeparator2 = new Gtk.SeparatorMenuItem ();
				menuViewMenu.append (menuViewSeparator2);
				
				menuViewReset = new Gtk.MenuItem.with_label ("Reset View");
				menuViewMenu.append (menuViewReset);
				menuViewReset.activate.connect (() => {reset_view();});
				
		//Toolbar
		
		toolbar = new Gtk.Toolbar ();
		toolbar.toolbar_style = Gtk.ToolbarStyle.ICONS;
		vBox.pack_start (toolbar, false, true, 0);
			
			toolScrollImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/scroll.png");
			toolScroll = new Gtk.RadioToolButton (null);
			toolScroll.set_label ("Scroll");
			toolScroll.set_icon_widget (toolScrollImage);
			toolbar.insert (toolScroll, -1);
			toolScroll.set_tooltip_text ("Scroll: Move your view of the timing diagram with click and drag.");
			toolScroll.clicked.connect (() => {mouseMode = MouseMode.SCROLL;});
			
			toolZoomImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/zoom.png");
			toolZoom = new Gtk.RadioToolButton.from_widget (toolScroll);
			toolZoom.set_label ("Zoom");
			toolZoom.set_icon_widget (toolZoomImage);
			toolbar.insert (toolZoom, -1);
			toolZoom.set_tooltip_text ("Zoom: Drag downward to stretch vertically, rightward to stretch horizontally.");
			toolZoom.clicked.connect (() => {mouseMode = MouseMode.ZOOM;});
			
			toolSeparator1 = new Gtk.SeparatorToolItem ();
			toolbar.insert (toolSeparator1, -1);
			
			toolMoveImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/move.png");
			toolMove = new Gtk.RadioToolButton.from_widget (toolScroll);
			toolMove.set_label ("Move");
			toolMove.set_icon_widget (toolMoveImage);
			toolbar.insert (toolMove, -1);
			toolMove.set_tooltip_text ("Move: Click and drag a trace to reorder it.");
			toolMove.clicked.connect (() => {mouseMode = MouseMode.MOVE;});
			
			toolDeleteImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/delete.png");
			toolDelete = new Gtk.RadioToolButton.from_widget (toolScroll);
			toolDelete.set_label ("Delete");
			toolDelete.set_icon_widget (toolDeleteImage);
			toolbar.insert (toolDelete, -1);
			toolDelete.set_tooltip_text ("Delete: Click on a trace to delete it.");
			toolDelete.clicked.connect (() => {mouseMode = MouseMode.DELETE;});
			
			toolAdjustImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/adjust.png");
			toolAdjust = new Gtk.RadioToolButton.from_widget (toolScroll);
			toolAdjust.set_label ("Adjust");
			toolAdjust.set_icon_widget (toolAdjustImage);
			toolbar.insert (toolAdjust, -1);
			toolAdjust.set_tooltip_text ("Adjust: Click on a trace to change its properties.");
			toolAdjust.clicked.connect (() => {mouseMode = MouseMode.ADJUST;});
			
		//Display Area
		
		controller = new Gtk.EventBox ();
		vBox.pack_start (controller, true, true, 0);
		controller.button_press_event.connect (mouse_down);
		controller.set_events (Gdk.EventMask.POINTER_MOTION_MASK);
		controller.motion_notify_event.connect (mouse_move);
		controller.button_release_event.connect (mouse_up);
		
		display = new Gtk.DrawingArea ();
		controller.add (display);
		// display.expose_event.connect (() => {render(true); return false;});
		display.draw.connect ((context) => {render(true, context); return false;});
		display.configure_event.connect (() => {diagramCache = null; render(true); return false;});
		
		show_all ();
		hide ();
		
		render ();
	}
	
	public void close_diagram () {
		destroy ();
	}
	
	public bool hide_diagram () {
		hide ();
		return true;
	}
	
	public void show_diagram () {
		show_all ();
		present ();
		set_keep_above (menuViewAlwaysontop.active);
		render (true);
	}
	
	public void add_wire (WireState newWireState) {
		foreach (WireState wireState in wireStates) {
			if (wireState == newWireState) {
				return;
			}
		}
		
		PropertySet propertySet = new PropertySet ("Watch Wire", "Record this wire in the timing diagram.");
		PropertyItemString labelProperty = new PropertyItemString ("Label", "Display this text next to the graph.", "");
		propertySet.add_item (labelProperty);
		
		PropertiesQuery propertiesQuery = new PropertiesQuery ("Watch Wire", this, propertySet);
		
		set_keep_above (false);
		
		if (propertiesQuery.run() == Gtk.ResponseType.APPLY) {
			string label = labelProperty.data;
			
			wireStates += newWireState;
			
			if (label == "") {
				labels += "Wire " + wireStates.length.to_string();
			} else {
				labels += label;
			}
			
			newWireState.start_recording (compiledCircuit.iterationCount - iterationCountOffset);
			
			diagramCache = null;
			render (true);
		}
		
		set_keep_above (alwaysOnTop);
	}
	
	private void forget_wire (int wireNumber) {
		WireState[] newWireStates = {};
		string[] newLabels = {};
		
		for (int i = 0; i < wireStates.length; i++) {
			if (i != wireNumber) {
				newWireStates += wireStates[i];
				newLabels += labels[i];
			} else {
				wireStates[i].stop_recording ();
			}
		}
		
		wireStates = newWireStates;
		labels = newLabels;
	}
	
	private void move_wire (int fromNumber, int toNumber) {
		if (0 <= fromNumber && fromNumber < wireStates.length &&
			0 <= toNumber && toNumber < wireStates.length) {
				WireState[] newWireStates = {};
				string[] newLabels = {};
				
				WireState movingWire = wireStates[fromNumber];
				string movingLabel = labels[fromNumber];
				
				int insertCount = 0;
				
				for (int i = 0; i < wireStates.length; i++) {
					if (insertCount == toNumber) {
						newWireStates += movingWire;
						newLabels += movingLabel;
						insertCount++;
					}
					if (i != fromNumber) {
						newWireStates += wireStates[i];
						newLabels += labels[i];
						insertCount++;
					}
				}
				if (insertCount == toNumber) {
					newWireStates += movingWire;
					newLabels += movingLabel;
					insertCount++;
				}
				
				wireStates = newWireStates;
				labels = newLabels;
		}
	}
	
	private void adjust_wire (int wireNumber) {
		if (0 <= wireNumber && wireNumber < wireStates.length) {
			PropertySet propertySet = new PropertySet ("Watch Wire", "Record this wire in the timing diagram.");
			PropertyItemString labelProperty = new PropertyItemString ("Label", "Display this text next to the graph.", labels[wireNumber]);
			propertySet.add_item (labelProperty);
			
			PropertiesQuery propertiesQuery = new PropertiesQuery ("Watch Wire", this, propertySet);
			
			set_keep_above (false);
			
			if (propertiesQuery.run() == Gtk.ResponseType.APPLY) {
				string label = labelProperty.data;
				
				if (label == "") {
					labels[wireNumber] = "Wire " + (wireNumber + 1).to_string();
				} else {
					labels[wireNumber] = label;
				}
				
				diagramCache = null;
				render (true);
			}
			
			set_keep_above (alwaysOnTop);
		}
	}
	
	public void reset_timings () {
		foreach (WireState wireState in wireStates) {
			wireState.start_recording (0);
		}
		
		xView = 0;
		iterationCountOffset = compiledCircuit.iterationCount;
		
		diagramCache = null;
		render (true);
	}
	
	public void reset_view () {
		xView = 0;
		yView = 0;
		xZoom = 1;
		yZoom = 25;
		
		diagramCache = null;
		render (true);
	}
	
	/**
	 * Handles mouse button down in the work area. Records mouse
	 * (drag) starting point.
	 */
	private bool mouse_down (Gdk.EventButton event) {
		xMouseStart = (int)(event.x);
		yMouseStart = (int)(event.y);
		return false;
	}
	
	private bool mouse_move (Gdk.EventMotion event) {
		if (Gtk.events_pending ()) {
			return false;
		}
		
		barPosition = event.x;
		
		render (false);
		return false;
	}
	
	/**
	 * Handles mouse button up in the work area. Performs an action
	 * which is determined by //mouseMode//.
	 */
	private bool mouse_up (Gdk.EventButton event) {
		Gtk.Allocation areaAllocation;
		controller.get_allocation (out areaAllocation);
		int width = areaAllocation.width;
		int height = areaAllocation.height;
		
//		int xCentre = width / 2;
//		int yCentre = height / 2;
//		int xStart = xMouseStart - xCentre;
//		int yStart = yMouseStart - yCentre;
//		int xEnd = (int)event.x - xCentre;
//		int yEnd = (int)event.y - yCentre;
		int xStart = xMouseStart;
		int yStart = yMouseStart - 20;
		int xEnd = (int)event.x;
		int yEnd = (int)event.y - 20;
		int xDiff = xEnd - xStart;
		int yDiff = yEnd - yStart;
		
//		int xBoardStart = (int)((float)xStart / zoom + (float)xView);
		int wireStart = (int)Math.floorf((float)((float)(yStart + yView) / (yZoom * 2.4)));
//		int xBoardEnd = (int)((float)xEnd / zoom + (float)xView);
		int wireEnd = (int)Math.floorf((float)((float)(yEnd + yView) / (yZoom * 2.4)));
		
//		int xBoardDiff = xBoardEnd - xBoardStart;
//		int yBoardDiff = yBoardEnd - yBoardStart;
		
//		uint button = event.button;
		
		int xDiffAbs = (xDiff > 0) ? xDiff : -xDiff;
		int yDiffAbs = (yDiff > 0) ? yDiff : -yDiff;
//		int xBoardDiffAbs = (xBoardDiff > 0) ? xBoardDiff : -xBoardDiff;
//		int yBoardDiffAbs = (yBoardDiff > 0) ? yBoardDiff : -yBoardDiff;
		
		switch (mouseMode) {
			case MouseMode.SCROLL:
				xView -= (int)((float)xDiff / xZoom);
				yView -= yDiff;
				break;
			case MouseMode.ZOOM:
				if (xDiff > 0) {
					xZoom *= 1.0f + ((float)xDiffAbs / (float)width);
				} else {
					xZoom /= 1.0f + ((float)xDiffAbs / (float)width);
				}
				if (yDiff > 0) {
					yZoom *= 1.0f + ((float)yDiffAbs / (float)height);
				} else {
					yZoom /= 1.0f + ((float)yDiffAbs / (float)height);
				}
				break;
			case MouseMode.MOVE:
				move_wire (wireStart, wireEnd);
				break;
			case MouseMode.DELETE:
				forget_wire (wireEnd);
				break;
			case MouseMode.ADJUST:
				adjust_wire (wireEnd);
				break;
		}
		
		diagramCache = null;
		render (true);
		
		return false;
	}
	
	public int text_length () { 
		int largestLength = 0;
		
		Cairo.TextExtents textExtents;
		Cairo.ImageSurface imageSurface = new Cairo.ImageSurface (Cairo.Format.ARGB32, 0, 0);
		Cairo.Context context = new Cairo.Context (imageSurface);
		
		context.set_font_size (16);
		
		foreach (string label in labels) {
			context.text_extents (label, out textExtents);
			if (largestLength < (int)textExtents.width) {
				largestLength = (int)textExtents.width;
			}
		}
		
		return largestLength;
	}
	
	//Also does horizontal grid
	public void render_labels (Cairo.Context context, bool fullRender, int width, out int largestLength) { 
		largestLength = 0;
		
		Cairo.Matrix oldMatrix;
		Cairo.TextExtents textExtents;
		context.get_matrix (out oldMatrix);
		context.translate (10, yZoom * 1.2 - yView + 20);
		
		foreach (string label in labels) {
			context.set_source_rgb (0, 0, 0);
			context.set_font_size (16);
			context.text_extents (label, out textExtents);
			if (largestLength < (int)textExtents.width) {
				largestLength = (int)textExtents.width;
			}
			if (fullRender) {
				context.show_text (label);
				context.stroke ();
				
				context.set_source_rgba (0, 0, 0, 0.25);
				context.move_to (-10, -yZoom * 1.2);
				context.line_to (width, -yZoom * 1.2);
				context.stroke ();
				
				context.translate (0, yZoom * 2.4);
			}
		}
		
		context.set_matrix (oldMatrix);
	}
	
	public void render_graphs (Cairo.Context context, bool fullRender, int width, int largestLength) {
		Cairo.Matrix oldMatrix;
		context.get_matrix (out oldMatrix);
		
		context.translate (largestLength + 20 - ((float)xView * xZoom), yZoom * 1.2 - yView + 20);
		int xLimit = (int)((float)(width - (largestLength + 20) + xView) / xZoom);
		
		foreach (WireState wireState in wireStates) {
			wireState.render_history (context, xView, xLimit, yZoom, xZoom);
			
			context.translate (0, yZoom * 2.4);
		}
		
		context.set_matrix (oldMatrix);
	}
	
	//Also does vertical grid
	public void render_ruler (Cairo.Context context, bool fullRender, int width, int height, int largestLength) {
		float xLabel;
		int labelValue;
		
		context.set_source_rgb (1, 1, 1);
		context.rectangle (0, 0, width, 20);
		context.fill ();
		context.stroke ();
		
		if (xView < 0) {
			xLabel = largestLength + 20 - (float)xView * xZoom;
			labelValue = 0;
		} else {
			xLabel = largestLength + 20 - (float)(xView % 50) * xZoom;
			labelValue = xView - (xView % 50);
		}
		
		for (; xLabel < width; xLabel += 5 * xZoom, labelValue += 5) {
			if (labelValue % 50 == 0) {
				context.set_source_rgba (0, 0, 0, 1);
				context.move_to (xLabel, 0);
				context.line_to (xLabel, 19);
				context.set_font_size (12);
				context.move_to (xLabel + 2, 16);
				context.show_text (labelValue.to_string());
				context.stroke ();
				
				if (fullRender && showGrid && xLabel >= largestLength + 20) {
					context.set_source_rgba (0, 0, 0, 0.25);
					context.move_to (xLabel, 20);
					context.line_to (xLabel, height);
					context.stroke ();
				}
			} else {
				context.set_source_rgba (0, 0, 0, 0.25);
				context.move_to (xLabel, 5);
				context.line_to (xLabel, 15);
				context.stroke ();
				
				if (fullRender && showGrid && xLabel >= largestLength + 20) {
					context.set_source_rgba (0, 0, 0, 0.125);
					context.move_to (xLabel, 20);
					context.line_to (xLabel, height);
					context.stroke ();
				}
			}
		}
	}
	
	private void render_bar (Cairo.Context context, int height, int largestLength) {
		if (barPosition > largestLength + 20) {
			context.set_source_rgba (0, 0, 0, 0.25);
			context.move_to (barPosition, 0);
			context.line_to (barPosition, height);
			context.stroke ();
		}
	}
	
	public bool render (bool fullRefresh = true, Cairo.Context? passedDisplayContext = null) {
		Cairo.Context displayContext;
		
		if (!visible) {
			return false;
		}
		
		int width, height;
		Gtk.Allocation areaAllocation;
		
		display.get_allocation (out areaAllocation);
		width = areaAllocation.width;
		height = areaAllocation.height;
		
		if (passedDisplayContext == null) {
			displayContext = Gdk.cairo_create (display.get_window());
		} else {
			displayContext = passedDisplayContext;
		}
		// Cairo.Context displayContext = Gdk.cairo_create (display.window);
		
//		Cairo.Matrix oldMatrix;
		
		int largestLength;
		
		if (largestLengthCache == 0) {
			fullRefresh = true;
		}
		
		if (fullRefresh || offScreenSurface == null) {
			Cairo.Surface offScreenSurface = new Cairo.Surface.similar (displayContext.get_target(), displayContext.get_target().get_content(), width, height);
			
			Cairo.Context context = new Cairo.Context (offScreenSurface);
			
			context.set_source_rgb (1, 1, 1);
			context.paint ();
			
			if (diagramCache == null) {
				diagramCache = new Cairo.Surface.similar (context.get_target(), Cairo.Content.COLOR_ALPHA, width, height);
				Cairo.Context cacheContext = new Cairo.Context (diagramCache);
				
				cacheContext.set_operator (Cairo.Operator.SOURCE);
				cacheContext.set_source_rgba (0, 0, 0, 0);
				cacheContext.paint ();
				cacheContext.set_operator (Cairo.Operator.OVER);
				
				render_labels (cacheContext, true, width, out largestLength);
				render_ruler (cacheContext, true, width, height, largestLength);
				
				largestLengthCache = largestLength;
			} else {
				largestLength = largestLengthCache;
			}
			
			render_graphs (context, true, width, largestLength);
			render_bar (context, height, largestLength);
			
			context.set_source_surface (diagramCache, 0, 0);
			context.paint ();
			
			displayContext.set_source_surface (offScreenSurface, 0, 0);
			displayContext.paint ();
		} else {
			Cairo.Context context = new Cairo.Context (offScreenSurface);
			
			context.set_source_rgb (1, 1, 1);
			context.paint ();
			
			if (diagramCache == null) {
				diagramCache = new Cairo.Surface.similar (context.get_target(), Cairo.Content.COLOR_ALPHA, width, height);
				Cairo.Context cacheContext = new Cairo.Context (diagramCache);
				
				cacheContext.set_operator (Cairo.Operator.SOURCE);
				cacheContext.set_source_rgba (0, 0, 0, 0);
				cacheContext.paint ();
				cacheContext.set_operator (Cairo.Operator.OVER);
				
				render_labels (cacheContext, false, width, out largestLength);
				render_ruler (cacheContext, false, width, height, largestLength);
				
				largestLengthCache = largestLength;
			} else {
				largestLength = largestLengthCache;
			}
			
			render_graphs (context, false, width, largestLength);
			render_bar (context, height, largestLength);
			
			context.set_source_surface (diagramCache, 0, 0);
			context.paint ();
			
			displayContext.set_source_surface (offScreenSurface, 0, 0);
			displayContext.paint ();
		}
		
		return false;
	}
	
	public void export_png () {
		ImageExporter.export_png (file_render);
	}
	
	public void export_pdf () {
		ImageExporter.export_pdf (file_render);
	}
	
	public void export_svg () {
		ImageExporter.export_svg (file_render);
	}
	
	/**
	 * Passed to ImageExporter as a delegate and called by an export
	 * function to render to a file.
	 */
	private void file_render (string filename, ImageExporter.ImageFormat imageFormat, double resolution) {
		Cairo.Surface surface;
		int duration = (compiledCircuit.iterationCount - iterationCountOffset);
		int width, height;
		width = (int)((float)(duration - xView) * xZoom) + text_length() + 21;
		height = (int)((float)(wireStates.length) * (yZoom * 2.4)) - yView + 21;
		
		int imageWidth = (int)((double)width * resolution);
		int imageHeight = (int)((double)height * resolution);
		double imageXZoom = xZoom * resolution;
		double imageYZoom = yZoom * resolution / 25;
		
		switch (imageFormat) {
			case ImageExporter.ImageFormat.PNG_RGB:
				surface = new Cairo.ImageSurface (Cairo.Format.RGB24, imageWidth, imageHeight);
				break;
			case ImageExporter.ImageFormat.PNG_ARGB:
				surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, imageWidth, imageHeight);
				break;
			case ImageExporter.ImageFormat.PDF:
				surface = new Cairo.PdfSurface (filename, imageWidth, imageHeight);
				break;
			case ImageExporter.ImageFormat.SVG:
			case ImageExporter.ImageFormat.SVG_CLEAR:
				surface = new Cairo.SvgSurface (filename, imageWidth, imageHeight);
				break;
			default:
				stderr.printf ("Error: Unknown Export Format!\n");
				return;
		}
		
		Cairo.Context context = new Cairo.Context (surface);
		
		switch (imageFormat) {
			case ImageExporter.ImageFormat.PNG_ARGB:
			case ImageExporter.ImageFormat.SVG_CLEAR:
				context.set_operator (Cairo.Operator.SOURCE);
				context.set_source_rgba (0, 0, 0, 0);
				context.paint ();
				context.set_operator (Cairo.Operator.OVER);
				break;
			default:
				context.set_source_rgb (1, 1, 1);
				context.paint ();
				break;
		}
		
		context.scale (imageXZoom, imageYZoom);
		
		context.set_line_width (1);
		
		stdout.printf ("Exporting timing diagram (render size = %i x %i, scale = %f x %f)\n", imageWidth, imageHeight, imageXZoom, imageYZoom);
		
		int largestLength;
		render_labels (context, true, width, out largestLength);
		render_graphs (context, true, width, largestLength);
		render_ruler (context, true, width, height, largestLength);
		
		switch (imageFormat) {
			case ImageExporter.ImageFormat.PNG_RGB:
			case ImageExporter.ImageFormat.PNG_ARGB:
				surface.write_to_png (filename);
				break;
		}
	}
}
