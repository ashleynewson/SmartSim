/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: designerwindow.vala
 *   
 *   Copyright Ashley Newson 2012
 */


/**
 * The primary interface for the user. Used to design components and
 * navigate through the application.
 */
public class DesignerWindow : Gtk.Window {
	/**
	 * Registration of all visible DesignerWindows.
	 */
	private static DesignerWindow[] designerWindows;
	
	/**
	 * Adds //window// to the list of visible DesignerWindows.
	 */
	public static void register (DesignerWindow window) {
		int position;
		position = designerWindows.length;
		designerWindows += window;
		window.myID = position;
		
		stdout.printf ("Registered designer window %i\n", position);
	}
	
	/**
	 * Removes //window// from the list of visible DesignerWindows.
	 * When there are no more visible windows, the application quits.
	 */
	public static void unregister (DesignerWindow window) {
		DesignerWindow[] tempArray = {};
		int position;
		int newID = 0;
		position = window.myID;
		
		if (position == -1) {
			stdout.printf ("Window already unregistered!\n");
			return;
		}
		
		designerWindows[position].myID = -1;
		for (int i = 0; i < designerWindows.length; i ++) {
			if (i != position) {
				designerWindows[i].myID = newID;
				tempArray += designerWindows[i];
				newID ++;
			}
		}
		
		designerWindows = tempArray;
		
		stdout.printf ("Unregistered designer window %i\n", position);
		
		Project.clean_up ();
		
		if (designerWindows.length == 0) {
			stdout.printf ("No more designer windows! Closing...\n");
			Gtk.main_quit ();
		}
	}
	
	public static bool project_has_windows (Project project) {
		foreach (DesignerWindow designerWindow in designerWindows) {
			if (designerWindow.project == project) {
				return true;
			}
		}
		
		return false;
	}
	
	public static int count_project_windows (Project project) {
		int count = 0;
		
		foreach (DesignerWindow designerWindow in designerWindows) {
			if (designerWindow.project == project) {
				count++;
			}
		}
		
		return count;
	}
	
	
	
	private Gtk.VBox vBox;
	private Gtk.MenuBar menubar;
		private Gtk.MenuItem menuFile;
			private Gtk.Menu menuFileMenu;
			private Gtk.MenuItem menuFileNewproject;
			private Gtk.MenuItem menuFileNewcomponent;
			private Gtk.MenuItem menuFileSeparator1;
			private Gtk.MenuItem menuFileOpen;
			private Gtk.MenuItem menuFileSeparator2;
			private Gtk.MenuItem menuFileSave;
			private Gtk.MenuItem menuFileSaveas;
			private Gtk.MenuItem menuFileSeparator3;
			private Gtk.MenuItem menuFileSaveproject;
			private Gtk.MenuItem menuFileSaveasproject;
			private Gtk.MenuItem menuFileSeparator4;
			private Gtk.MenuItem menuFileOpenproject;
			private Gtk.MenuItem menuFileSeparator5;
//			private Gtk.MenuItem menuFileResumesimulation;
//			private Gtk.MenuItem menuFileSeparator6;
			private Gtk.MenuItem menuFileExport;
				private Gtk.Menu menuFileExportMenu;
				private Gtk.MenuItem menuFileExportPng;
				private Gtk.MenuItem menuFileExportPdf;
				private Gtk.MenuItem menuFileExportSvg;
			private Gtk.MenuItem menuFileSeparator6;
			private Gtk.MenuItem menuFilePagesetup;
			private Gtk.MenuItem menuFilePrint;
			private Gtk.MenuItem menuFileSeparator7;
			private Gtk.MenuItem menuFileRemovecomponent;
			private Gtk.MenuItem menuFileSeparator8;
			private Gtk.MenuItem menuFileExit;
		private Gtk.MenuItem menuView;
			private Gtk.Menu menuViewMenu;
			private Gtk.MenuItem menuViewFitdesign;
			private Gtk.MenuItem menuViewSeparator1;
			private Gtk.CheckMenuItem menuViewShowgrid;
			private Gtk.CheckMenuItem menuViewLivescrollupdate;
			private Gtk.CheckMenuItem menuViewShadowcomponent;
			private Gtk.CheckMenuItem menuViewColourbackgrounds;
			private Gtk.CheckMenuItem menuViewHighlighterrors;
			private Gtk.CheckMenuItem menuViewShowdesignerhints;
		private Gtk.MenuItem menuEdit;
			private Gtk.Menu menuEditMenu;
			private Gtk.CheckMenuItem menuEditAutobind;
		private Gtk.MenuItem menuRun;
			private Gtk.Menu menuRunMenu;
			private Gtk.MenuItem menuRunRun;
//			private Gtk.MenuItem menuRunReplayrecording;
			private Gtk.MenuItem menuRunCheckcircuit;
			private Gtk.MenuItem menuRunSeparator1;
			private Gtk.CheckMenuItem menuRunStartpaused;
//			private Gtk.CheckMenuItem menuRunRecord;
		private Gtk.MenuItem menuProject;
			private Gtk.Menu menuProjectMenu;
			private Gtk.MenuItem menuProjectStatistics;
			private Gtk.MenuItem menuProjectOptions;
		private Gtk.MenuItem menuComponent;
			private Gtk.Menu menuComponentMenu;
			private Gtk.MenuItem menuComponentMakeroot;
			private Gtk.MenuItem menuComponentCustomise;
		private Gtk.MenuItem menuWindows;
			private Gtk.Menu menuWindowsMenu;
			private Gtk.MenuItem[] menuWindowsComponents;
		private Gtk.MenuItem menuHelp;
			private Gtk.Menu menuHelpMenu;
			private Gtk.MenuItem menuHelpAbout;
	private Gtk.RadioToolButton hiddenRadioToolButton;
	private Gtk.Toolbar toolbar;
		private Gtk.RadioToolButton toolScroll;
			private Gtk.Image toolScrollImage;
		private Gtk.RadioToolButton toolZoom;
			private Gtk.Image toolZoomImage;
		private Gtk.SeparatorToolItem toolSeparator1;
		private Gtk.RadioToolButton toolCursor;
			private Gtk.Image toolCursorImage;
		private Gtk.RadioToolButton toolMove;
			private Gtk.Image toolMoveImage;
		private Gtk.RadioToolButton toolOrientate;
			private Gtk.Image toolOrientateImage;
		private Gtk.RadioToolButton toolDelete;
			private Gtk.Image toolDeleteImage;
		private Gtk.RadioToolButton toolAdjust;
			private Gtk.Image toolAdjustImage;
		private Gtk.SeparatorToolItem toolSeparator2;
		private Gtk.RadioToolButton toolAnnotate;
			private Gtk.Image toolAnnotateImage;
//		private Gtk.ToolButton toolWatch;
//			private Gtk.Image toolWatchImage;
		private Gtk.RadioToolButton toolWire;
			private Gtk.Image toolWireImage;
		private Gtk.RadioToolButton toolBind;
			private Gtk.Image toolBindImage;
		private Gtk.RadioToolButton toolTag;
			private Gtk.Image toolTagImage;
		private Gtk.RadioToolButton toolInvert;
			private Gtk.Image toolInvertImage;
		private Gtk.SeparatorToolItem toolSeparator3;
		private Gtk.MenuToolButton toolCustoms;
			private Gtk.Image toolCustomsImage;
			private Gtk.Menu toolCustomsMenu;
			private Gtk.MenuItem[] toolCustomsMenuComponents;
		private Gtk.SeparatorToolItem toolSeparator4;
		private Gtk.RadioToolButton[] toolStandards;
			private Gtk.Image[] toolStandardImages;
	private Gtk.EventBox controller;
	private Gtk.DrawingArea display;
	
	private Gtk.FileFilter anysspFileFilter;
	private Gtk.FileFilter anysscFileFilter;
	private Gtk.FileFilter sscFileFilter;
	private Gtk.FileFilter sscxmlFileFilter;
	private Gtk.FileFilter xmlFileFilter;
//	private Gtk.FileFilter pngFileFilter;
//	private Gtk.FileFilter pdfFileFilter;
//	private Gtk.FileFilter svgFileFilter;
	private Gtk.FileFilter anyFileFilter;
	
	private Gtk.PrintSettings printSettings;
	private Gtk.PageSetup pageSetup;
	
	private Cairo.Surface gridCache;
	private Cairo.Surface staticCache;
	
	/**
	 * An array containing all primitive (built-in) component
	 * definitions.
	 */
	private ComponentDef[] standardComponentDefs;
	
	/**
	 * The Designer which the DesignerWindow is acting as a front-end
	 * for.
	 */
	private Designer designer;
	private bool _hasDesigner = false;
	/**
	 * Whether or not the window has a Designer.
	 */
	private bool hasDesigner {
		get { return _hasDesigner; }
		set {
			_hasDesigner = value;
			
			menuFileSave.set_sensitive (value);
			menuFileSaveas.set_sensitive (value);
			
			menuFilePrint.set_sensitive (value);
			menuFileExport.set_sensitive (value);
			menuFileRemovecomponent.set_sensitive (value);
			
			menuComponent.set_sensitive (value);
		}
	}
	/**
	 * The project associated with the DesignerWindow.
	 */
	private Project project;
	private bool _hasProject = false;
	/**
	 * Whether or not the window has a Project.
	 */
	private bool hasProject {
		get { return _hasProject; }
		set {
			_hasProject = value;
			
			menuFileNewcomponent.set_sensitive (value);
			menuFileOpen.set_sensitive (value);
			
			menuFileSaveproject.set_sensitive (value);
			menuFileSaveasproject.set_sensitive (value);
			
			menuRun.set_sensitive (value);
			menuProject.set_sensitive (value);
			menuWindows.set_sensitive (value);
			
			update_custom_menu ();
		}
	}
	
	/**
	 * Unique in the whole application.
	 */
	public int myID;
	/**
	 * The filename to save to. Ignored when using Save As.
	 */
	public string componentFileName = "";
	
	
	/**
	 * The x position where the user drags on the display area from.
	 */
	private int xMouseStart;
	/**
	 * The y position where the user drags on the display area from.
	 */
	private int yMouseStart;
	
	private float xMouseTravel;
	private float yMouseTravel;
	
	private float xMouseTravelStart;
	private float yMouseTravelStart;
	
	private bool mouseIsDown;
	
	/**
	 * Actions to perform when the mouse button is released.
	 */
	private enum MouseMode {
		SCROLL,
		ZOOM,
		SELECT,
		MOVE,
		ORIENTATE,
		DELETE,
		ADJUST,
		ANNOTATE,
		WIRE,
		BIND,
		TAG,
		INVERT,
		INSERT
	}
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
	 * Display grid on the work area.
	 */
	public bool showGrid = true;
	/**
	 * Update display whilst scrolling or zooming with mouse.
	 */
	public bool liveScrollUpdate = true;
	/**
	 * Insert or move component shadow
	 */
	public bool shadowComponent = true;
	/**
	 * Will show errors in red.
	 */
	private bool highlightErrors = true;
	private bool colourBackgrounds = true;
	private bool showHints = true;
	
	private bool autoBind = true;
	
	/**
	 * How shallow a diagonal line can be. E.g.: 0.2 means 1 in 5.
	 */
	private float diagonalThreshold = 0.2f;
	/**
	 * Specifies the action to perform when the mouse button is
	 * released.
	 */
	private MouseMode mouseMode = MouseMode.SELECT;
	
	
	/**
	 * Create a new DesignerWindow without any project or component.
	 */
	public DesignerWindow () {
		populate ();
		
		register_window ();
	}
	
	/**
	 * Create a new DesignerWindow with a new project but no component.
	 */
	public DesignerWindow.with_new_project () {
		populate ();
		register_window ();
		new_project ();
	}
	
	public DesignerWindow.with_project_from_file (string filename) {
		populate ();
		register_window ();
		load_project (filename);
	}
	
	/**
	 * Create a new DesignerWindow with a designer and project, but no
	 * component.
	 */
	public DesignerWindow.with_new_designer (Project project) {
		populate ();
		register_window ();
		this.project = project;
		hasProject = true;
		update_title ();
		
		new_designer ();
	}
	
	public DesignerWindow.with_existing_component (Project project, CustomComponentDef customComponentDef) {
		populate ();
		register_window ();
		this.project = project;
		hasProject = true;
		update_title ();
		
		new_designer ();
		set_component (customComponentDef);
	}
	
	/**
	 * Create a new DesignerWindow with a project, and new designer and
	 * component.
	 */
	public DesignerWindow.with_new_component (Project project) {
		populate ();
		register_window ();
		this.project = project;
		hasProject = true;
		update_title ();
		
		new_designer ();
		new_component ();
	}
	
	/**
	 * Create a new DesignerWindow with a project, new designer,
	 * and load a component from a file.
	 */
	public DesignerWindow.with_component_from_file (Project project, string filename) {
		populate ();
		register_window ();
		this.project = project;
		hasProject = true;
		update_title ();
		
		new_designer ();
		load_component (filename);
	}
	
	/**
	 * Populate the window with widgets.
	 */
	public void populate () {
		stdout.printf ("Design Window Created\n");
		
		set_default_size (800, 600);
		set_border_width (0);
		delete_event.connect (() => {close_window(); return true;});
		set_title (Core.programName);
		
		try {
			icon = new Gdk.Pixbuf.from_file (Config.resourcesDir + "images/icons/smartsim64.png");
		} catch {
			stderr.printf ("Could not load window image.\n");
		}
		
		vBox = new Gtk.VBox (false, 2);
		add (vBox);
		
		//Menus
		
		menubar = new Gtk.MenuBar ();
		vBox.pack_start (menubar, false, true, 0);
			
			menuFile = new Gtk.MenuItem.with_label ("File");
			menubar.append (menuFile);
			menuFileMenu = new Gtk.Menu ();
			menuFile.set_submenu (menuFileMenu);
				
				menuFileNewproject = new Gtk.MenuItem.with_label ("New Project");
				menuFileMenu.append (menuFileNewproject);
				menuFileNewproject.activate.connect (new_project);
				
				menuFileNewcomponent = new Gtk.MenuItem.with_label ("New Component");
				menuFileMenu.append (menuFileNewcomponent);
				menuFileNewcomponent.activate.connect (() => {new_designer().new_component();});
				menuFileNewcomponent.set_sensitive (false);
				
				menuFileSeparator1 = new Gtk.SeparatorMenuItem ();
				menuFileMenu.append (menuFileSeparator1);
				
				menuFileSaveproject = new Gtk.MenuItem.with_label ("Save Project");
				menuFileMenu.append (menuFileSaveproject);
				menuFileSaveproject.activate.connect (() => {save_project (false);});
				menuFileSaveproject.set_sensitive (false);
				
				menuFileSaveasproject = new Gtk.MenuItem.with_label ("Save Project As");
				menuFileMenu.append (menuFileSaveasproject);
				menuFileSaveasproject.activate.connect (() => {save_project (true);});
				menuFileSaveasproject.set_sensitive (false);
				
				menuFileSeparator2 = new Gtk.SeparatorMenuItem ();
				menuFileMenu.append (menuFileSeparator2);
				
				menuFileOpenproject = new Gtk.MenuItem.with_label ("Open Project");
				menuFileMenu.append (menuFileOpenproject);
				menuFileOpenproject.activate.connect (() => {open_project ();});
				
				menuFileSeparator3 = new Gtk.SeparatorMenuItem ();
				menuFileMenu.append (menuFileSeparator3);
				
				menuFileSave = new Gtk.MenuItem.with_label ("Save Component");
				menuFileMenu.append (menuFileSave);
				menuFileSave.activate.connect (() => {save_component (false);});
				menuFileSave.set_sensitive (false);
				
				menuFileSaveas = new Gtk.MenuItem.with_label ("Save Component As");
				menuFileMenu.append (menuFileSaveas);
				menuFileSaveas.activate.connect (() => {save_component (true);});
				menuFileSaveas.set_sensitive (false);
				
				menuFileSeparator4 = new Gtk.SeparatorMenuItem ();
				menuFileMenu.append (menuFileSeparator4);
				
				menuFileOpen = new Gtk.MenuItem.with_label ("Open Component");
				menuFileMenu.append (menuFileOpen);
				menuFileOpen.activate.connect (() => {open_component ();});
				menuFileOpen.set_sensitive (false);
				
				menuFileSeparator5 = new Gtk.SeparatorMenuItem ();
				menuFileMenu.append (menuFileSeparator5);
				
//				menuFileResumesimulation = new Gtk.MenuItem.with_label ("Resume Simulation");
//				menuFileMenu.append (menuFileResumesimulation);
				
//				menuFileSeparator6 = new Gtk.SeparatorMenuItem ();
//				menuFileMenu.append (menuFileSeparator6);
				
				menuFileExport = new Gtk.MenuItem.with_label ("Export");
				menuFileMenu.append (menuFileExport);
				menuFileExport.set_sensitive (false);
				menuFileExportMenu = new Gtk.Menu ();
				menuFileExport.set_submenu (menuFileExportMenu);
					
					menuFileExportPng = new Gtk.MenuItem.with_label ("Design Image as PNG Image");
					menuFileExportMenu.append (menuFileExportPng);
					menuFileExportPng.activate.connect (export_png);
					
					menuFileExportPdf = new Gtk.MenuItem.with_label ("Design Image as PDF Document");
					menuFileExportMenu.append (menuFileExportPdf);
					menuFileExportPdf.activate.connect (export_pdf);
					
					menuFileExportSvg = new Gtk.MenuItem.with_label ("Design Image as SVG Image");
					menuFileExportMenu.append (menuFileExportSvg);
					menuFileExportSvg.activate.connect (export_svg);
					
				menuFileSeparator6 = new Gtk.SeparatorMenuItem ();
				menuFileMenu.append (menuFileSeparator6);
				
				menuFilePagesetup = new Gtk.MenuItem.with_label ("Page Setup");
				menuFileMenu.append (menuFilePagesetup);
				menuFilePagesetup.activate.connect (print_page_setup);
				
				menuFilePrint = new Gtk.MenuItem.with_label ("Print");
				menuFileMenu.append (menuFilePrint);
				menuFilePrint.activate.connect (print);
				menuFilePrint.set_sensitive (false);
				
				menuFileSeparator7 = new Gtk.SeparatorMenuItem ();
				menuFileMenu.append (menuFileSeparator7);
				
				menuFileRemovecomponent = new Gtk.MenuItem.with_label ("Remove Component");
				menuFileMenu.append (menuFileRemovecomponent);
				menuFileRemovecomponent.activate.connect (() => {remove_component();});
				menuFileRemovecomponent.set_sensitive (false);
				
				menuFileSeparator8 = new Gtk.SeparatorMenuItem ();
				menuFileMenu.append (menuFileSeparator8);
				
				menuFileExit = new Gtk.MenuItem.with_label ("Close");
				menuFileMenu.append (menuFileExit);
				menuFileExit.activate.connect (() => {close_window();});
				
			menuView = new Gtk.MenuItem.with_label ("View");
			menubar.append (menuView);
			menuViewMenu = new Gtk.Menu ();
			menuView.set_submenu (menuViewMenu);
				
				menuViewFitdesign = new Gtk.MenuItem.with_label ("Fit Design to Display");
				menuViewMenu.append (menuViewFitdesign);
				menuViewFitdesign.activate.connect (() => {fit_design();});
				
				menuViewSeparator1 = new Gtk.SeparatorMenuItem ();
				menuViewMenu.append (menuViewSeparator1);
				
				menuViewShowgrid = new Gtk.CheckMenuItem.with_label ("Show Grid");
				menuViewMenu.append (menuViewShowgrid);
				menuViewShowgrid.active = true;
				menuViewShowgrid.toggled.connect ( 
					(menuItem) => {
						showGrid = menuItem.active;
						render_design ();
					});
				
				menuViewLivescrollupdate = new Gtk.CheckMenuItem.with_label ("Live Scroll Update");
				menuViewMenu.append (menuViewLivescrollupdate);
				menuViewLivescrollupdate.active = true;
				menuViewLivescrollupdate.toggled.connect ( 
					(menuItem) => {
						liveScrollUpdate = menuItem.active;
					});
				
				menuViewShadowcomponent = new Gtk.CheckMenuItem.with_label ("Shadow Component");
				menuViewMenu.append (menuViewShadowcomponent);
				menuViewShadowcomponent.active = true;
				menuViewShadowcomponent.toggled.connect ( 
					(menuItem) => {
						shadowComponent = menuItem.active;
					});
				
				menuViewHighlighterrors = new Gtk.CheckMenuItem.with_label ("Highlight Errors");
				menuViewMenu.append (menuViewHighlighterrors);
				menuViewHighlighterrors.active = true;
				menuViewHighlighterrors.toggled.connect ( 
					(menuItem) => {
						highlightErrors = menuItem.active;
						render_design ();
					});
				
				menuViewColourbackgrounds = new Gtk.CheckMenuItem.with_label ("Colour Backgrounds");
				menuViewMenu.append (menuViewColourbackgrounds);
				menuViewColourbackgrounds.active = true;
				menuViewColourbackgrounds.toggled.connect ( 
					(menuItem) => {
						colourBackgrounds = menuItem.active;
						render_design ();
					});
				
				menuViewShowdesignerhints = new Gtk.CheckMenuItem.with_label ("Show Designer Hints");
				menuViewMenu.append (menuViewShowdesignerhints);
				menuViewShowdesignerhints.active = true;
				menuViewShowdesignerhints.toggled.connect ( 
					(menuItem) => {
						showHints = menuItem.active;
						render_design ();
					});
				
			menuEdit = new Gtk.MenuItem.with_label ("Edit");
			menubar.append (menuEdit);
			menuEditMenu = new Gtk.Menu ();
			menuEdit.set_submenu (menuEditMenu);
				
				menuEditAutobind = new Gtk.CheckMenuItem.with_label ("Automatic Binding");
				menuEditMenu.append (menuEditAutobind);
				menuEditAutobind.active = true;
				menuEditAutobind.toggled.connect ( 
					(menuItem) => {
						autoBind = menuItem.active;
						render_design ();
					});
				
			menuRun = new Gtk.MenuItem.with_label ("Run");
			menubar.append (menuRun);
			menuRunMenu = new Gtk.Menu ();
			menuRun.set_sensitive (false);
			menuRun.set_submenu (menuRunMenu);
				
				menuRunRun = new Gtk.MenuItem.with_label ("Run");
				menuRunRun.activate.connect (run_circuit);
				menuRunMenu.append (menuRunRun);
				
//				menuRunReplayrecording = new Gtk.MenuItem.with_label ("Replay Recording From File");
//				menuRunMenu.append (menuRunReplayrecording);
				
				menuRunCheckcircuit = new Gtk.MenuItem.with_label ("Check Circuit Validity");
				menuRunCheckcircuit.activate.connect (validate_circuit);
				menuRunMenu.append (menuRunCheckcircuit);
				
				menuRunSeparator1 = new Gtk.SeparatorMenuItem ();
				menuRunMenu.append (menuRunSeparator1);
				
				menuRunStartpaused = new Gtk.CheckMenuItem.with_label ("Start Paused");
				menuRunMenu.append (menuRunStartpaused);
				
//				menuRunRecord = new Gtk.CheckMenuItem.with_label ("Record");
//				menuRunMenu.append (menuRunRecord);
				
			menuComponent = new Gtk.MenuItem.with_label ("Component");
			menubar.append (menuComponent);
			menuComponentMenu = new Gtk.Menu ();
			menuComponent.set_sensitive (false);
			menuComponent.set_submenu (menuComponentMenu);
				
				menuComponentMakeroot = new Gtk.MenuItem.with_label ("Set as Root");
				menuComponentMakeroot.activate.connect (set_root_component);
				menuComponentMenu.append (menuComponentMakeroot);
				
				menuComponentCustomise = new Gtk.MenuItem.with_label ("Customise");
				menuComponentCustomise.activate.connect (customise_component);
				menuComponentMenu.append (menuComponentCustomise);
				
			menuProject = new Gtk.MenuItem.with_label ("Project");
			menubar.append (menuProject);
			menuProjectMenu = new Gtk.Menu ();
			menuProject.set_sensitive (false);
			menuProject.set_submenu (menuProjectMenu);
				
				menuProjectStatistics = new Gtk.MenuItem.with_label ("Statistics");
				menuProjectStatistics.activate.connect (display_statistics);
				menuProjectMenu.append (menuProjectStatistics);
				
				menuProjectOptions = new Gtk.MenuItem.with_label ("Options");
				menuProjectOptions.activate.connect (configure_project);
				menuProjectMenu.append (menuProjectOptions);
				
			menuWindows = new Gtk.MenuItem.with_label ("Windows");
			menubar.append (menuWindows);
			menuWindows.set_sensitive (false);
				
				//Component listing defined dynamically
				
			menuHelp = new Gtk.MenuItem.with_label ("Help");
			menubar.append (menuHelp);
			menuHelpMenu = new Gtk.Menu ();
			menuHelp.set_submenu (menuHelpMenu);
				
				menuHelpAbout = new Gtk.MenuItem.with_label ("About");
				menuHelpMenu.append (menuHelpAbout);
				menuHelpAbout.activate.connect (show_about);
				
		//Toolbar
		
		hiddenRadioToolButton = new Gtk.RadioToolButton (null);
		
		toolbar = new Gtk.Toolbar ();
		toolbar.toolbar_style = Gtk.ToolbarStyle.ICONS;
		vBox.pack_start (toolbar, false, true, 0);
			
			toolScrollImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/scroll.png");
			toolScroll = new Gtk.RadioToolButton.from_widget (hiddenRadioToolButton);
			toolScroll.set_label ("Scroll");
			toolScroll.set_icon_widget (toolScrollImage);
			toolbar.insert (toolScroll, -1);
			toolScroll.set_tooltip_text ("Scroll: Move your view of the circuit with click and drag.");
			toolScroll.clicked.connect (() => {mouseMode = MouseMode.SCROLL; render_overlay ();});
			toolScroll.active = true;
			
			toolZoomImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/zoom.png");
			toolZoom = new Gtk.RadioToolButton.from_widget (hiddenRadioToolButton);
			toolZoom.set_label ("Zoom");
			toolZoom.set_icon_widget (toolZoomImage);
			toolbar.insert (toolZoom, -1);
			toolZoom.set_tooltip_text ("Zoom: Drag downward to zoom in or upward to zoom out.");
			toolZoom.clicked.connect (() => {mouseMode = MouseMode.ZOOM; render_overlay ();});
			
			toolSeparator1 = new Gtk.SeparatorToolItem ();
			toolbar.insert (toolSeparator1, -1);
			
			toolCursorImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/cursor.png");
			toolCursor = new Gtk.RadioToolButton.from_widget (hiddenRadioToolButton);
			toolCursor.set_label ("Cursor");
			toolCursor.set_icon_widget (toolCursorImage);
			toolbar.insert (toolCursor, -1);
			toolCursor.set_tooltip_text ("Select: Click on an object to select it.");
			toolCursor.clicked.connect (() => {mouseMode = MouseMode.SELECT; render_overlay ();});
			
			toolMoveImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/move.png");
			toolMove = new Gtk.RadioToolButton.from_widget (hiddenRadioToolButton);
			toolMove.set_label ("Move");
			toolMove.set_icon_widget (toolMoveImage);
			toolbar.insert (toolMove, -1);
			toolMove.set_tooltip_text ("Move: Click and drag an object to move it.");
			toolMove.clicked.connect (() => {mouseMode = MouseMode.MOVE; render_overlay ();});
			
			toolOrientateImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/orientate.png");
			toolOrientate = new Gtk.RadioToolButton.from_widget (hiddenRadioToolButton);
			toolOrientate.set_label ("Orientate");
			toolOrientate.set_icon_widget (toolOrientateImage);
			toolbar.insert (toolOrientate, -1);
			toolOrientate.set_tooltip_text ("Orientate: Change the rotation of a component by dragging it. Flip by clicking.");
			toolOrientate.clicked.connect (() => {mouseMode = MouseMode.ORIENTATE; render_overlay ();});
			
			toolDeleteImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/delete.png");
			toolDelete = new Gtk.RadioToolButton.from_widget (hiddenRadioToolButton);
			toolDelete.set_label ("Delete");
			toolDelete.set_icon_widget (toolDeleteImage);
			toolbar.insert (toolDelete, -1);
			toolDelete.set_tooltip_text ("Delete: Click on an object to delete it.");
			toolDelete.clicked.connect (() => {mouseMode = MouseMode.DELETE; render_overlay ();});
			
			toolAdjustImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/adjust.png");
			toolAdjust = new Gtk.RadioToolButton.from_widget (hiddenRadioToolButton);
			toolAdjust.set_label ("Adjust");
			toolAdjust.set_icon_widget (toolAdjustImage);
			toolbar.insert (toolAdjust, -1);
			toolAdjust.set_tooltip_text ("Adjust: Click on an object to change its properties.");
			toolAdjust.clicked.connect (() => {mouseMode = MouseMode.ADJUST; render_overlay ();});
			
			toolSeparator2 = new Gtk.SeparatorToolItem ();
			toolbar.insert (toolSeparator2, -1);
			
			toolAnnotateImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/annotate.png");
			toolAnnotate = new Gtk.RadioToolButton.from_widget (hiddenRadioToolButton);
			toolAnnotate.set_label ("Annotate");
			toolAnnotate.set_icon_widget (toolAnnotateImage);
			toolbar.insert (toolAnnotate, -1);
			toolAnnotate.set_tooltip_text ("Annotate: Click to insert a text comment.");
			toolAnnotate.clicked.connect (() => {mouseMode = MouseMode.ANNOTATE; render_overlay ();});
			
//			toolWatchImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/watch.png");
//			toolWatch = new Gtk.ToolButton (toolWatchImage, "Watch");
//			toolbar.insert (toolWatch, -1);
			
			toolWireImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/wire.png");
			toolWire = new Gtk.RadioToolButton.from_widget (hiddenRadioToolButton);
			toolWire.set_label ("Wire");
			toolWire.set_icon_widget (toolWireImage);
			toolbar.insert (toolWire, -1);
			toolWire.set_tooltip_text ("Wire: Insert a wire by clicking on successive points. Click again on the last point to finalise the wire. Click on the previous point to undo. Click this button again to forget the wire currently being draw.");
			toolWire.clicked.connect (() => {
				if (mouseMode == MouseMode.WIRE) {
					designer.forget_wire ();
					render_design ();
				}
				mouseMode = MouseMode.WIRE;
				render_overlay ();
			});
			
			toolBindImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/bind.png");
			toolBind = new Gtk.RadioToolButton.from_widget (hiddenRadioToolButton);
			toolBind.set_label ("Bind");
			toolBind.set_icon_widget (toolBindImage);
			toolbar.insert (toolBind, -1);
			toolBind.set_tooltip_text ("Bind: Click where a wire meets a pin or another wire to connect them. Click on an existing connection to remove it.");
			toolBind.clicked.connect (() => {mouseMode = MouseMode.BIND; render_overlay ();});
			
			toolTagImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/tag.png");
			toolTag = new Gtk.RadioToolButton.from_widget (hiddenRadioToolButton);
			toolTag.set_label ("Tag");
			toolTag.set_icon_widget (toolTagImage);
			toolbar.insert (toolTag, -1);
			toolTag.set_tooltip_text ("Tag: Drag to or from a wire to create an interface to the higher (container) component.");
			toolTag.clicked.connect (() => {mouseMode = MouseMode.TAG; render_overlay ();});
			
			toolInvertImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/invert.png");
			toolInvert = new Gtk.RadioToolButton.from_widget (hiddenRadioToolButton);
			toolInvert.set_label ("Invert");
			toolInvert.set_icon_widget (toolInvertImage);
			toolbar.insert (toolInvert, -1);
			toolInvert.set_tooltip_text ("Invert: Click on the end of a pin to invert it.");
			toolInvert.clicked.connect (() => {mouseMode = MouseMode.INVERT; render_overlay ();});
			
			toolSeparator3 = new Gtk.SeparatorToolItem ();
			toolbar.insert (toolSeparator3, -1);
			
			toolCustomsImage = new Gtk.Image.from_file (Config.resourcesDir + "images/toolbar/custom.png");
			toolCustoms = new Gtk.MenuToolButton (toolCustomsImage, "Custom...");
			toolbar.insert (toolCustoms, -1);
			toolCustoms.set_tooltip_text ("Custom Components: Select a custom component from the drop-down menu. Click the button for the last used component.");
			toolCustoms.clicked.connect (() => {
				if (hasDesigner) {
					if (designer.set_insert_last_custom()) {
						mouseMode = MouseMode.INSERT;
						deselect_tools ();
						render_overlay ();
					}
				}
			});
			
				//Component listing defined Dynamically
			
			toolSeparator4 = new Gtk.SeparatorToolItem ();
			toolbar.insert (toolSeparator4, -1);
			
			standardComponentDefs = Core.standardComponentDefs;
			for (int i = 0; i < standardComponentDefs.length; i ++) {
				ComponentDef componentDef = standardComponentDefs[i];
				Gtk.Image toolStandardImage;
				Gtk.RadioToolButton toolStandard;
				toolStandardImage = new Gtk.Image.from_file (Config.resourcesDir + "components/icons/" + componentDef.iconFilename);
				toolStandardImage.icon_size = 24;
				toolStandard = new Gtk.RadioToolButton.from_widget (hiddenRadioToolButton);
				toolStandard.set_label (componentDef.name);
				toolStandard.set_icon_widget (toolStandardImage);
				toolStandard.clicked.connect (
					() => {
						if (hasDesigner) {
							mouseMode = MouseMode.INSERT;
							designer.set_insert_component (componentDef);
							render_overlay ();
						}
					}
				);
				toolStandards += toolStandard;
				toolStandardImages += toolStandardImage;
				toolbar.insert (toolStandard, -1);
				toolStandard.set_tooltip_text (componentDef.name + ": " + componentDef.description);
			}
			
		//Main Display
		
		controller = new Gtk.EventBox ();
		vBox.pack_start (controller, true, true, 0);
		controller.button_press_event.connect (mouse_down);
		controller.set_events (Gdk.EventMask.POINTER_MOTION_MASK);
		controller.motion_notify_event.connect (mouse_move);
		controller.button_release_event.connect (mouse_up);
		
		display = new Gtk.DrawingArea ();
		controller.add (display);
		display.expose_event.connect (() => {render_design(); return false;});
		display.configure_event.connect (() => {gridCache = null; render_design(); return false;});
		
		printSettings = new Gtk.PrintSettings ();
		pageSetup = new Gtk.PageSetup ();
		pageSetup.set_orientation (Gtk.PageOrientation.LANDSCAPE);
		
		//File Filters
		
		anysspFileFilter = new Gtk.FileFilter();
		anysspFileFilter.set_name("Any SmartSim Project Format (.ssp)");
		anysspFileFilter.add_pattern("*.ssp");
		
		anysscFileFilter = new Gtk.FileFilter();
		anysscFileFilter.set_name("Any SmartSim Component Format (.ssc, .ssc.xml, .xml)");
		anysscFileFilter.add_pattern("*.ssc");
		anysscFileFilter.add_pattern("*.ssc.xml");
		anysscFileFilter.add_pattern("*.xml");
		
		sscFileFilter = new Gtk.FileFilter();
		sscFileFilter.set_name("SmartSim Component (.ssc)");
		sscFileFilter.add_pattern("*.ssc");
		
		xmlFileFilter = new Gtk.FileFilter();
		xmlFileFilter.set_name("SmartSim Component (.xml)");
		xmlFileFilter.add_pattern("*.xml");
		
		sscxmlFileFilter = new Gtk.FileFilter();
		sscxmlFileFilter.set_name("SmartSim Component (.ssc.xml)");
		sscxmlFileFilter.add_pattern("*.ssc.xml");
		
		/*
		pngFileFilter = new Gtk.FileFilter();
		pngFileFilter.set_name("Portable Network Graphic (.png)");
		pngFileFilter.add_pattern("*.png");
		
		pdfFileFilter = new Gtk.FileFilter();
		pdfFileFilter.set_name("Adobe Portable Document (.pdf)");
		pdfFileFilter.add_pattern("*.pdf");
		
		svgFileFilter = new Gtk.FileFilter();
		svgFileFilter.set_name("Scalable Vector Graphic (.svg)");
		svgFileFilter.add_pattern("*.svg");
		*/
		
		anyFileFilter = new Gtk.FileFilter();
		anyFileFilter.set_name("Any File");
		anyFileFilter.add_pattern("*");
		
		//Update window and custom component selections
		
		update_custom_menu ();
		
		//Finish
		
		show_all ();
	}
	
	/**
	 * Updates the custom components listed the "Windows" menu and
	 * custom component insert menu.
	 */
	public void update_custom_menu () {
		
		if (toolCustomsMenu != null) {
			toolCustomsMenu.destroy ();
		}
		if (menuWindowsMenu != null) {
			menuWindowsMenu.destroy ();
		}
		
		toolCustomsMenu = new Gtk.Menu ();
		menuWindowsMenu = new Gtk.Menu ();
		
		if (hasProject) {
			
			toolCustomsMenuComponents = {};
			menuWindowsComponents = {};
			
			for (int i = 0; i < project.customComponentDefs.length; i++) {
				CustomComponentDef customComponentDef = project.customComponentDefs[i];
				
				Gtk.MenuItem toolMenuItem = new Gtk.MenuItem.with_label (customComponentDef.name);
				toolCustomsMenu.append (toolMenuItem);
				toolMenuItem.activate.connect (
					() => {
						if (hasDesigner) {
							deselect_tools ();
							mouseMode = MouseMode.INSERT;
							designer.set_insert_component (customComponentDef);
							render_overlay ();
							stdout.printf ("DEBUG\n");
						}
					}
				);
				if (hasDesigner) {
					if (customComponentDef == designer.customComponentDef) {
						toolMenuItem.set_sensitive (false);
					}
				}
				toolCustomsMenuComponents += toolMenuItem;
				
				Gtk.MenuItem windowMenuItem = new Gtk.MenuItem.with_label (customComponentDef.name);
				menuWindowsMenu.append (windowMenuItem);
				windowMenuItem.activate.connect (
					() => {
						project.reopen_window_from_component (customComponentDef);
					}
				);
				menuWindowsComponents += windowMenuItem;
			}
		}
		
		toolCustoms.set_menu (toolCustomsMenu);
		menuWindows.set_submenu (menuWindowsMenu);
		
		toolCustomsMenu.show_all ();
		menuWindowsMenu.show_all ();
	}
	
	private void deselect_tools () {
		hiddenRadioToolButton.active = true;
	}
	
	public void update_error_mode (bool error) {
		if (error) {
			colourBackgrounds = false;
		} else {
			colourBackgrounds = menuViewColourbackgrounds.active;
		}
	}
	
	private void fit_design () {
		if (hasDesigner) {
			if (designer.hasComponent) {
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
				
				designer.customComponentDef.get_design_bounds (out rightBound, out downBound, out leftBound, out upBound);
				
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
				
				gridCache = null;
				render_design ();
			}
		}
	}
	
	/**
	 * Handles user request to open the Customiser.
	 */
	private void customise_component () {
		if (hasDesigner) {
			designer.customise_component ();
		}
	}
	
	private void configure_project () {
		if (hasProject) {
			project.configure ();
			project.update_titles ();
		}
	}
	
	private void display_statistics () {
		if (hasProject) {
			CircuitInformation circuitInformation = new CircuitInformation (project);
			
			if (circuitInformation.summary != "") {
				BasicDialog.information (this, "Statistics:\n\n" + circuitInformation.summary);
			}
		}
	}
	
	/**
	 * Handles mouse button down in the work area. Records mouse
	 * (drag) starting point.
	 */
	private bool mouse_down (Gdk.EventButton event) {
		mouseIsDown = true;
		
		xMouseStart = (int)(event.x);
		yMouseStart = (int)(event.y);
		
		return false;
	}
	
	private bool mouse_move (Gdk.EventMotion event) {
		if (Gtk.events_pending ()) {
			return false;
		}
		
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
		
		int xBoardDiff = xBoardEnd - xBoardStart;
		int yBoardDiff = yBoardEnd - yBoardStart;
		
//		int xDiffAbs = (xDiff > 0) ? xDiff : -xDiff;
		int yDiffAbs = (yDiff > 0) ? yDiff : -yDiff;
		
		xMouseTravel += (float)event.x - xMouseTravelStart;
		yMouseTravel += (float)event.y - yMouseTravelStart;
		
		xMouseTravelStart = (float)event.x;
		yMouseTravelStart = (float)event.y;
		
		if (xMouseTravel < -40) {
			yMouseTravel *= -40 / xMouseTravel;
			xMouseTravel = -40;
		} else if (xMouseTravel > 40) {
			yMouseTravel *= 40 / xMouseTravel;
			xMouseTravel = 40;
		}
		if (yMouseTravel < -40) {
			xMouseTravel *= -40 / yMouseTravel;
			yMouseTravel = -40;
		} else if (yMouseTravel > 40) {
			xMouseTravel *= 40 / yMouseTravel;
			yMouseTravel = 40;
		}
		
		switch (mouseMode) {
			case MouseMode.SCROLL:
				if (mouseIsDown && liveScrollUpdate) {
					int xViewOld = xView;
					int yViewOld = yView;
					xView -= xBoardDiff;
					yView -= yBoardDiff;
					gridCache = null;
					render_design ();
					xView = xViewOld;
					yView = yViewOld;
					gridCache = null;
				}
				break;
			case MouseMode.ZOOM:
				if (mouseIsDown && liveScrollUpdate) {
					float zoomOld = zoom;
					if (yDiff > 0) {
						zoom *= 1.0f + ((float)yDiffAbs / (float)height);
					} else {
						zoom /= 1.0f + ((float)yDiffAbs / (float)height);
					}
					gridCache = null;
					render_design ();
					zoom = zoomOld;
					gridCache = null;
				}
				break;
			case MouseMode.INSERT:
				if (!mouseIsDown && shadowComponent) {
					Direction direction;
					float xMouseTravelAbs = (xMouseTravel > 0) ? xMouseTravel : -xMouseTravel;
					float yMouseTravelAbs = (yMouseTravel > 0) ? yMouseTravel : -yMouseTravel;
					
					if (xMouseTravelAbs > yMouseTravelAbs) {
						if (xMouseTravel > 0) {
							direction = Direction.RIGHT;
						} else {
							direction = Direction.LEFT;
						}
					} else if (xMouseTravelAbs < yMouseTravelAbs) {
						if (yMouseTravel > 0) {
							direction = Direction.DOWN;
						} else {
							direction = Direction.UP;
						}
					} else {
						direction = Direction.RIGHT;
					}
					
					designer.shadowComponentInst.xPosition = xBoardEnd;
					designer.shadowComponentInst.yPosition = yBoardEnd;
					designer.shadowComponentInst.direction = direction;
					
					render_overlay ();
				}
				break;
		}
		
		return false;
	}
	
	/**
	 * Handles mouse button up in the work area. Performs an action
	 * which is determined by //mouseMode//.
	 */
	private bool mouse_up (Gdk.EventButton event) {
		mouseIsDown = false;
		
		if (project != null) {
			if (project.running) {
				stdout.printf ("Cannot edit running circuit!\n");
				return false;
			}
		}
		
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
		int xDiff = xEnd - xStart;
		int yDiff = yEnd - yStart;
		
		int xBoardStart = (int)((float)xStart / zoom + (float)xView);
		int yBoardStart = (int)((float)yStart / zoom + (float)yView);
		int xBoardEnd = (int)((float)xEnd / zoom + (float)xView);
		int yBoardEnd = (int)((float)yEnd / zoom + (float)yView);
		
		bool snapGridStart = true;
		bool snapGridEnd = true;
		
		int halfGridSize = gridSize / 2;
		
		if (mouseMode == MouseMode.WIRE || mouseMode == MouseMode.BIND || mouseMode == MouseMode.INVERT) {
			snapGridStart = (designer.snap_pin (ref xBoardStart, ref yBoardStart, gridSize) == 1);
			snapGridEnd = (designer.snap_pin (ref xBoardEnd, ref yBoardEnd, gridSize) == 1);
		}
		
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
		stdout.printf ("Interact @ (%i, %i) - (%i, %i)\n", xBoardStart, yBoardStart, xBoardEnd, yBoardEnd);
		
		int xBoardDiff = xBoardEnd - xBoardStart;
		int yBoardDiff = yBoardEnd - yBoardStart;
		
//		int xBoardDiff = (int)((float)xDiff / zoom);
//		int yBoardDiff = (int)((float)yDiff / zoom);
		
//		uint button = event.button;
//		int x;
//		int y;
		
//		x = xEnd;
//		y = yEnd;
		
		int xDiffAbs = (xDiff > 0) ? xDiff : -xDiff;
		int yDiffAbs = (yDiff > 0) ? yDiff : -yDiff;
//		int xBoardDiffAbs = (xBoardDiff > 0) ? xBoardDiff : -xBoardDiff;
//		int yBoardDiffAbs = (yBoardDiff > 0) ? yBoardDiff : -yBoardDiff;
		
		
		switch (mouseMode) {
			case MouseMode.SCROLL:
				xView -= xBoardDiff;
				yView -= yBoardDiff;
				gridCache = null;
				break;
			case MouseMode.ZOOM:
				if (yDiff > 0) {
					zoom *= 1.0f + ((float)yDiffAbs / (float)height);
				} else {
					zoom /= 1.0f + ((float)yDiffAbs / (float)height);
				}
				gridCache = null;
				break;
			case MouseMode.SELECT:
				if (hasDesigner && hasProject) {
					designer.select_components (xBoardEnd, yBoardEnd, false);
					designer.select_wires (xBoardEnd, yBoardEnd, false, true);
					designer.select_annotations (xBoardEnd, yBoardEnd, false);
				}
				break;
			case MouseMode.MOVE:
				if (hasDesigner && hasProject) {
					designer.select_components (xBoardStart, yBoardStart, false);
					designer.select_wires (xBoardStart, yBoardStart, false, true);
					designer.select_annotations (xBoardStart, yBoardStart, false);
					designer.move_components (xBoardDiff, yBoardDiff, false, autoBind);
					designer.move_wires (xBoardDiff, yBoardDiff, false, autoBind);
					designer.move_annotations (xBoardDiff, yBoardDiff, false);
				}
				break;
			case MouseMode.DELETE:
				if (hasDesigner && hasProject) {
					designer.delete_components (xBoardEnd, yBoardEnd);
					designer.delete_wires (xBoardEnd, yBoardEnd);
					designer.delete_tags (xBoardEnd, yBoardEnd);
					designer.delete_annotations (xBoardEnd, yBoardEnd);
				}
				break;
			case MouseMode.ADJUST:
				if (hasDesigner && hasProject) {
					designer.adjust_components (xBoardEnd, yBoardEnd, autoBind);
					designer.adjust_annotations (xBoardEnd, yBoardEnd);
					designer.adjust_wires (xBoardEnd, yBoardEnd);
				}
				break;
			case MouseMode.ANNOTATE:
				if (hasDesigner && hasProject) {
					designer.add_annotation (xBoardEnd, yBoardEnd, "Enter Text Here", 12);
					designer.adjust_annotations (xBoardEnd, yBoardEnd);
				}
				break;
			case MouseMode.WIRE:
				if (hasDesigner && hasProject) {
					designer.draw_wire (xBoardEnd, yBoardEnd, diagonalThreshold, autoBind);
				}
				break;
			case MouseMode.BIND:
				if (hasDesigner && hasProject) {
					int boundWires = 0;
					int connectedComponents = 0;
					boundWires = designer.bind_wire (xBoardEnd, yBoardEnd);
					connectedComponents = designer.connect_component (xBoardEnd, yBoardEnd);
					
					if (boundWires == 1 && connectedComponents == 0) {
						designer.unbind_wire (xBoardEnd, yBoardEnd);
						designer.disconnect_component (xBoardEnd, yBoardEnd);
					}
				}
				break;
			case MouseMode.TAG:
				if (hasDesigner && hasProject) {
					designer.tag_wire(xBoardStart, yBoardStart, xBoardEnd, yBoardEnd);
				}
				break;
			case MouseMode.INVERT:
				if (hasDesigner && hasProject) {
					designer.invert_pin (xBoardEnd, yBoardEnd);
				}
				break;
			case MouseMode.INSERT:
				if (hasDesigner && hasProject) {
					Direction direction;
					if (xDiffAbs > yDiffAbs) {
						if (xDiff > 0) {
							direction = Direction.RIGHT;
						} else {
							direction = Direction.LEFT;
						}
					} else if (xDiffAbs < yDiffAbs) {
						if (yDiff > 0) {
							direction = Direction.DOWN;
						} else {
							direction = Direction.UP;
						}
					} else {
						if (designer.shadowComponentInst != null && shadowComponent) {
							direction = designer.shadowComponentInst.direction;
						} else {
							direction = Direction.RIGHT;
						}
					}
					
					designer.add_componentInst (xBoardStart, yBoardStart, direction, autoBind);
				}
				break;
			case MouseMode.ORIENTATE:
				if (hasDesigner && hasProject) {
					designer.select_components (xBoardStart, yBoardStart, false);
					if (xDiff == 0 && yDiff == 0) {
						designer.flip_component (autoBind);
					} else {
						Direction direction;
						if (xDiffAbs > yDiffAbs) {
							if (xDiff > 0) {
								direction = Direction.RIGHT;
							} else {
								direction = Direction.LEFT;
							}
						} else if (xDiffAbs < yDiffAbs) {
							if (yDiff > 0) {
								direction = Direction.DOWN;
							} else {
								direction = Direction.UP;
							}
						} else {
							direction = Direction.RIGHT;
						}
						
						designer.orientate_component (direction, autoBind);
					}
				}
				break;
		}
		
		render_design ();
		
		return false;
	}
	
	/**
	 * Updates the window title to display identification about the
	 * component being viewed.
	 */
	public void update_title () {
		if (hasProject) {
			if (hasDesigner) {
				if (designer.hasComponent) {
					if (componentFileName != "") {
//						string shortFileName = componentFileName.replace ("\\", "/"); //Account for Windows.
						string shortFileName = componentFileName;
						if (shortFileName.last_index_of(GLib.Path.DIR_SEPARATOR_S) != -1) {
							shortFileName = shortFileName[shortFileName.last_index_of(GLib.Path.DIR_SEPARATOR_S)+1 : shortFileName.length];
						}
						designer.set_name (shortFileName);
					} else {
						designer.set_name ("Not saved - " + designer.customComponentDef.name);
					}
					set_title (Core.programName + " - " + project.name + " - " + designer.designerName);
				} else {
					set_title (Core.programName + " - " + project.name + " - " + designer.designerName);
				}
			} else {
				set_title (Core.programName + " - " + project.name);
			}
		} else {
			set_title (Core.programName);
		}
	}
	
	/**
	 * Prompts the user to open a file (when File>>Open is selected) and
	 * loads the file.
	 */
	private bool open_component () {
		
		Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog (
			"Load Component",
			this,
			Gtk.FileChooserAction.OPEN,
			Gtk.Stock.CANCEL,
			Gtk.ResponseType.CANCEL,
			Gtk.Stock.OPEN,
			Gtk.ResponseType.ACCEPT);
		
		fileChooser.add_filter(anysscFileFilter);
		add_filefilters (fileChooser);
		
		if (fileChooser.run () == Gtk.ResponseType.ACCEPT) {
			if (project.reopen_window_from_file(fileChooser.get_filename()) == 0) {
				stdout.printf ("Load Component From: %s\n", fileChooser.get_filename());
				new_designer().load_component (fileChooser.get_filename());
			}
			fileChooser.destroy ();
		} else {
			fileChooser.destroy ();
			return false;
		}
		
		return false;
	}
	
	/**
	 * Prompts the user to save to a file (when File>>Open is selected)
	 * if a filename is unknown, or if //saveAs// is true, and saves the
	 * component to a file.
	 */
	public bool save_component (bool saveAs) {
		
		if (!hasDesigner) {
			return false;
		} else if (!designer.hasComponent) {
			return false;
		}
		
		if (componentFileName == "" || saveAs) {
			Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog (
				"Save Component",
				this,
				Gtk.FileChooserAction.SAVE,
				Gtk.Stock.CANCEL,
				Gtk.ResponseType.CANCEL,
				Gtk.Stock.SAVE,
				Gtk.ResponseType.ACCEPT);
			
			add_filefilters (fileChooser);
			fileChooser.do_overwrite_confirmation = true;
			
			bool stillChoosing = true;
			while (stillChoosing) {
				if (fileChooser.run() == Gtk.ResponseType.ACCEPT) {
					componentFileName = fileChooser.get_filename ();
					if ("." in componentFileName) {
						stdout.printf ("File extension already given\n");
					} else {
						if (fileChooser.filter == sscFileFilter) {
							componentFileName += ".ssc";
						} else if (fileChooser.filter == sscxmlFileFilter) {
							componentFileName += ".ssc.xml";
						} else if (fileChooser.filter == xmlFileFilter) {
							componentFileName += ".xml";
						}
					}
					if (GLib.FileUtils.test(componentFileName, GLib.FileTest.EXISTS)) {
						if (BasicDialog.ask_overwrite(fileChooser, componentFileName) == Gtk.ResponseType.YES) {
							stillChoosing = false;
						}
					} else {
						stillChoosing = false;
					}
				} else {
					fileChooser.destroy ();
					return false;
				}
			}
			fileChooser.destroy ();
		}
		
		stdout.printf ("Save Component To: %s\n", componentFileName);
		
		designer.save_component (componentFileName);
		
		update_title ();
		
		return false;
	}
	
	private bool open_project () {
		
		Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog (
			"Load Project",
			this,
			Gtk.FileChooserAction.OPEN,
			Gtk.Stock.CANCEL,
			Gtk.ResponseType.CANCEL,
			Gtk.Stock.OPEN,
			Gtk.ResponseType.ACCEPT);
		
		fileChooser.add_filter(anysspFileFilter);
		
		if (fileChooser.run () == Gtk.ResponseType.ACCEPT) {
			stdout.printf ("Load Project From: %s\n", fileChooser.get_filename());
			load_project (fileChooser.get_filename());
			fileChooser.destroy ();
		} else {
			fileChooser.destroy ();
			return false;
		}
		
		return false;
	}
	
	private bool save_project (bool saveAs) {
		do_save_project (saveAs);
		
		return false;
	}
	
	private bool do_save_project (bool saveAs) {
		if (!hasProject) {
			return false;
		}
		
		if (project.filename == "" || saveAs) {
			Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog (
				"Save Project",
				this,
				Gtk.FileChooserAction.SAVE,
				Gtk.Stock.CANCEL,
				Gtk.ResponseType.CANCEL,
				Gtk.Stock.SAVE,
				Gtk.ResponseType.ACCEPT);
			
			fileChooser.add_filter(anysspFileFilter);
			fileChooser.do_overwrite_confirmation = true;
			
			bool stillChoosing = true;
			while (stillChoosing) {
				if (fileChooser.run () == Gtk.ResponseType.ACCEPT) {
					project.filename = fileChooser.get_filename ();
					if ("." in project.filename) {
						stdout.printf ("File extension already given\n");
					} else {
						if (fileChooser.filter == anysspFileFilter) {
							project.filename += ".ssp";
						}
					}
					if (GLib.FileUtils.test(project.filename, GLib.FileTest.EXISTS)) {
						if (BasicDialog.ask_overwrite(fileChooser, project.filename) == Gtk.ResponseType.YES) {
							stillChoosing = false;
						}
					} else {
						stillChoosing = false;
					}
				} else {
					fileChooser.destroy ();
					return false;
				}
			}
			fileChooser.destroy ();
		}
		
		stdout.printf ("Save Project To: %s\n", project.filename);
		
		project.save (project.filename);
		
		update_title ();
		
		return true;
	}
	
	/**
	 * Sets file extension filter opens in component open/save dialogs.
	 */
	private void add_filefilters (Gtk.FileChooser fileChooser) {
		fileChooser.add_filter(sscFileFilter);
		fileChooser.add_filter(sscxmlFileFilter);
		fileChooser.add_filter(xmlFileFilter);
		fileChooser.add_filter(anyFileFilter);
	}
	
	/**
	 * Creates a new component in this window. Does not open a new
	 * window if there is already a component.
	 */
	private void new_component () {
		if (hasDesigner && hasProject) {
			designer.set_component (project.new_component ());
//			designer.set_name ("Not saved - " + designer.customComponentDef.name);
		}
		update_custom_menu ();
		update_title ();
		render_design ();
	}
	
	private void set_component (CustomComponentDef customComponentDef) {
		if (hasDesigner && hasProject) {
			designer.set_component (customComponentDef);
//			designer.set_name (designer.customComponentDef.filename);
			componentFileName = designer.customComponentDef.filename;
		}
		update_custom_menu ();
		update_title ();
		render_design ();
	}
	
	/**
	 * Loads a component from a file in this window. Does not open a new
	 * window if there is already a component.
	 */
	private void load_component (string filename) {
		if (hasDesigner && hasProject) {
			designer.set_component (project.load_component (filename));
			if (!designer.hasComponent) {
				project.unregister_designer (designer);
				hasDesigner = false;
			}
			componentFileName = filename;
		}
		update_custom_menu ();
		update_title ();
		render_design ();
	}
	
	/**
	 * Creates a new Designer for the current project. Returns the
	 * window for the Designer. If there is not already a component in
	 * this window, this window will be used and returned.
	 */
	private DesignerWindow new_designer () {
		if (hasDesigner) {
			if (designer.hasComponent) {
				return new DesignerWindow.with_new_designer (project);
			} else {
				return this;
			}
		}
		designer = project.new_designer (this);
		hasDesigner = true;
		update_title ();
		render_design ();
		
		return this;
	}
	
/*	private void set_designer (Designer designer) {
		this.designer = designer;
		hasDesigner = true;
		update_title ();
		render_design ();
	}*/
	
	/**
	 * Creates a new Project. If there is not already a project in this
	 * window, this window will be used, else a new window will be
	 * created.
	 */
	private void new_project () {
		if (hasProject) {
			new DesignerWindow.with_new_project ();
			return;
		}
		project = new Project ();
		hasProject = true;
		update_title ();
	}
	
	private void load_project (string filename) {
		if (hasProject) {
			new DesignerWindow.with_project_from_file (filename);
			return;
		}
		try {
			project = new Project.load (filename);
			hasProject = true;
			CustomComponentDef defaultComponent = project.get_default_component ();
			if (defaultComponent != null) {
				new_designer();
				set_component (defaultComponent);
			}
			update_title ();
		} catch (ProjectLoadError error) {
			stderr.printf ("Error loading project: %s\n", error.message);
		}
	}
	
	/**
	 * Displays the about dialog (Help>>About). Displays information
	 * about the SmartSim software package.
	 */
	private void show_about () {
		Gdk.Pixbuf logo = null;
		
		try {
			logo = new Gdk.Pixbuf.from_file (Config.resourcesDir + "images/icons/smartsim64.png");
		} catch {
			stderr.printf ("Could not load logo image.\n");
		}
		
		Gtk.show_about_dialog (
				this,
				"logo", logo,
				"program-name", Core.programName,
				"title", "About" + Core.programName,
				"version", Core.versionString,
				"comments", "A logic circuit designer and simulator.",
				"copyright", Core.copyrightString,
				"license", Core.licenseName + "\n\n" + Core.licenseText
			);
	}
	
	/**
	 * Called when the user clicks File>>Page Setup. Opens a dialog for
	 * configuring the page setup for printing.
	 */
	public void print_page_setup () {
		pageSetup = Gtk.print_run_page_setup_dialog (this, pageSetup, printSettings);
	}
	
	/**
	 * Called when the user clicks File>>Print. Prompts the user with
	 * printing options and prints off the current work area view.
	 */
	public void print () {
		int width, height;
		Gtk.Allocation areaAllocation;
		
		display.get_allocation (out areaAllocation);
		width = areaAllocation.width;
		height = areaAllocation.height;
		
		if (!hasDesigner) {
			stderr.printf ("Error: Cannot print without designer\n");
			return;
		} else {
			if (!designer.hasComponent) {
				stderr.printf ("Error: Cannot print without component (but found designer)\n");
				return;
			}
		}
		
		Gtk.PrintOperation printOperation
			= new Gtk.PrintOperation ();
		
		printOperation.set_print_settings (printSettings);
		printOperation.set_default_page_setup (pageSetup);
		printOperation.set_n_pages (1);
		printOperation.set_unit (Gtk.Unit.POINTS);
		
		printOperation.draw_page.connect (print_render);
		
		Gtk.PrintOperationResult result;
		
		try {
			result = printOperation.run (Gtk.PrintOperationAction.PRINT_DIALOG, this);
		} catch {
			stderr.printf ("Print operation failed!\n");
			return;
		}
		
		if (result == Gtk.PrintOperationResult.APPLY) {
			printSettings = printOperation.get_print_settings ();
		}
	}
	
	public bool render_overlay () {
		if (display == null || !hasDesigner) {
			return false;
		}
		
		int width, height;
		Gtk.Allocation areaAllocation;
		
		display.get_allocation (out areaAllocation);
		width = areaAllocation.width;
		height = areaAllocation.height;
		
		if (staticCache == null) {
			render_design ();
		}
		
		Cairo.Context displayContext = Gdk.cairo_create (display.window);
		Cairo.Surface offScreenSurface = new Cairo.Surface.similar (displayContext.get_target(), Cairo.Content.COLOR, width, height);
		Cairo.Context context = new Cairo.Context (offScreenSurface);
		displayContext.set_source_surface (offScreenSurface, 0, 0);
		
		context.set_source_surface (staticCache, 0, 0);
		context.paint ();
		
		context.translate (width / 2, height / 2);
		context.scale (zoom, zoom);
		context.translate (-xView, -yView);
		
		context.set_source_rgb (0, 0, 0);
		context.set_line_width (1);
				
		if (shadowComponent && mouseMode == MouseMode.INSERT && !mouseIsDown) {
			designer.shadowComponentInst.render (context, showHints, false, colourBackgrounds);
		}
		
		displayContext.paint ();
		
		return false;
	}
	
	/**
	 * Refreshes the work area display.
	 */
	public bool render_design () {
		int width, height;
		Gtk.Allocation areaAllocation;
		
		display.get_allocation (out areaAllocation);
		width = areaAllocation.width;
		height = areaAllocation.height;
		
		Cairo.Context displayContext = Gdk.cairo_create (display.window);
		Cairo.Surface offScreenSurface = new Cairo.Surface.similar (displayContext.get_target(), Cairo.Content.COLOR, width, height);
		Cairo.Context context = new Cairo.Context (offScreenSurface);
		displayContext.set_source_surface (offScreenSurface, 0, 0);
		
		if (!hasDesigner) {
			context.translate (width / 2, height / 2);
			context.scale (zoom, zoom);
			context.translate (-xView, -yView);
			
			Cairo.TextExtents textExtents;
			context.select_font_face ("", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
			context.set_font_size (16.0);
			context.text_extents ("Welcome to " + Core.programName + " v" + Core.shortVersionString, out textExtents);
			context.translate (-textExtents.width / 2, +textExtents.height / 2);
			context.set_source_rgb (0.75, 0.75, 0.75);
			context.paint ();
			
			context.set_source_rgb (0, 0, 0);
			context.show_text ("Welcome to " + Core.programName + " v" + Core.shortVersionString);
			context.stroke ();
			context.select_font_face ("", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
			
			displayContext.paint ();
			return false;
		}
		
		context.set_line_width (1);
		
		if (showGrid) {
			if (gridCache == null) {
				gridCache = new Cairo.Surface.similar (context.get_target(), context.get_target().get_content(), width, height);
				Cairo.Context gridContext = new Cairo.Context (gridCache);
				
				gridContext.set_source_rgb (1, 1, 1);
				gridContext.paint ();
				
				float spacing = zoom * gridSize;
				
				while (spacing < 2) {
					spacing *= gridSize;
				}
				
				float y = ((height / 2) - (float)yView * zoom) % (spacing);
				float x = ((width  / 2) - (float)xView * zoom) % (spacing);
				
				gridContext.set_source_rgba (0, 0, 0, 0.5);
				
				gridContext.set_dash ({1.0, spacing - 1.0}, 0);
				
				for (; y < height; y += spacing) {
					gridContext.move_to (x, y);
					gridContext.line_to (width, y);
					gridContext.stroke ();
				}
				
				spacing *= 4;
				
				y = ((height / 2) - (float)yView * zoom) % (spacing);
				x = ((width  / 2) - (float)xView * zoom) % (spacing);// - (spacing * (xView % 4));
				
				gridContext.set_source_rgba (0, 0, 0, 1.0);
				
				gridContext.set_dash ({1.0, (spacing) - 1.0}, 0);
				
				for (; y < height; y += spacing) {
					gridContext.move_to (x, y);
					gridContext.line_to (width, y);
					gridContext.stroke ();
				}
				
				gridContext.set_dash (null, 0);
				
				gridContext.set_source_rgba (0, 0, 0, 0.5);
				
				x = (width / 2) - xView * zoom;
				y = (height / 2) - yView * zoom;
				
				gridContext.move_to ((x - 10 * zoom), (y)            );
				gridContext.line_to ((x + 10 * zoom), (y)            );
				gridContext.stroke ();
				gridContext.move_to ((x)            , (y - 10 * zoom));
				gridContext.line_to ((x)            , (y + 10 * zoom));
				gridContext.stroke ();
				
				gridContext.set_source_rgba (0, 0, 0, 1);
			}
			
			context.set_source_surface (gridCache, 0, 0);
			context.paint ();
		} else {
			context.set_source_rgb (1, 1, 1);
			context.paint ();
		}
		
		context.translate (width / 2, height / 2);
		context.scale (zoom, zoom);
		context.translate (-xView, -yView);
		
		context.set_source_rgb (0, 0, 0);
		
		designer.render (context, showHints, highlightErrors, colourBackgrounds);
		
		displayContext.paint ();
		
		staticCache = offScreenSurface;
		
		render_overlay ();
		
		return false;
	}
	
	/**
	 * Called by //print//. Renders the circuit for printing.
	 */
	public void print_render (Gtk.PrintContext printContext, int page_nr) {
		int width, height;
		Gtk.Allocation areaAllocation;
		
		display.get_allocation (out areaAllocation);
		width = areaAllocation.width;
		height = areaAllocation.height;
		
		int pageWidth = (int)printContext.get_width ();
		int pageHeight = (int)printContext.get_height ();
		double pageZoom;
		
		Cairo.Context context = printContext.get_cairo_context ();
		
		printContext.get_cairo_context ();
		
		context.set_source_rgb (1, 1, 1);
		context.paint ();
		
		context.set_line_width (1);
		
		pageZoom = zoom;
		if (pageWidth / width > pageHeight / height) {
			pageZoom = pageZoom * (double)pageHeight / (double)height;
		} else {
			pageZoom = pageZoom * (double)pageWidth / (double)width;
		}
		
		stdout.printf ("Printing design (render size = %i x %i, scale = %f)\n", pageWidth, pageHeight, pageZoom);
		
		context.translate (pageWidth / 2, pageHeight / 2);
		context.scale (pageZoom, pageZoom);
		context.translate (-xView, -yView);
		
		designer.render (context, false, false, colourBackgrounds);
	}
	
	public void export_png () {
		ImageExporter.export_png (file_render);
		
		/*
		string filename = "";
		ImageFormat imageFormat = ImageFormat.PNG_RGB;;
		double resolution;
		
		if (!hasDesigner) {
			return;
		} else if (!designer.hasComponent) {
			return;
		}
		
		PropertySet propertySet = new PropertySet ("PNG Export", "PNG image export options.");
		PropertyItemSelection formatProperty = new PropertyItemSelection ("Format", "PNG colour format to use.");
			formatProperty.add_option ("RGB (White Background)");
			formatProperty.add_option ("ARGB (Transparent Background)");
			formatProperty.set_option ("RGB (White Background)");
		propertySet.add_item (formatProperty);
		PropertyItemDouble resolutionProperty = new PropertyItemDouble ("Resolution", "Pixels per unit of distance.", 2);
		propertySet.add_item (resolutionProperty);
		
		PropertiesQuery propertiesQuery = new PropertiesQuery ("Export PNG Options", this, propertySet);
		
		if (propertiesQuery.run() == Gtk.ResponseType.APPLY) {
			Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog (
				"Export to PNG",
				this,
				Gtk.FileChooserAction.SAVE,
				Gtk.Stock.CANCEL,
				Gtk.ResponseType.CANCEL,
				Gtk.Stock.SAVE,
				Gtk.ResponseType.ACCEPT);
			
			fileChooser.add_filter (pngFileFilter);
			fileChooser.do_overwrite_confirmation = true;
			
			if (fileChooser.run () == Gtk.ResponseType.ACCEPT) {
				filename = fileChooser.get_filename ();
				if ("." in filename) {
					stdout.printf ("File extension already given\n");
				} else {
					if (fileChooser.filter == pngFileFilter) {
						filename += ".png";
					}
				}
				
				fileChooser.destroy ();
			} else {
				fileChooser.destroy ();
				return;
			}
		}
		
		if (filename != "") {
			switch (PropertyItemSelection.get_data(propertySet, "Format")) {
				case "RGB (White Background)":
					imageFormat = ImageFormat.PNG_RGB;
					break;
				case "ARGB (Transparent Background)":
					imageFormat = ImageFormat.PNG_ARGB;
					break;
			}
			
			resolution = PropertyItemDouble.get_data (propertySet, "Resolution");
			
			file_render (filename, imageFormat, resolution);
		}
		*/
	}
	
	public void export_pdf () {
		ImageExporter.export_pdf (file_render);
		
		/*
		string filename = "";
		
		if (!hasDesigner) {
			return;
		} else if (!designer.hasComponent) {
			return;
		}
		
		Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog (
			"Export to PDF",
			this,
			Gtk.FileChooserAction.SAVE,
			Gtk.Stock.CANCEL,
			Gtk.ResponseType.CANCEL,
			Gtk.Stock.SAVE,
			Gtk.ResponseType.ACCEPT);
		
		fileChooser.add_filter (pdfFileFilter);
		fileChooser.do_overwrite_confirmation = true;
		
		if (fileChooser.run () == Gtk.ResponseType.ACCEPT) {
			filename = fileChooser.get_filename ();
			if ("." in filename) {
				stdout.printf ("File extension already given\n");
			} else {
				if (fileChooser.filter == pdfFileFilter) {
					filename += ".pdf";
				}
			}
			
			fileChooser.destroy ();
		} else {
			fileChooser.destroy ();
		}
		
		if (filename != "") {
			file_render (filename, ImageFormat.PDF, 1);
		}
		*/
	}
	
	public void export_svg () {
		ImageExporter.export_svg (file_render);
		
		/*
		string filename = "";
		ImageFormat imageFormat = ImageFormat.SVG;
		
		if (!hasDesigner) {
			return;
		} else if (!designer.hasComponent) {
			return;
		}
		
		PropertySet propertySet = new PropertySet ("SVG Export", "SVG image export options.");
		PropertyItemSelection formatProperty = new PropertyItemSelection ("Background", "The background for the SVG to use.");
			formatProperty.add_option ("White Background");
			formatProperty.add_option ("Transparent Background");
			formatProperty.set_option ("White Background");
		propertySet.add_item (formatProperty);
		
		PropertiesQuery propertiesQuery = new PropertiesQuery ("Export SVG Options", this, propertySet);
		
		if (propertiesQuery.run() == Gtk.ResponseType.APPLY) {
			Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog (
				"Export to SVG",
				this,
				Gtk.FileChooserAction.SAVE,
				Gtk.Stock.CANCEL,
				Gtk.ResponseType.CANCEL,
				Gtk.Stock.SAVE,
				Gtk.ResponseType.ACCEPT);
			
			fileChooser.add_filter (svgFileFilter);
			fileChooser.do_overwrite_confirmation = true;
			
			if (fileChooser.run () == Gtk.ResponseType.ACCEPT) {
				filename = fileChooser.get_filename ();
				if ("." in filename) {
					stdout.printf ("File extension already given\n");
				} else {
					if (fileChooser.filter == svgFileFilter) {
						filename += ".svg";
					}
				}
				
				fileChooser.destroy ();
			} else {
				fileChooser.destroy ();
				return;
			}
		}
		
		if (filename != "") {
			switch (PropertyItemSelection.get_data(propertySet, "Background")) {
				case "White Background":
					imageFormat = ImageFormat.SVG;
					break;
				case "Transparent Background":
					imageFormat = ImageFormat.SVG_CLEAR;
					break;
			}
			
			file_render (filename, imageFormat, 1);
		}
		*/
	}
	
	/**
	 * Passed to ImageExporter as a delegate and called by an export
	 * function to render to a file.
	 */
	private void file_render (string filename, ImageExporter.ImageFormat imageFormat, double resolution) {
		Cairo.Surface surface;
		Gtk.Allocation areaAllocation;
		display.get_allocation (out areaAllocation);
		int width, height;
		width = areaAllocation.width;
		height = areaAllocation.height;
		
		int imageWidth = (int)((double)width * resolution);
		int imageHeight = (int)((double)height * resolution);
		double imageZoom = zoom * resolution;
		
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
		
		context.set_line_width (1);
		
		stdout.printf ("Exporting design (render size = %i x %i, scale = %f)\n", imageWidth, imageHeight, imageZoom);
		
		context.translate (imageWidth / 2, imageHeight / 2);
		context.scale (imageZoom, imageZoom);
		context.translate (-xView, -yView);
		
		designer.render (context, false, false, colourBackgrounds);
		
		switch (imageFormat) {
			case ImageExporter.ImageFormat.PNG_RGB:
			case ImageExporter.ImageFormat.PNG_ARGB:
				surface.write_to_png (filename);
				break;
		}
	}
	
	/**
	 * Hides the window and unregisters it from the list of visible
	 * DesignerWindows. Destroys only if there is no designer.
	 */
	private bool close_window () {
		if (hasProject) {
			if (count_project_windows(project) == 1) {
				if (!comfirm_close()) {
					return false;
				}
			}
		}
		
		if (hasDesigner) {
			unregister_window ();
			hide ();
			gridCache = null;
		} else {
			force_destroy_window ();
		}
		return true;
	}
	
	private bool comfirm_close () {
		Gtk.MessageDialog messageDialog = new Gtk.MessageDialog (
			this,
			Gtk.DialogFlags.MODAL,
			Gtk.MessageType.QUESTION,
			Gtk.ButtonsType.NONE,
			"You are about to close project \"%s\".\nDo you wish to save this project?",
			project.name);
		
		messageDialog.add_button (Gtk.Stock.YES, Gtk.ResponseType.YES);
		messageDialog.add_button (Gtk.Stock.NO, Gtk.ResponseType.NO);
		messageDialog.add_button (Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL);
		
		switch (messageDialog.run()) {
			case Gtk.ResponseType.CANCEL:
				messageDialog.destroy ();
				return false;
			case Gtk.ResponseType.NO:
				messageDialog.destroy ();
				return true;
			case Gtk.ResponseType.YES:
				messageDialog.destroy ();
				return do_save_project (false);
			default:
				messageDialog.destroy ();
				return false;
		}
	}
	
	public void force_destroy_window () {
		stdout.printf ("Designer Window destroyed (not hidden)\n");
		
		project = null;
		designer = null;
		hasDesigner = false;
		hasProject = false;
		
		update_custom_menu ();
		
		unregister_window ();
		
		destroy ();
	}
	
	private bool remove_component () {
		if (!hasDesigner) {
			return false;
		}
		
		if (project.remove_component(designer.customComponentDef) == 0) {
			project.update_custom_menus ();
			project.unregister_designer (designer);
			hasDesigner = false;
			update_title ();
			render_design ();
		}
		
		return false;
	}
	
	/**
	 * Called when user clicks Run>>Check circuit validity. Shows a
	 * message dialog stating whether or not the circuit is valid.
	 */
	private void validate_circuit () {
		CompiledCircuit compiledCircuit = project.validate ();
		
		if (compiledCircuit == null) {
			stderr.printf ("Cannot validate.\n");
			return;
		}
		
		if (compiledCircuit.errorMessage != "") {
			stdout.printf ("Circuit is invalid!\n");
			stdout.flush ();
			stderr.printf ("Error Messages:\n%s\n", compiledCircuit.errorMessage);
//			
//			colourBackgrounds = false;
		} else {
			stdout.printf ("Circuit validated with no errors\n");
//			
//			colourBackgrounds = menuViewColourbackgrounds.active;
		}
		
		render_design ();
	}
	
	/**
	 * Called when the user clicks Run>>Run. Starts the circuit
	 * simulating.
	 */
	private void run_circuit () {
		if (project.running) {
			return;
		}
		
		bool startNow = !menuRunStartpaused.active;
		CompiledCircuit compiledCircuit = project.run (startNow);
		
		if (compiledCircuit == null) {
			stderr.printf ("Run failure.\n");
			
			colourBackgrounds = false;
			
			render_design ();
			
			return;
		}
		
		if (compiledCircuit.errorMessage != "") {
			stdout.printf ("Circuit is invalid!\n");
			stdout.flush ();
			stderr.printf ("Error Messages:\n%s\n", compiledCircuit.errorMessage);
			
			colourBackgrounds = false;
		} else {
			stdout.printf ("Circuit started with no errors\n");
			
			colourBackgrounds = menuViewColourbackgrounds.active;
		}
		
		render_design ();
	}
	
	/**
	 * Called when the user clicks Component>>Set as root. Sets the
	 * component open in the designer as root.
	 */
	public void set_root_component () {
		if (hasDesigner && hasProject) {
			project.set_root_component (designer.customComponentDef);
		}
	}
	
	/**
	 * Registers the window.
	 */
	private void register_window () {
		DesignerWindow.register (this);
	}
	
	/**
	 * Unregisters the window.
	 */
	private void unregister_window () {
		DesignerWindow.unregister (this);
	}
	
	~DesignerWindow () {
		stdout.printf ("Designer Window Destroyed\n");
	}
}
