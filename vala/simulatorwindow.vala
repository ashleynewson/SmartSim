/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: simulatorwindow.vala
 *   
 *   Copyright Ashley Newson 2012
 */


/**
 * Interface for the user when running a circuit.
 * 
 * Allows a user to control and explore a circuit, using the
 * CompiledCircuit as a back-end.
 */
public class SimulatorWindow : Gtk.Window {
	private Gtk.Box vBox;
	private Gtk.MenuBar menubar;
		private Gtk.MenuItem menuSimulation;
			private Gtk.Menu menuSimulationMenu;
			private Gtk.CheckMenuItem menuSimulationRun;
			private Gtk.MenuItem menuSimulationSeparator1;
			private Gtk.MenuItem menuSimulationExit;
		private Gtk.MenuItem menuView;
			private Gtk.Menu menuViewMenu;
			private Gtk.MenuItem menuViewFitdesign;
			private Gtk.CheckMenuItem menuViewAutofitdesign;
			private Gtk.MenuItem menuViewSeparator1;
			private Gtk.MenuItem menuViewTimingdiagram;
	private Gtk.Toolbar toolbar;
		private Gtk.RadioToolButton toolScroll;
			private Gtk.Image toolScrollImage;
		private Gtk.RadioToolButton toolZoom;
			private Gtk.Image toolZoomImage;
		private Gtk.SeparatorToolItem toolSeparator1;
		private Gtk.RadioToolButton toolContext;
			private Gtk.Image toolContextImage;
		private Gtk.RadioToolButton toolInteract;
			private Gtk.Image toolInteractImage;
		private Gtk.RadioToolButton toolExplore;
			private Gtk.Image toolExploreImage;
		private Gtk.RadioToolButton toolWatch;
			private Gtk.Image toolWatchImage;
		private Gtk.SeparatorToolItem toolSeparator2;
		private Gtk.ToolButton toolShrink;
			private Gtk.Image toolShrinkImage;
		private Gtk.SeparatorToolItem toolSeparator3;
		private Gtk.ToggleToolButton toolRun;
			private Gtk.Image toolRunImage;
		private Gtk.ToolButton toolSinglestep;
			private Gtk.Image toolSinglestepImage;
		private Gtk.ToolButton toolMultistep;
			private Gtk.Image toolMultistepImage;
		private Gtk.SeparatorToolItem toolSeparator4;
		private Gtk.ToggleToolButton toolMaxspeed;
			private Gtk.Image toolMaxspeedImage;
		private Gtk.ToolItem toolSpeed;
			private Gtk.Box toolSpeedBox;
				private Gtk.Label toolSpeedLabel;
				private Gtk.SpinButton toolSpeedSpin;
		private Gtk.SeparatorToolItem toolSeparator5;
		private Gtk.ToolItem toolStepsize;
			private Gtk.Box toolStepsizeBox;
				private Gtk.Label toolStepsizeLabel;
				private Gtk.SpinButton toolStepsizeSpin;
//		private Gtk.ToolButton toolTiming;
//			private Gtk.Image toolTimingImage;
	private Gtk.EventBox controller;
	private Gtk.DrawingArea display;
	
	/**
	 * The CompiledCircuit which the SimulatorWindow is acting as the
	 * front-end for.
	 */
	private CompiledCircuit compiledCircuit;
	
	/**
	 * Actions to perform when the mouse button is released.
	 */
	private enum MouseMode {
		SCROLL,
		ZOOM,
		CONTEXT,
		INTERACT,
		EXPLORE,
		WATCH
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
	private MouseMode mouseMode = MouseMode.CONTEXT;
	
	/**
	 * The size of a grid square. Affects snapping as well as the
	 * displayed grid.
	 */
	public int gridSize = 5;
	
	/**
	 * Where the user's view is centred around (x).
	 */
	private int xView = 0;
	/**
	 * Where the user's view is centred around (y).
	 */
	private int yView = 0;
	/**
	 * Magnification of the display.
	 */
	public float zoom = 1;
	
	/**
	 * The states the simulation can be in. (e.g. running, paused...)
	 */
	public enum RunState {
		PAUSED,
		STEPPING,
		RUNNING,
		HALTING,
		ERROR
	}
	
	/**
	 * Specifies the current state of the simulation.
	 */
	private RunState runState;
	
	/**
	 * Milliseconds between simulation updates.
	 */
	private int cycleDelay = 0;
	
	private int multistepSize = 50;
	
	private int stepsLeft = 0;
	
	private uint cycleSourceID = 0;
	private uint refreshSourceID = 0;
	
	/**
	 * Microseconds between simulation updates.
	 */
	private int microCycleDelay = 0;
	
	/**
	 * The simulation time to go before re-rendering the display.
	 */
	private double timeBeforeRender;
	
	private bool inhibitRender = false;
	
	private bool autoFitDesign = true;
	
	
	
	TimingDiagram timingDiagram;
	
	
	
	/**
	 * Creates a new Simulator window associated with the
	 * CompiledCircuit //compiledCircuit//.
	 */
	public SimulatorWindow (CompiledCircuit compiledCircuit) {
		this.compiledCircuit = compiledCircuit;
		runState = RunState.PAUSED;
		populate ();
	}
	
	~SimulatorWindow () {
		timingDiagram.close_diagram ();
	}
	
	/**
	 * Populate the window with widgets.
	 */
	public void populate () {
		stdout.printf ("Simulation Window Created\n");
		
		set_default_size (800, 600);
		set_border_width (0);
		destroy.connect (close_simulation);
		set_title (Core.programName + " - Simulation");
		
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
			
			menuSimulation = new Gtk.MenuItem.with_label ("Simulation");
			menubar.append (menuSimulation);
			menuSimulationMenu = new Gtk.Menu ();
			menuSimulation.set_submenu (menuSimulationMenu);
				
				menuSimulationRun = new Gtk.CheckMenuItem.with_label ("Run");
				menuSimulationMenu.append (menuSimulationRun);
				menuSimulationRun.toggled.connect (() => {run_toggle(menuSimulationRun);});
				
				menuSimulationSeparator1 = new Gtk.SeparatorMenuItem ();
				menuSimulationMenu.append (menuSimulationSeparator1);
				
				menuSimulationExit = new Gtk.MenuItem.with_label ("Close Simulation");
				menuSimulationMenu.append (menuSimulationExit);
				menuSimulationExit.activate.connect (() => {destroy();});
				
			menuView = new Gtk.MenuItem.with_label ("View");
			menubar.append (menuView);
			menuViewMenu = new Gtk.Menu ();
			menuView.set_submenu (menuViewMenu);
				
				menuViewFitdesign = new Gtk.MenuItem.with_label ("Fit Design to Display");
				menuViewMenu.append (menuViewFitdesign);
				menuViewFitdesign.activate.connect (() => {fit_design();});
				
				menuViewAutofitdesign = new Gtk.CheckMenuItem.with_label ("Auto Fit When Exploring");
				menuViewMenu.append (menuViewAutofitdesign);
				menuViewAutofitdesign.active = true;
				menuViewAutofitdesign.toggled.connect ((menuItem) => {autoFitDesign = menuItem.active;});
				
				menuViewSeparator1 = new Gtk.SeparatorMenuItem ();
				menuViewMenu.append (menuViewSeparator1);
				
				menuViewTimingdiagram = new Gtk.MenuItem.with_label ("Show Timing Diagram");
				menuViewMenu.append (menuViewTimingdiagram);
				menuViewTimingdiagram.activate.connect (() => {show_timing_diagram();});
				
		//Toolbar
		
		toolbar = new Gtk.Toolbar ();
		toolbar.toolbar_style = Gtk.ToolbarStyle.ICONS;
		vBox.pack_start (toolbar, false, true, 0);
			
			toolScrollImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/scroll.png");
			toolScroll = new Gtk.RadioToolButton (null);
			toolScroll.set_label ("Scroll");
			toolScroll.set_icon_widget (toolScrollImage);
			toolbar.insert (toolScroll, -1);
			toolScroll.set_tooltip_text ("Scroll: Move your view of the circuit with click and drag.");
			toolScroll.clicked.connect (() => {mouseMode = MouseMode.SCROLL;});
			
			toolZoomImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/zoom.png");
			toolZoom = new Gtk.RadioToolButton.from_widget (toolScroll);
			toolZoom.set_label ("Zoom");
			toolZoom.set_icon_widget (toolZoomImage);
			toolbar.insert (toolZoom, -1);
			toolZoom.set_tooltip_text ("Zoom: Drag downward to zoom in or upward to zoom out.");
			toolZoom.clicked.connect (() => {mouseMode = MouseMode.ZOOM;});
			
			toolSeparator1 = new Gtk.SeparatorToolItem ();
			toolbar.insert (toolSeparator1, -1);
			
			toolContextImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/context.png");
			toolContext = new Gtk.RadioToolButton.from_widget (toolScroll);
			toolContext.set_label ("Context");
			toolContext.set_icon_widget (toolContextImage);
			toolbar.insert (toolContext, -1);
			toolContext.set_tooltip_text ("Context: Interact or explore depending on what you click on. See Interact and Explore tools.");
			toolContext.clicked.connect (() => {mouseMode = MouseMode.CONTEXT;});
			toolContext.active = true;
			
			toolInteractImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/interact.png");
			toolInteract = new Gtk.RadioToolButton.from_widget (toolScroll);
			toolInteract.set_label ("Interact");
			toolInteract.set_icon_widget (toolInteractImage);
			toolbar.insert (toolInteract, -1);
			toolInteract.set_tooltip_text ("Interact: Click on an interactive component to interact with it.");
			toolInteract.clicked.connect (() => {mouseMode = MouseMode.INTERACT;});
			
			toolExploreImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/explore.png");
			toolExplore = new Gtk.RadioToolButton.from_widget (toolScroll);
			toolExplore.set_label ("Explore");
			toolExplore.set_icon_widget (toolExploreImage);
			toolbar.insert (toolExplore, -1);
			toolExplore.set_tooltip_text ("Explore: Click on sub components to expand them and look at the activity inside them. Click on the background (or use the shrink tool) to go back to the higher level.");
			toolExplore.clicked.connect (() => {mouseMode = MouseMode.EXPLORE;});
			
			toolWatchImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/watch.png");
			toolWatch = new Gtk.RadioToolButton.from_widget (toolScroll);
			toolWatch.set_label ("Watch");
			toolWatch.set_icon_widget (toolWatchImage);
			toolbar.insert (toolWatch, -1);
			toolWatch.set_tooltip_text ("Watch: Click on a wire to add it to the logic timing diagram.");
			toolWatch.clicked.connect (() => {mouseMode = MouseMode.WATCH;});
			
			toolSeparator2 = new Gtk.SeparatorToolItem ();
			toolbar.insert (toolSeparator2, -1);
			
			toolShrinkImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/shrink.png");
			toolShrink = new Gtk.ToolButton (toolShrinkImage, "Shrink");
			toolbar.insert (toolShrink, -1);
			toolShrink.set_tooltip_text ("Shrink: Explore the immediately higher level component (the component containing the currently viewed one).");
			toolShrink.clicked.connect (() => {
				compiledCircuit.shrink_component();
				if (autoFitDesign) {
					fit_design ();
				}
				render (true);
			});
			
			toolSeparator3 = new Gtk.SeparatorToolItem ();
			toolbar.insert (toolSeparator3, -1);
			
			toolRunImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/run.png");
			toolRun = new Gtk.ToggleToolButton ();
			toolRun.set_label ("Run");
			toolRun.set_icon_widget (toolRunImage);
			toolbar.insert (toolRun, -1);
			toolRun.set_tooltip_text ("Run: Toggle between a running and paused simulation.");
			toolRun.toggled.connect (() => {run_toggle(toolRun);});
			
			toolSinglestepImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/singlestep.png");
			toolSinglestep = new Gtk.ToolButton (toolSinglestepImage, "Single Step");
			toolbar.insert (toolSinglestep, -1);
			toolSinglestep.set_tooltip_text ("Single Step: Step through the simulation a single iteration at a time.");
			toolSinglestep.clicked.connect (() => {step(false);});
			
			toolMultistepImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/multistep.png");
			toolMultistep = new Gtk.ToolButton (toolMultistepImage, "Multi Step");
			toolbar.insert (toolMultistep, -1);
			toolMultistep.set_tooltip_text ("Multi Step: Step through the simulation by a specified number of iterations.");
			toolMultistep.clicked.connect (() => {step(true);});
			
/*			toolTimingImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/cycledelay.png");
			toolTiming = new Gtk.ToolButton (toolTimingImage, "Timing");
			toolbar.insert (toolTiming, -1);
			toolTiming.set_tooltip_text ("Timing: Change the simulation speed and multi step size.");
			toolTiming.clicked.connect (change_timing);*/
			
			toolSeparator4 = new Gtk.SeparatorToolItem ();
			toolbar.insert (toolSeparator4, -1);
			
			toolSpeed = new Gtk.ToolItem ();
			toolbar.insert (toolSpeed, -1);
				toolSpeedBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
				toolSpeed.add (toolSpeedBox);
					toolSpeedLabel = new Gtk.Label ("Speed (Hz):");
					toolSpeedBox.pack_start (toolSpeedLabel, false, true, 0);
					toolSpeedSpin = new Gtk.SpinButton.with_range (0.1, 1000.0, 1.0);
					toolSpeedBox.pack_start (toolSpeedSpin, false, true, 0);
					toolSpeedSpin.set_value (50.0);
					toolSpeedSpin.set_snap_to_ticks (false);
					toolSpeedSpin.set_digits (1);
					toolSpeedSpin.value_changed.connect (() => {
						if (!toolMaxspeed.active) {
							change_speed ((int)(1000.0 / toolSpeedSpin.get_value()));
						}
					});
					toolSpeedSpin.set_sensitive (false);
			
			toolMaxspeedImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/fastest.png");
			toolMaxspeed = new Gtk.ToggleToolButton ();
			toolMaxspeed.set_label ("Maximum Speed");
			toolMaxspeed.set_icon_widget (toolMaxspeedImage);
			toolbar.insert (toolMaxspeed, -1);
			toolMaxspeed.set_tooltip_text ("Maximum Speed: Toggle between running as fast as possible and running at a specified speed.");
			toolMaxspeed.active = true;
			toolMaxspeed.toggled.connect (() => {
				if (toolMaxspeed.active) {
					toolSpeedSpin.set_sensitive (false);
					change_speed (0);
				} else {
					toolSpeedSpin.set_sensitive (true);
					change_speed ((int)(1000.0 / toolSpeedSpin.get_value()));
				}
			});
			
			toolSeparator5 = new Gtk.SeparatorToolItem ();
			toolbar.insert (toolSeparator5, -1);
			
			toolStepsize = new Gtk.ToolItem ();
			toolbar.insert (toolStepsize, -1);
				toolStepsizeBox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
				toolStepsize.add (toolStepsizeBox);
					toolStepsizeLabel = new Gtk.Label ("Multi Step:");
					toolStepsizeBox.pack_start (toolStepsizeLabel, false, true, 0);
					toolStepsizeSpin = new Gtk.SpinButton.with_range (1, 1000000, 1.0);
					toolStepsizeBox.pack_start (toolStepsizeSpin, false, true, 0);
					toolStepsizeSpin.set_value (50.0);
					toolStepsizeSpin.value_changed.connect (() => {multistepSize = toolStepsizeSpin.get_value_as_int();});
			
		controller = new Gtk.EventBox ();
		vBox.pack_start (controller, true, true, 0);
		controller.button_press_event.connect (mouse_down);
		controller.button_release_event.connect (mouse_up);
		
		display = new Gtk.DrawingArea ();
		controller.add (display);
		// display.expose_event.connect (() => {render(true); return false;});
		display.draw.connect ((context) => {render(true, false, context); return false;});
		
		show_all ();
		
		timingDiagram = new TimingDiagram (compiledCircuit);
	}
	
	/*
	 * Handles a click on toolTiming. Prompts the user to change the
	 * speed of the simulation.
	 */
/*	private void change_timing () {
		PropertySet propertySet = new PropertySet ("Timing", "Set the speed of the simulation");
		
		propertySet.add_item (new PropertyItemInt("Cycle Delay", "Set the millisecond interval between circuit steps", cycleDelay));
		propertySet.add_item (new PropertyItemInt("Multistep Size", "Number circuit updates per multistep", multistepSize));
		
		PropertiesQuery propertiesQuery = new PropertiesQuery (null, this, propertySet);
		
		bool running = (runState == RunState.RUNNING);
		
		pause ();
		
		timingDiagram.set_keep_above (false);
		
		if (propertiesQuery.run () == Gtk.ResponseType.APPLY) {
			cycleDelay = PropertyItemInt.get_data (propertySet, "Cycle Delay");
			multistepSize = PropertyItemInt.get_data (propertySet, "Multistep Size");
		}
		
		timingDiagram.set_keep_above (timingDiagram.alwaysOnTop);
		
		if (running) {
			run ();
		}
		
		if (cycleDelay < 0) {
			cycleDelay = 0;
		} else if (cycleDelay > 5000) {
			cycleDelay = 5000;
		}
		
		microCycleDelay = cycleDelay * 1000;
	}*/
	
	private void change_speed (int newCycleDelay) {
		bool running = (runState == RunState.RUNNING);
		
		pause ();
		
		cycleDelay = newCycleDelay;
		
		if (running) {
			run ();
		}
		
		if (cycleDelay < 0) {
			cycleDelay = 0;
		} else if (cycleDelay > 10000) {
			cycleDelay = 10000;
		}
		
		microCycleDelay = cycleDelay * 1000;
	}
	
	/**
	 * Toggles whether the simulation is running or paused. Does nothing
	 * if the circuit is in the ERROR state.
	 */
	private void run_toggle (Gtk.Widget widget) {
		bool doRun = false;
		
		if (widget == menuSimulationRun) {
			doRun = menuSimulationRun.active;
		} else if (widget == toolRun) {
			doRun = toolRun.active;
		}
		
		if (doRun) {
			run ();
		} else {
			pause ();
		}
	}
	
	private void step (bool multistep) {
		stepsLeft = multistep ? multistepSize : 1;
		
		run ();
		
		runState = RunState.STEPPING;
	}
	
	/**
	 * Sets the simulation state to running. Does nothing if the circuit
	 * is in the ERROR state.
	 */
	public void run () {
		if (runState == RunState.ERROR) {
			return;
		}
		
		if (runState != RunState.RUNNING) {
			int refreshDelay;
			
			if (cycleDelay > 100) {
				refreshDelay = cycleDelay;
			} else {
				refreshDelay = 100;
			}
			
			if (cycleSourceID != 0) {
				Source.remove (cycleSourceID);
			}
			if (refreshSourceID != 0) {
				Source.remove (refreshSourceID);
			}
			
			cycleSourceID = Timeout.add (cycleDelay, update_cycle, Priority.DEFAULT_IDLE);
			refreshSourceID = Timeout.add (refreshDelay, refresh_cycle, Priority.DEFAULT);
		}
		runState = RunState.RUNNING;
		menuSimulationRun.active = true;
		toolRun.active = true;
		
		timeBeforeRender = 0;
	}
	
	/**
	 * Sets the simulation state to paused. Does nothing if the circuit
	 * is in the ERROR state.
	 */
	public void pause () {
		if (runState == RunState.ERROR) {
			return;
		}
		
		if (cycleSourceID != 0) {
			Source.remove (cycleSourceID);
			cycleSourceID = 0;
		}
		if (refreshSourceID != 0) {
			Source.remove (refreshSourceID);
			refreshSourceID = 0;
		}
		
		runState = RunState.PAUSED;
		menuSimulationRun.active = false;
		toolRun.active = false;
		
		render (true);
		timingDiagram.render (true);
	}
	
	private void show_timing_diagram () {
		timingDiagram.show_diagram ();
	}
	
	private void fit_design () {
		Gtk.Allocation areaAllocation;
		controller.get_allocation (out areaAllocation);
		int width = areaAllocation.width;
		int height = areaAllocation.height;
		
		int rightBound;
		int downBound;
		int leftBound;
		int upBound;
		
		int boundWidth;
		int boundHeight;
		
		float altZoom;
		
		compiledCircuit.viewedComponent.get_design_bounds (out rightBound, out downBound, out leftBound, out upBound);
		
		if (rightBound == leftBound || downBound == upBound) {
			return;
		}
		
		rightBound += 10;
		downBound += 10;
		leftBound -= 10;
		upBound -= 10;
		
		xView = (rightBound + leftBound) / 2;
		yView = (downBound + upBound) / 2;
		
		boundWidth = rightBound - leftBound;
		boundHeight = downBound - upBound;
		
		zoom = (float)width / (float)boundWidth;
		altZoom = (float)height / (float)boundHeight;
		
		if (altZoom < zoom) {
			zoom = altZoom;
		}
		
		render (true);
	}
	
	/**
	 * Run periodically using a timer. Updates the display.
	 */
	private bool refresh_cycle () {
		Timer renderingTimer = new Timer ();
		
		if (runState != RunState.HALTING && timeBeforeRender <= 0.0) {
			renderingTimer.start ();
			
			render (false);
			timingDiagram.render (false);
			
			renderingTimer.stop ();
			
			timeBeforeRender = renderingTimer.elapsed ();
		}
		
		if (runState == RunState.RUNNING || runState == RunState.STEPPING) {
			return true;
		} else {
			return false;
		}
	}
	
	/**
	 * Run periodically using a timer. Runs an single iteration of the
	 * simulation.
	 */
	private bool update_cycle () {
		Timer simulationTimer = new Timer ();
		
		simulationTimer.start ();
		
		int result = compiledCircuit.update_cycle ();
		
		simulationTimer.stop ();
		
		if (simulationTimer.elapsed () < microCycleDelay) {
			timeBeforeRender -= (double)microCycleDelay;
		} else {
			timeBeforeRender -= simulationTimer.elapsed ();
		}
		
		if (result == 1) {
			runState = RunState.ERROR;
			render (true);
			
			stdout.printf ("Simulation Error!\n");
			stdout.flush ();
			stderr.printf ("Error Messages:\n%s\n", compiledCircuit.errorMessage);
			
			BasicDialog.error (null, "Circuit Runtime Error:\n" + compiledCircuit.errorMessage);
		}
		
		if (runState == RunState.RUNNING) {
			return true;
		} else if (runState == RunState.STEPPING) {
			stepsLeft --;
			if (stepsLeft <= 0) {
				pause ();
				return false;
			} else {
				return true;
			}
		} else {
			return false;
		}
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
	
	/**
	 * Handles mouse button up in the work area. Performs an action
	 * which is determined by //mouseMode//.
	 */
	private bool mouse_up (Gdk.EventButton event) {
		Gtk.Allocation areaAllocation;
		controller.get_allocation (out areaAllocation);
		int width = areaAllocation.width;
		int height = areaAllocation.height;
		
		int xCentre = width / 2;
		int yCentre = height / 2;
		int xStart = xMouseStart - xCentre;
		int yStart = yMouseStart - yCentre;
		int xEnd = (int)event.x - xCentre;
		int yEnd = (int)event.y - yCentre;
//		int xDiff = xEnd - xStart;
		int yDiff = yEnd - yStart;
		
		int xBoardStart = (int)((float)xStart / zoom + (float)xView);
		int yBoardStart = (int)((float)yStart / zoom + (float)yView);
		int xBoardEnd = (int)((float)xEnd / zoom + (float)xView);
		int yBoardEnd = (int)((float)yEnd / zoom + (float)yView);
		
		bool snapGridStart = true;
		bool snapGridEnd = true;
		
		int halfGridSize = gridSize / 2;
		
		if (snapGridStart) {
			xBoardStart += (xBoardStart > 0) ? halfGridSize : -halfGridSize;
			yBoardStart += (yBoardStart > 0) ? halfGridSize : -halfGridSize;
			xBoardStart = (xBoardStart / gridSize) * gridSize;
			yBoardStart = (yBoardStart / gridSize) * gridSize;
		}
		if (snapGridEnd) {
			xBoardEnd += (xBoardEnd > 0) ? halfGridSize : -halfGridSize;
			yBoardEnd += (yBoardEnd > 0) ? halfGridSize : -halfGridSize;
			xBoardEnd = (xBoardEnd / gridSize) * gridSize;
			yBoardEnd = (yBoardEnd / gridSize) * gridSize;
		}
		
		int xBoardDiff = xBoardEnd - xBoardStart;
		int yBoardDiff = yBoardEnd - yBoardStart;
		
//		uint button = event.button;
		
//		int xDiffAbs = (xDiff > 0) ? xDiff : -xDiff;
		int yDiffAbs = (yDiff > 0) ? yDiff : -yDiff;
//		int xBoardDiffAbs = (xBoardDiff > 0) ? xBoardDiff : -xBoardDiff;
//		int yBoardDiffAbs = (yBoardDiff > 0) ? yBoardDiff : -yBoardDiff;
		
		switch (mouseMode) {
			case MouseMode.SCROLL:
				xView -= xBoardDiff;
				yView -= yBoardDiff;
				render (true);
				break;
			case MouseMode.ZOOM:
				if (yDiff > 0) {
					zoom *= 1.0f + ((float)yDiffAbs / (float)height);
				} else {
					zoom /= 1.0f + ((float)yDiffAbs / (float)height);
				}
				render (true);
				break;
			case MouseMode.INTERACT:
				compiledCircuit.interact_components (xBoardEnd, yBoardEnd);
				render (true, true);
				break;
			case MouseMode.CONTEXT:
				int result = compiledCircuit.expand_component(xBoardEnd, yBoardEnd);
				
				switch (result) {
					case 0: //Expand
						if (autoFitDesign) {
							fit_design ();
						}
						render (true);
						break;
					case 1: //Shrink
						compiledCircuit.shrink_component();
						if (autoFitDesign) {
							fit_design ();
						}
						render (true);
						break;
					case 2: //No Action happened, so interact
						compiledCircuit.interact_components (xBoardEnd, yBoardEnd);
						render (true, true);
						break;
				}
				break;
			case MouseMode.EXPLORE:
				int result = compiledCircuit.expand_component(xBoardEnd, yBoardEnd);
				
				switch (result) {
					case 0: //Expand
						if (autoFitDesign) {
							fit_design ();
						}
						render (true);
						break;
					case 1: //Shrink
						compiledCircuit.shrink_component();
						if (autoFitDesign) {
							fit_design ();
						}
						render (true);
						break;
					case 2: //No Action
						break;
				}
				break;
			case MouseMode.WATCH:
				WireState wireState = compiledCircuit.find_wire(xBoardEnd, yBoardEnd);
				
				if (wireState != null) {
//					PropertySet propertySet = new PropertySet ("Watch Wire", "Record this wire in the timing diagram.");
//					PropertyItemString labelProperty = new PropertyItemString ("Label", "Display this text next to the graph.", "");
//					propertySet.add_item (labelProperty);
					
//					PropertiesQuery propertiesQuery = new PropertiesQuery ("Watch Wire", this, propertySet);
					
//					if (propertiesQuery.run() == Gtk.ResponseType.APPLY) {
//						timingDiagram.add_wire (wireState, labelProperty.data);
//						timingDiagram.render (true);
//					}
					timingDiagram.add_wire (wireState);
				}
				break;
		}
		
		return false;
	}
	
	/**
	 * Renders the currently viewed part of the simulation. If
	 * //fullRefresh// is false, then the circuit design is not redrawn.
	 */
	public bool render (bool fullRefresh = true, bool cancelIfRunning = false, Cairo.Context? passedDisplayContext = null) {
		Cairo.Context displayContext;
		int width, height;
		Gtk.Allocation areaAllocation;
		
		if (cancelIfRunning && runState == RunState.RUNNING) {
			return false;
		}
		
		//If the display will not naturally update, don't update too much.
		if (runState == RunState.PAUSED) {
			if (inhibitRender) {
				return false;
			}
			
			inhibitRender = true;
			
			while (Gtk.events_pending()) {
				Gtk.main_iteration ();
			}
			
			inhibitRender = false;
		}
		
		display.get_allocation (out areaAllocation);
		width = areaAllocation.width;
		height = areaAllocation.height;
		
		if (passedDisplayContext == null) {
			displayContext = Gdk.cairo_create (display.get_window());
		} else {
			displayContext = passedDisplayContext;
		}
		// Cairo.Context displayContext = Gdk.cairo_create (display.window);
		
		if (fullRefresh) {
			Cairo.Surface offScreenSurface = new Cairo.Surface.similar (displayContext.get_target(), displayContext.get_target().get_content(), width, height);
			
			Cairo.Context context = new Cairo.Context (offScreenSurface);
			
			context.set_source_rgb (1, 1, 1);
			context.paint ();
			
//			if (zoom < 1.0) {
//				context.set_line_width (1.0 / zoom);
//			} else {
//				context.set_line_width (1.0);
//			}
			
//			context.set_line_width (1);
			
			context.translate (width / 2, height / 2);
			context.scale (zoom, zoom);
			context.translate (-xView, -yView);
			
			compiledCircuit.render (context, true, zoom);
			
			displayContext.set_source_surface (offScreenSurface, 0, 0);
			displayContext.paint ();
		} else {
//			if (zoom < 1.0) {
//				displayContext.set_line_width (1.0 / zoom);
//			} else {
//				displayContext.set_line_width (1.0);
//			}
			
			displayContext.translate (width / 2, height / 2);
			displayContext.scale (zoom, zoom);
			displayContext.translate (-xView, -yView);
			
			compiledCircuit.render (displayContext, false, zoom);
		}
		
//		fullRefresh = true;
		
		return false;
	}
	
	/**
	 * Ends the simulation. Presenting a summary.
	 */
	public void close_simulation () {
		stdout.printf ("Ending Simulation.\n");
		
		runState = RunState.HALTING;
		
		timingDiagram.destroy ();
		
		BasicDialog.information (null, "Simulation Summary:\nIterations: " + compiledCircuit.iterationCount.to_string());
		
		compiledCircuit.project.running = false;
	}
}
