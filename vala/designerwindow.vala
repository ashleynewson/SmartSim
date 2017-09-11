/*
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *   Filename: designerwindow.vala
 *
 *   Copyright Ashley Newson 2013
 */


/**
 * The primary interface for the user. Used to design components and
 * navigate through the application.
 */
public class DesignerWindow {
    // I don't know of any way to include this within the UI XML.
    const string[] projectRequiringWidgetIds = {
        "menu_file_newcomponent",
        "menu_file_saveproject",
        "menu_file_saveprojectas",
        "menu_file_openproject",
        "menu_file_opencomponent",
        "menu_file_openplugincomponent",
        "menu_run",
        "menu_project",
        "menu_windows"
    };
    const string[] designerRequiringWidgetIds = {
        "menu_file_savecomponent",
        "menu_file_savecomponentas",
        "menu_file_removecomponent",
        "menu_file_print",
        "menu_file_export",
        "menu_component"
    };

    /**
     * Registration of all visible DesignerWindows.
     */
    private static DesignerWindow[] designerWindows;

    /**
     * Adds //designerWindow// to the list of visible DesignerWindows.
     */
    public static void register(DesignerWindow designerWindow) {
        int position;
        position = designerWindows.length;
        designerWindows += designerWindow;
        designerWindow.myID = position;

        stderr.printf("Registered designer window %i\n", position);
    }

    /**
     * Removes //designerWindow// from the list of visible DesignerWindows.
     * When there are no more visible windows, the application quits.
     */
    public static void unregister(DesignerWindow designerWindow) {
        DesignerWindow[] tempArray = {};
        int position;
        int newID = 0;
        position = designerWindow.myID;

        if (position == -1) {
            stderr.printf("Window already unregistered!\n");
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

        stderr.printf("Unregistered designer window %i\n", position);

        Project.clean_up();

        if (designerWindows.length == 0) {
            stderr.printf("No more designer windows! Closing...\n");
            Gtk.main_quit();
        }
    }

    public static bool project_has_windows(Project project) {
        foreach (DesignerWindow designerWindow in designerWindows) {
            if (designerWindow.project == project) {
                return true;
            }
        }

        return false;
    }

    public static int count_project_windows(Project project) {
        int count = 0;

        foreach (DesignerWindow designerWindow in designerWindows) {
            if (designerWindow.project == project) {
                count++;
            }
        }

        return count;
    }

    public static DesignerWindow[] get_project_windows(Project project) {
        DesignerWindow[] projectDesignerWindows = {};
        foreach (DesignerWindow designerWindow in designerWindows) {
            if (designerWindow.project == project) {
                projectDesignerWindows += designerWindow;
            }
        }

        return projectDesignerWindows;
    }



    private Gtk.Window window;
    private Gtk.MenuItem menuFileRemoveplugincomponent;
    private Gtk.Menu menuFileRemoveplugincomponentMenu;
    private Gtk.MenuItem[] menuFileRemoveplugincomponentComponents;
    private Gtk.CheckMenuItem menuViewColourbackgrounds;
    private Gtk.CheckMenuItem menuRunStartpaused;
    private Gtk.MenuItem menuWindows;
    private Gtk.Menu menuWindowsMenu;
    private Gtk.MenuItem[] menuWindowsComponents;
    private Gtk.RadioToolButton hiddenRadioToolButton;
    private Gtk.Toolbar toolbar;
    private Gtk.MenuToolButton toolCustoms;
    private Gtk.Menu toolCustomsMenu;
    private Gtk.MenuItem[] toolCustomsMenuComponents;
    private Gtk.MenuToolButton toolPlugins;
    private Gtk.Menu toolPluginsMenu;
    private Gtk.MenuItem[] toolPluginsMenuComponents;
    private Gtk.EventBox controller;
    private Gtk.DrawingArea display;

    private Gtk.FileFilter sspFileFilter;
    private Gtk.FileFilter sscFileFilter;
    private Gtk.FileFilter ssxFileFilter;
    private Gtk.FileFilter pngFileFilter;
    private Gtk.FileFilter pdfFileFilter;
    private Gtk.FileFilter svgFileFilter;
    private Gtk.FileFilter anyFileFilter;

    private Gtk.PrintSettings printSettings;
    private Gtk.PageSetup pageSetup;

    private Gtk.Widget[] projectRequiringWidgets = {};
    private Gtk.Widget[] designerRequiringWidgets = {};

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

            foreach (Gtk.Widget widget in designerRequiringWidgets) {
                widget.set_sensitive(value);
            }
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

            foreach (Gtk.Widget widget in projectRequiringWidgets) {
                widget.set_sensitive(value);
            }

            update_custom_menu();
            update_plugin_menu();
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
    public bool shadowComponent = false;
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
    public DesignerWindow() {
        populate();

        register_designerwindow();
    }

    /**
     * Create a new DesignerWindow with a new project but no component.
     */
    public DesignerWindow.with_new_project() {
        populate();
        register_designerwindow();
        new_project();
    }

    public DesignerWindow.with_project_from_file(string filename) {
        populate();
        register_designerwindow();
        load_project(filename);
    }

    /**
     * Create a new DesignerWindow with a designer and project, but no
     * component.
     */
    public DesignerWindow.with_new_designer(Project project) {
        populate();
        register_designerwindow();
        this.project = project;
        hasProject = true;
        update_title();

        new_designer();
    }

    public DesignerWindow.with_existing_component(Project project, CustomComponentDef customComponentDef) {
        populate();
        register_designerwindow();
        this.project = project;
        hasProject = true;
        update_title();

        new_designer();
        set_component(customComponentDef);
    }

    /**
     * Create a new DesignerWindow with a project, and new designer and
     * component.
     */
    public DesignerWindow.with_new_component(Project project) {
        populate();
        register_designerwindow();
        this.project = project;
        hasProject = true;
        update_title();

        new_designer();
        new_component();
    }

    /**
     * Create a new DesignerWindow with a project, new designer,
     * and load a component from a file.
     */
    public DesignerWindow.with_component_from_file(Project project, string filename) {
        populate();
        register_designerwindow();
        this.project = project;
        hasProject = true;
        update_title();

        new_designer();
        load_component(filename);
    }

    /**
     * Populate the window with widgets.
     */
    public void populate() {
        stderr.printf("Design Window Created\n");

        try {
            Gtk.Builder builder = new Gtk.Builder();
            try {
                builder.add_from_file(Config.resourcesDir + "ui/designer.ui");
            } catch (FileError e) {
                throw new UICommon.LoadError.MISSING_RESOURCE(e.message);
            } catch (Error e) {
                throw new UICommon.LoadError.BAD_RESOURCE(e.message);
            }

            // Connect basic signals
            // There doesn't seem to be any error handling for this...
            builder.connect_signals(this);

            // Get references to useful things
            window = UICommon.get_object_critical(builder, "window") as Gtk.Window;

            // Menus are enabled/disabled and submenus are populated at runtime.
            // It would be good if these could be annotated in the ui xml.
            foreach (string id in projectRequiringWidgetIds) {
                projectRequiringWidgets += UICommon.get_object_critical(builder, id) as Gtk.Widget;
            }
            foreach (string id in designerRequiringWidgetIds) {
                designerRequiringWidgets += UICommon.get_object_critical(builder, id) as Gtk.Widget;
            }

            menuFileRemoveplugincomponent = UICommon.get_object_critical(builder, "menu_file_removeplugincomponent") as Gtk.MenuItem;
            menuViewColourbackgrounds = UICommon.get_object_critical(builder, "menu_view_backgrounds") as Gtk.CheckMenuItem;
            menuWindows = UICommon.get_object_critical(builder, "menu_windows") as Gtk.MenuItem;
            menuRunStartpaused = UICommon.get_object_critical(builder, "menu_run_startpaused") as Gtk.CheckMenuItem;

            toolbar = UICommon.get_object_critical(builder, "toolbar") as Gtk.Toolbar;
            hiddenRadioToolButton = UICommon.get_object_critical(builder, "tool_group") as Gtk.RadioToolButton;

            controller = UICommon.get_object_critical(builder, "controller") as Gtk.EventBox;
            display = UICommon.get_object_critical(builder, "display") as Gtk.DrawingArea;

            sspFileFilter = UICommon.get_object_critical(builder, "filter_ssp") as Gtk.FileFilter;
            sscFileFilter = UICommon.get_object_critical(builder, "filter_ssc") as Gtk.FileFilter;
            ssxFileFilter = UICommon.get_object_critical(builder, "filter_ssx") as Gtk.FileFilter;
            pngFileFilter = UICommon.get_object_critical(builder, "filter_png") as Gtk.FileFilter;
            pdfFileFilter = UICommon.get_object_critical(builder, "filter_pdf") as Gtk.FileFilter;
            svgFileFilter = UICommon.get_object_critical(builder, "filter_svg") as Gtk.FileFilter;
            anyFileFilter = UICommon.get_object_critical(builder, "filter_any") as Gtk.FileFilter;

            // Connect tools. These connections are done in code for convenience.

            // This could probably be cleaned using a map
            connect_tool(builder, "tool_scroll", MouseMode.SCROLL);
            connect_tool(builder, "tool_zoom", MouseMode.ZOOM);
            connect_tool(builder, "tool_select", MouseMode.SELECT);
            connect_tool(builder, "tool_move", MouseMode.MOVE);
            connect_tool(builder, "tool_orientate", MouseMode.ORIENTATE);
            connect_tool(builder, "tool_delete", MouseMode.DELETE);
            connect_tool(builder, "tool_adjust", MouseMode.ADJUST);
            connect_tool(builder, "tool_annotate", MouseMode.ANNOTATE);
            connect_tool(builder, "tool_wire", MouseMode.WIRE);
            connect_tool(builder, "tool_bind", MouseMode.BIND);
            connect_tool(builder, "tool_tag", MouseMode.TAG);
            connect_tool(builder, "tool_invert", MouseMode.INVERT);
            toolCustoms = UICommon.get_object_critical(builder, "tool_customs") as Gtk.MenuToolButton;
            toolCustoms.clicked.connect(
                                        () => {
                                            if (hasDesigner) {
                                                if (designer.set_insert_last_custom()) {
                                                    deselect_tools();
                                                    mouseMode = MouseMode.INSERT;
                                                    designer.set_insert_last_custom();
                                                    update_overlay();
                                                }
                                            }
                                        }
                                        );
            toolPlugins = UICommon.get_object_critical(builder, "tool_plugins") as Gtk.MenuToolButton;
            toolPlugins.clicked.connect(
                                        () => {
                                            if (hasDesigner) {
                                                if (designer.set_insert_last_plugin()) {
                                                    deselect_tools();
                                                    mouseMode = MouseMode.INSERT;
                                                    designer.set_insert_last_plugin();
                                                    update_overlay();
                                                }
                                            }
                                        }
                                        );

            // Component listing defined Dynamically

            standardComponentDefs = Core.standardComponentDefs;
            for (int i = 0; i < standardComponentDefs.length; i ++) {
                ComponentDef componentDef = standardComponentDefs[i];
                Gtk.Image toolStandardImage;
                Gtk.RadioToolButton toolStandard;
                toolStandardImage = new Gtk.Image.from_file(Config.resourcesDir + "components/icons/" + componentDef.iconFilename);
                toolStandardImage.icon_size = 24;
                toolStandard = new Gtk.RadioToolButton.from_widget(hiddenRadioToolButton);
                toolStandard.set_label(componentDef.name);
                toolStandard.set_icon_widget(toolStandardImage);
                toolStandard.clicked.connect(
                                             () => {
                                                 if (hasDesigner) {
                                                     mouseMode = MouseMode.INSERT;
                                                     designer.set_insert_component(componentDef);
                                                     update_overlay();
                                                 }
                                             }
                                             );
                toolbar.insert(toolStandard, -1);
                toolStandard.set_tooltip_text(componentDef.name + ": " + componentDef.description);
            }

            // Printing

            printSettings = new Gtk.PrintSettings();
            pageSetup = new Gtk.PageSetup();
            pageSetup.set_orientation(Gtk.PageOrientation.LANDSCAPE);

            // Update window and custom component selections

            update_custom_menu();
            update_plugin_menu();

            // I know of no way to set the file filter names in UI code.

            sspFileFilter.set_filter_name("SmartSim Project Format (.ssp)");
            sscFileFilter.set_filter_name("SmartSim Component (.ssc)");
            ssxFileFilter.set_filter_name("SmartSim Plugin Component (.ssx)");
            pngFileFilter.set_filter_name("Portable Network Graphic (.png)");
            pdfFileFilter.set_filter_name("Portable Document Format (.pdf)");
            svgFileFilter.set_filter_name("Scalable Vector Graphic (.svg)");
            anyFileFilter.set_filter_name("Any File");

            // Finish

            window.show_all();

            window.set_title(Core.programName);
        } catch (UICommon.LoadError e) {
            UICommon.fatal_load_error(e);
        }
    }

    private void connect_tool(Gtk.Builder builder, string name, MouseMode mode) throws UICommon.LoadError.MISSING_OBJECT {
        (UICommon.get_object_critical(builder, name) as Gtk.RadioToolButton).clicked.connect(() => {mouseMode = mode; update_display();});
    }


    // Signal handlers.
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_delete_window")]
    public bool ui_delete_window(Gtk.Window window, Gdk.Event event) {
        return close_window();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_close")]
    public void ui_close(Gtk.Activatable activatable) {
        close_window();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_new_project")]
    public void ui_new_project(Gtk.Activatable activatable) {
        new_project();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_new_component")]
    public void ui_new_component(Gtk.Activatable activatable) {
        new_designer().new_component();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_save_project")]
    public void ui_save_project(Gtk.Activatable activatable) {
        save_project(false);
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_save_project_as")]
    public void ui_save_project_as(Gtk.Activatable activatable) {
        save_project(true);
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_open_project")]
    public void ui_open_project(Gtk.Activatable activatable) {
        open_project();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_save_component")]
    public void ui_save_component(Gtk.Activatable activatable) {
        save_component(false);
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_save_component_as")]
    public void ui_save_component_as(Gtk.Activatable activatable) {
        save_component(true);
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_open_component")]
    public void ui_open_component(Gtk.Activatable activatable) {
        open_component();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_open_plugin_component")]
    public void ui_open_plugin_component(Gtk.Activatable activatable) {
        open_plugin_component();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_export_png")]
    public void ui_export_png(Gtk.Activatable activatable) {
        export_png();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_export_pdf")]
    public void ui_export_pdf(Gtk.Activatable activatable) {
        export_pdf();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_export_svg")]
    public void ui_export_svg(Gtk.Activatable activatable) {
        export_svg();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_page_setup")]
    public void ui_page_setup(Gtk.Activatable activatable) {
        print_page_setup();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_print")]
    public void ui_print(Gtk.Activatable activatable) {
        print();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_remove_component")]
    public void ui_remove_component(Gtk.Activatable activatable) {
        remove_component();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_fit_design")]
    public void ui_fit_design(Gtk.Activatable activatable) {
        fit_design();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_show_grid")]
    public void ui_show_grid(Gtk.CheckMenuItem menuItem) {
        showGrid = menuItem.active;
        update_display();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_live_scroll")]
    public void ui_live_scroll(Gtk.CheckMenuItem menuItem) {
        liveScrollUpdate = menuItem.active;
        update_display();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_shadow_component")]
    public void ui_shadow_component(Gtk.CheckMenuItem menuItem) {
        shadowComponent = menuItem.active;
        update_display();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_highlight_errors")]
    public void ui_highlight_errors(Gtk.CheckMenuItem menuItem) {
        highlightErrors = menuItem.active;
        update_display();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_colour_backgrounds")]
    public void ui_colour_backgrounds(Gtk.CheckMenuItem menuItem) {
        colourBackgrounds = menuItem.active;
        update_display();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_show_hints")]
    public void ui_show_hints(Gtk.CheckMenuItem menuItem) {
        showHints = menuItem.active;
        update_display();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_autobind")]
    public void ui_autobind(Gtk.CheckMenuItem menuItem) {
        autoBind = menuItem.active;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_run")]
    public void ui_run(Gtk.Activatable activatable) {
        run_circuit();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_check")]
    public void ui_check(Gtk.Activatable activatable) {
        validate_circuit();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_set_root")]
    public void ui_set_root(Gtk.Activatable activatable) {
        set_root_component();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_customise")]
    public void ui_customise(Gtk.Activatable activatable) {
        customise_component();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_project_statistics")]
    public void ui_project_statistics(Gtk.Activatable activatable) {
        display_statistics();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_project_properties")]
    public void ui_project_properties(Gtk.Activatable activatable) {
        configure_project();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_about")]
    public void ui_about(Gtk.Activatable activatable) {
        show_about();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_mouse_down")]
    public bool ui_mouse_down(Gtk.Widget widget, Gdk.EventButton event) {
        mouse_down(event);
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_mouse_move")]
    public bool ui_mouse_move(Gtk.Widget widget, Gdk.EventMotion event) {
        mouse_move(event);
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_mouse_up")]
    public bool ui_mouse_up(Gtk.Widget widget, Gdk.EventButton event) {
        mouse_up(event);
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_render")]
    public bool ui_render(Gtk.Widget widget, Cairo.Context context) {
        render_design(context);
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT designer_window_ui_display_configure")]
    public bool ui_display_configure(Gtk.Widget widget, Gdk.Event event) {
        gridCache = null;
        update_display();
        return false;
    }

    /**
     * Updates the custom components listed in the "Windows" menu and
     * custom component insert menu.
     */
    public void update_custom_menu() {

        if (toolCustomsMenu != null) {
            toolCustomsMenu.destroy();
        }
        if (menuWindowsMenu != null) {
            menuWindowsMenu.destroy();
        }

        toolCustomsMenu = new Gtk.Menu();
        menuWindowsMenu = new Gtk.Menu();

        if (hasProject) {

            toolCustomsMenuComponents = {};
            menuWindowsComponents = {};

            for (int i = 0; i < project.customComponentDefs.length; i++) {
                weak CustomComponentDef customComponentDef = project.customComponentDefs[i];

                Gtk.MenuItem toolMenuItem = new Gtk.MenuItem.with_label(customComponentDef.name);
                toolCustomsMenu.append(toolMenuItem);
                toolMenuItem.activate.connect(
                    () => {
                        if (hasDesigner) {
                            deselect_tools();
                            mouseMode = MouseMode.INSERT;
                            designer.set_insert_component(customComponentDef);
                            update_overlay();
                        }
                    }
                );
                if (hasDesigner) {
                    if (customComponentDef == designer.customComponentDef) {
                        toolMenuItem.set_sensitive(false);
                    }
                }
                toolCustomsMenuComponents += toolMenuItem;

                Gtk.MenuItem windowMenuItem = new Gtk.MenuItem.with_label(customComponentDef.name);
                menuWindowsMenu.append(windowMenuItem);
                windowMenuItem.activate.connect(
                    () => {
                        project.reopen_window_from_component(customComponentDef);
                    }
                );
                menuWindowsComponents += windowMenuItem;
            }
        }

        toolCustoms.set_menu(toolCustomsMenu);
        menuWindows.set_submenu(menuWindowsMenu);

        toolCustomsMenu.show_all();
        menuWindowsMenu.show_all();
    }


    /**
     * Updates the plugin components listed in the "Windows" menu and
     * plugin component insert menu.
     */
    public void update_plugin_menu() {
        if (toolPluginsMenu != null) {
            toolPluginsMenu.destroy();
        }
        if (menuFileRemoveplugincomponentMenu != null) {
            menuFileRemoveplugincomponentMenu.destroy();
        }
        menuFileRemoveplugincomponent.set_sensitive(false);

        toolPluginsMenu = new Gtk.Menu();
        menuFileRemoveplugincomponentMenu = new Gtk.Menu();

        if (hasProject) {

            toolPluginsMenuComponents = {};
            menuFileRemoveplugincomponentComponents = {};

            for (int i = 0; i < project.pluginComponentDefs.length; i++) {
                // These must not interfere with the freeing order of plugins.
                weak PluginComponentDef pluginComponentDef = project.pluginComponentDefs[i];

                Gtk.MenuItem toolMenuItem = new Gtk.MenuItem.with_label(pluginComponentDef.name);
                toolPluginsMenu.append(toolMenuItem);
                toolMenuItem.activate.connect(
                    () => {
                        if (hasDesigner) {
                            deselect_tools();
                            mouseMode = MouseMode.INSERT;
                            designer.set_insert_component(pluginComponentDef);
                            update_overlay();
                        }
                    }
                );
                toolPluginsMenuComponents += toolMenuItem;

                Gtk.MenuItem removeplugincomponentMenuItem = new Gtk.MenuItem.with_label(pluginComponentDef.name);
                menuFileRemoveplugincomponentMenu.append(removeplugincomponentMenuItem);
                removeplugincomponentMenuItem.activate.connect(
                    () => {
                        remove_plugin_component(pluginComponentDef);
                    }
                );
                menuFileRemoveplugincomponentComponents += removeplugincomponentMenuItem;
                menuFileRemoveplugincomponent.set_sensitive(true);
            }
        }

        toolPlugins.set_menu(toolPluginsMenu);
        menuFileRemoveplugincomponent.set_submenu(menuFileRemoveplugincomponentMenu);

        toolPluginsMenu.show_all();
        menuFileRemoveplugincomponentMenu.show_all();
    }

    private void deselect_tools() {
        hiddenRadioToolButton.active = true;
    }

    public void update_error_mode(bool error) {
        if (error) {
            colourBackgrounds = false;
        } else {
            colourBackgrounds = menuViewColourbackgrounds.active;
        }
    }

    private void fit_design() {
        if (hasDesigner) {
            if (designer.hasComponent) {
                Gtk.Allocation areaAllocation;
                controller.get_allocation(out areaAllocation);
                int width = areaAllocation.width;
                int height = areaAllocation.height;

                int rightBound;
                int downBound;
                int leftBound;
                int upBound;

                int boundWidth;
                int boundHeight;

                float altZoom;

                designer.customComponentDef.get_design_bounds(out rightBound, out downBound, out leftBound, out upBound);

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
                update_display();
            }
        }
    }

    /**
     * Handles user request to open the Customiser.
     */
    private void customise_component() {
        if (hasDesigner) {
            designer.customise_component();
        }
    }

    private void configure_project() {
        if (hasProject) {
            project.configure();
            project.update_titles();
        }
    }

    private void display_statistics() {
        if (hasProject) {
            CircuitInformation circuitInformation = new CircuitInformation(project);

            if (circuitInformation.summary != "") {
                BasicDialog.information(window, "Statistics:\n\n" + circuitInformation.summary);
            }
        }
    }

    /**
     * Handles mouse button down in the work area. Records mouse
     * (drag) starting point.
     */
    private void mouse_down(Gdk.EventButton event) {
        mouseIsDown = true;

        xMouseStart = (int)(event.x);
        yMouseStart = (int)(event.y);
    }

    private void mouse_move(Gdk.EventMotion event) {
        Gtk.Allocation areaAllocation;
        controller.get_allocation(out areaAllocation);
        int width = areaAllocation.width;
        int height = areaAllocation.height;

        int xCentre = width / 2;
        int yCentre = height / 2;
        int xStart = xMouseStart - xCentre;
        int yStart = yMouseStart - yCentre;
        int xEnd = (int)event.x - xCentre;
        int yEnd = (int)event.y - yCentre;
        int yDiff = yEnd - yStart;

        int xBoardStart = (int)((float)xStart / zoom + (float)xView);
        int yBoardStart = (int)((float)yStart / zoom + (float)yView);
        int xBoardEnd = (int)((float)xEnd / zoom + (float)xView);
        int yBoardEnd = (int)((float)yEnd / zoom + (float)yView);

        int xBoardDiff = xBoardEnd - xBoardStart;
        int yBoardDiff = yBoardEnd - yBoardStart;

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
                xView -= xBoardDiff;
                yView -= yBoardDiff;
                xMouseStart = (int)event.x;
                yMouseStart = (int)event.y;
                gridCache = null;
                update_display();
            }
            break;
        case MouseMode.ZOOM:
            if (mouseIsDown && liveScrollUpdate) {
                if (yDiff > 0) {
                    zoom *= 1.0f + ((float)yDiffAbs / (float)height);
                } else {
                    zoom /= 1.0f + ((float)yDiffAbs / (float)height);
                }
                xMouseStart = (int)event.x;
                yMouseStart = (int)event.y;
                gridCache = null;
                update_display();
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
                stderr.printf("y\n");
                update_overlay();
            }
            break;
        }
    }

    /**
     * Handles mouse button up in the work area. Performs an action
     * which is determined by //mouseMode//.
     */
    private void mouse_up(Gdk.EventButton event) {
        mouseIsDown = false;

        if (project != null) {
            if (project.running) {
                stderr.printf ("Cannot edit running circuit!\n");
                return;
            }
        }

        Gtk.Allocation areaAllocation;
        controller.get_allocation(out areaAllocation);
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
        stderr.printf("Interact @ (%i, %i) - (%i, %i)\n", xBoardStart, yBoardStart, xBoardEnd, yBoardEnd);

        int xBoardDiff = xBoardEnd - xBoardStart;
        int yBoardDiff = yBoardEnd - yBoardStart;

        int xDiffAbs = (xDiff > 0) ? xDiff : -xDiff;
        int yDiffAbs = (yDiff > 0) ? yDiff : -yDiff;


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
                designer.select_components(xBoardEnd, yBoardEnd, false);
                designer.select_wires(xBoardEnd, yBoardEnd, false, true);
                designer.select_annotations(xBoardEnd, yBoardEnd, false);
            }
            break;
        case MouseMode.MOVE:
            if (hasDesigner && hasProject) {
                designer.select_components(xBoardStart, yBoardStart, false);
                designer.select_wires(xBoardStart, yBoardStart, false, true);
                designer.select_annotations(xBoardStart, yBoardStart, false);
                designer.move_components(xBoardDiff, yBoardDiff, false, autoBind);
                designer.move_wires(xBoardDiff, yBoardDiff, false, autoBind);
                designer.move_annotations(xBoardDiff, yBoardDiff, false);
            }
            break;
        case MouseMode.DELETE:
            if (hasDesigner && hasProject) {
                designer.delete_components(xBoardEnd, yBoardEnd);
                designer.delete_wires(xBoardEnd, yBoardEnd);
                designer.delete_tags(xBoardEnd, yBoardEnd);
                designer.delete_annotations(xBoardEnd, yBoardEnd);
            }
            break;
        case MouseMode.ADJUST:
            if (hasDesigner && hasProject) {
                designer.adjust_components(xBoardEnd, yBoardEnd, autoBind);
                designer.adjust_annotations(xBoardEnd, yBoardEnd);
                designer.adjust_wires(xBoardEnd, yBoardEnd);
            }
            break;
        case MouseMode.ANNOTATE:
            if (hasDesigner && hasProject) {
                designer.add_annotation(xBoardEnd, yBoardEnd, "Enter Text Here", 12);
                designer.adjust_annotations(xBoardEnd, yBoardEnd);
            }
            break;
        case MouseMode.WIRE:
            if (hasDesigner && hasProject) {
                designer.draw_wire(xBoardEnd, yBoardEnd, diagonalThreshold, autoBind);
            }
            break;
        case MouseMode.BIND:
            if (hasDesigner && hasProject) {
                int boundWires = 0;
                int connectedComponents = 0;
                boundWires = designer.bind_wire(xBoardEnd, yBoardEnd);
                connectedComponents = designer.connect_component(xBoardEnd, yBoardEnd);

                if (boundWires == 1 && connectedComponents == 0) {
                    designer.unbind_wire(xBoardEnd, yBoardEnd);
                    designer.disconnect_component(xBoardEnd, yBoardEnd);
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
                designer.invert_pin(xBoardEnd, yBoardEnd);
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

                designer.add_componentInst(xBoardStart, yBoardStart, direction, autoBind);
            }
            break;
        case MouseMode.ORIENTATE:
            if (hasDesigner && hasProject) {
                designer.select_components(xBoardStart, yBoardStart, false);
                if (xDiff == 0 && yDiff == 0) {
                    designer.flip_component(autoBind);
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

                    designer.orientate_component(direction, autoBind);
                }
            }
            break;
        }

        update_display();
    }

    /**
     * Updates the window title to display identification about the
     * component being viewed.
     */
    public void update_title() {
        if (hasProject) {
            if (hasDesigner) {
                if (designer.hasComponent) {
                    if (componentFileName != "") {
                        string shortFileName = componentFileName;
                        if (shortFileName.last_index_of(GLib.Path.DIR_SEPARATOR_S) != -1) {
                            shortFileName = shortFileName[shortFileName.last_index_of(GLib.Path.DIR_SEPARATOR_S)+1 : shortFileName.length];
                        }
                        designer.set_name(shortFileName);
                    } else {
                        designer.set_name("Not saved - " + designer.customComponentDef.name);
                    }
                    window.set_title(Core.programName + " - " + project.name + " - " + designer.designerName);
                } else {
                    window.set_title(Core.programName + " - " + project.name + " - " + designer.designerName);
                }
            } else {
                window.set_title(Core.programName + " - " + project.name);
            }
        } else {
            window.set_title(Core.programName);
        }
    }

    /**
     * Prompts the user to open a file (when File>>Open is selected) and
     * loads the file.
     */
    private bool open_component() {

        Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog(
            "Load Component",
            window,
            Gtk.FileChooserAction.OPEN,
            "_Cancel",
            Gtk.ResponseType.CANCEL,
            "_Open",
            Gtk.ResponseType.ACCEPT
        );

        fileChooser.add_filter(sscFileFilter);
        fileChooser.add_filter(anyFileFilter);

        if (fileChooser.run() == Gtk.ResponseType.ACCEPT) {
            if (project.reopen_window_from_file(fileChooser.get_filename()) == 0) {
                stderr.printf("Load Component From: %s\n", fileChooser.get_filename());
                new_designer().load_component(fileChooser.get_filename());
            }
            fileChooser.destroy();
        } else {
            fileChooser.destroy();
            return false;
        }

        return false;
    }

    /**
     * Prompts the user to open a file (when "File>>Open Plugin Component" is selected) and
     * loads the file as a plugin component.
     */
    private bool open_plugin_component() {
        if (project.plugins_allowed() == false) {
            return false;
        }

        Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog(
            "Load Component",
            window,
            Gtk.FileChooserAction.OPEN,
            "_Cancel",
            Gtk.ResponseType.CANCEL,
            "_Open",
            Gtk.ResponseType.ACCEPT
        );

        fileChooser.add_filter(ssxFileFilter);
        fileChooser.add_filter(anyFileFilter);

        try {
            fileChooser.add_shortcut_folder(Config.resourcesDir + "plugins");
        } catch {
            stderr.printf("Cannot add plugins shortcut %s.\n", Config.resourcesDir + "plugins");
        }

        if (fileChooser.run() == Gtk.ResponseType.ACCEPT) {
            stderr.printf("Load Plugin Component From: %s\n", fileChooser.get_filename());
            project.load_plugin_component(fileChooser.get_filename());
            project.update_plugin_menus();
        }
        fileChooser.destroy();

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
            Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog(
                "Save Component",
                window,
                Gtk.FileChooserAction.SAVE,
                "_Cancel",
                Gtk.ResponseType.CANCEL,
                "_Save",
                Gtk.ResponseType.ACCEPT
            );

            fileChooser.add_filter(sscFileFilter);
            fileChooser.add_filter(anyFileFilter);
            fileChooser.do_overwrite_confirmation = true;

            bool stillChoosing = true;
            while (stillChoosing) {
                if (fileChooser.run() == Gtk.ResponseType.ACCEPT) {
                    componentFileName = fileChooser.get_filename();
                    if ("." in componentFileName) {
                        stderr.printf("File extension already given\n");
                    } else {
                        if (fileChooser.filter == sscFileFilter) {
                            componentFileName += ".ssc";
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
                    fileChooser.destroy();
                    return false;
                }
            }
            fileChooser.destroy();
        }

        stderr.printf("Save Component To: %s\n", componentFileName);

        designer.save_component(componentFileName);

        update_title();

        return false;
    }

    private bool open_project() {

        Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog(
            "Load Project",
            window,
            Gtk.FileChooserAction.OPEN,
            "_Cancel",
            Gtk.ResponseType.CANCEL,
            "_Open",
            Gtk.ResponseType.ACCEPT
        );

        fileChooser.add_filter(sspFileFilter);
        fileChooser.add_filter(anyFileFilter);

        if (fileChooser.run() == Gtk.ResponseType.ACCEPT) {
            stderr.printf("Load Project From: %s\n", fileChooser.get_filename());
            load_project(fileChooser.get_filename());
            fileChooser.destroy();
        } else {
            fileChooser.destroy();
            return false;
        }

        return false;
    }

    private bool save_project(bool saveAs) {
        do_save_project(saveAs);

        return false;
    }

    private bool do_save_project(bool saveAs) {
        if (!hasProject) {
            return false;
        }

        if (project.filename == "" || saveAs) {
            Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog(
                "Save Project",
                window,
                Gtk.FileChooserAction.SAVE,
                "_Cancel",
                Gtk.ResponseType.CANCEL,
                "_Save",
                Gtk.ResponseType.ACCEPT
            );

            fileChooser.add_filter(sspFileFilter);
            fileChooser.add_filter(anyFileFilter);
            fileChooser.do_overwrite_confirmation = true;

            bool stillChoosing = true;
            while (stillChoosing) {
                if (fileChooser.run() == Gtk.ResponseType.ACCEPT) {
                    project.filename = fileChooser.get_filename();
                    if ("." in project.filename) {
                        stderr.printf("File extension already given\n");
                    } else {
                        if (fileChooser.filter == sspFileFilter) {
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
                    fileChooser.destroy();
                    return false;
                }
            }
            fileChooser.destroy();
        }

        stderr.printf("Save Project To: %s\n", project.filename);

        project.save(project.filename);

        update_title();

        return true;
    }

    /**
     * Creates a new component in this window. Does not open a new
     * window if there is already a component.
     */
    private void new_component() {
        if (hasDesigner && hasProject) {
            designer.set_component(project.new_component());
        }
        update_custom_menu();
        update_plugin_menu();
        update_title();
        update_display();
    }

    private void set_component(CustomComponentDef customComponentDef) {
        if (hasDesigner && hasProject) {
            designer.set_component(customComponentDef);
            componentFileName = designer.customComponentDef.filename;
        }
        update_custom_menu();
        update_plugin_menu();
        update_title();
        update_display();
    }

    /**
     * Loads a component from a file in this window. Does not open a new
     * window if there is not already a component.
     */
    private void load_component(string filename) {
        if (hasDesigner && hasProject) {
            designer.set_component(project.load_component(filename));
            if (!designer.hasComponent) {
                project.unregister_designer(designer);
                hasDesigner = false;
            }
            componentFileName = filename;
        }
        update_custom_menu();
        update_plugin_menu();
        update_title();
        update_display();
    }

    /**
     * Creates a new Designer for the current project. Returns the
     * window for the Designer. If there is not already a component in
     * this window, this window will be used and returned.
     */
    private DesignerWindow new_designer() {
        if (hasDesigner) {
            if (designer.hasComponent) {
                return new DesignerWindow.with_new_designer(project);
            } else {
                return this;
            }
        }
        designer = project.new_designer(this);
        hasDesigner = true;
        update_title();
        update_display();

        return this;
    }

    /**
     * Creates a new Project. If there is not already a project in this
     * window, this window will be used, else a new window will be
     * created.
     */
    private void new_project() {
        if (hasProject) {
            new DesignerWindow.with_new_project();
            return;
        }
        project = new Project();
        hasProject = true;
        update_title();
    }

    private void load_project(string filename) {
        if (hasProject) {
            new DesignerWindow.with_project_from_file(filename);
            return;
        }
        try {
            project = new Project.load(filename);
            hasProject = true;
            CustomComponentDef defaultComponent = project.get_default_component();
            if (defaultComponent != null) {
                new_designer();
                set_component(defaultComponent);
            }
            update_title();
        } catch (ProjectLoadError error) {
            stderr.printf("Error loading project: %s\n", error.message);
        }
    }

    /**
     * Displays the about dialog (Help>>About). Displays information
     * about the SmartSim software package.
     */
    private void show_about() {
        Gtk.AboutDialog aboutDialog = new Gtk.AboutDialog();
        aboutDialog.set_logo_icon_name("smartsim");
        aboutDialog.program_name = Core.programName;
        aboutDialog.title = "About " + Core.programName;
        aboutDialog.version = Core.versionString;
        aboutDialog.comments = "A logic circuit designer and simulator.";
        aboutDialog.authors = Core.authorsStrings;
        aboutDialog.copyright = Core.copyrightString;
        aboutDialog.license_type = Core.licenseType;
        aboutDialog.license = Core.licenseName + "\n\n" + Core.shortLicenseText;
        aboutDialog.website = Core.websiteString;
        aboutDialog.website_label = "SmartSim Website - Software and Documentation";
        aboutDialog.wrap_license = false;
        aboutDialog.run();
        aboutDialog.destroy();
    }

    /**
     * Called when the user clicks File>>Page Setup. Opens a dialog for
     * configuring the page setup for printing.
     */
    public void print_page_setup() {
        pageSetup = Gtk.print_run_page_setup_dialog(window, pageSetup, printSettings);
    }

    /**
     * Called when the user clicks File>>Print. Prompts the user with
     * printing options and prints off the current work area view.
     */
    public void print() {
        int width, height;
        Gtk.Allocation areaAllocation;

        display.get_allocation(out areaAllocation);
        width = areaAllocation.width;
        height = areaAllocation.height;

        if (!hasDesigner) {
            stderr.printf ("Error: Cannot print without designer\n");
            return;
        } else {
            if (!designer.hasComponent) {
                stderr.printf("Error: Cannot print without component (but found designer)\n");
                return;
            }
        }

        Gtk.PrintOperation printOperation
            = new Gtk.PrintOperation();

        printOperation.set_print_settings(printSettings);
        printOperation.set_default_page_setup(pageSetup);
        printOperation.set_n_pages(1);
        printOperation.set_unit(Gtk.Unit.POINTS);

        printOperation.draw_page.connect(print_render);

        Gtk.PrintOperationResult result;

        try {
            result = printOperation.run(Gtk.PrintOperationAction.PRINT_DIALOG, window);
        } catch {
            stderr.printf("Print operation failed!\n");
            return;
        }

        if (result == Gtk.PrintOperationResult.APPLY) {
            printSettings = printOperation.get_print_settings();
        }
    }

    public void update_overlay() {
        if (window.visible) {
            display.queue_draw();
        }
    }

    public void update_display() {
        staticCache = null;

        if (window.visible) {
            display.queue_draw();
        }
    }

    public void render_overlay(Cairo.Context context) {
        int width, height;
        Gtk.Allocation areaAllocation;

        display.get_allocation(out areaAllocation);
        width = areaAllocation.width;
        height = areaAllocation.height;

        context.translate(width / 2, height / 2);
        context.scale(zoom, zoom);
        context.translate(-xView, -yView);

        context.set_source_rgb(0, 0, 0);
        context.set_line_width(1);

        if (shadowComponent && mouseMode == MouseMode.INSERT && !mouseIsDown) {
            designer.shadowComponentInst.render(context, showHints, false, colourBackgrounds);
        }
    }

    /**
     * Refreshes the work area display.
     */
    public void render_design(Cairo.Context displayContext) {
        int width, height;
        Gtk.Allocation areaAllocation;

        display.get_allocation(out areaAllocation);
        width = areaAllocation.width;
        height = areaAllocation.height;

        // Render off screen for performance and for caching.
        Cairo.Surface offScreenSurface = new Cairo.Surface.similar(displayContext.get_target(), Cairo.Content.COLOR, width, height);
        Cairo.Context context = new Cairo.Context(offScreenSurface);

        if (staticCache != null) {
            context.set_source_surface(staticCache, 0, 0);
            context.paint();
        } else {
            if (!hasDesigner) {
                context.translate(width / 2, height / 2);
                context.scale(zoom, zoom);
                context.translate(-xView, -yView);

                Cairo.TextExtents textExtents;
                context.select_font_face("", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
                context.set_font_size(16.0);
                context.text_extents("Welcome to " + Core.programName + " v" + Core.shortVersionString, out textExtents);
                context.translate(-textExtents.width / 2, +textExtents.height / 2);
                context.set_source_rgb(0.75, 0.75, 0.75);
                context.paint();

                context.set_source_rgb(0, 0, 0);
                context.show_text("Welcome to " + Core.programName + " v" + Core.shortVersionString);
                context.stroke();
                context.select_font_face("", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
            } else {
                context.set_line_width(1);

                if (showGrid) {
                    if (gridCache == null) {
                        gridCache = new Cairo.Surface.similar(context.get_target(), context.get_target().get_content(), width, height);
                        Cairo.Context gridContext = new Cairo.Context(gridCache);

                        gridContext.set_source_rgb(1, 1, 1);
                        gridContext.paint();

                        float spacing = zoom * gridSize;

                        while (spacing < 2) {
                            spacing *= gridSize;
                        }

                        float y = ((height / 2) - (float)yView * zoom) % (spacing);
                        float x = ((width  / 2) - (float)xView * zoom) % (spacing);

                        gridContext.set_source_rgba(0, 0, 0, 0.5);

                        gridContext.set_dash({1.0, spacing - 1.0}, 0);

                        for (; y < height; y += spacing) {
                            gridContext.move_to(x, y);
                            gridContext.line_to(width, y);
                            gridContext.stroke();
                        }

                        spacing *= 4;

                        y = ((height / 2) - (float)yView * zoom) % (spacing);
                        x = ((width  / 2) - (float)xView * zoom) % (spacing);

                        gridContext.set_source_rgba (0, 0, 0, 1.0);

                        gridContext.set_dash({1.0, (spacing) - 1.0}, 0);

                        for (; y < height; y += spacing) {
                            gridContext.move_to(x, y);
                            gridContext.line_to(width, y);
                            gridContext.stroke();
                        }

                        gridContext.set_dash(null, 0);

                        gridContext.set_source_rgba(0, 0, 0, 0.5);

                        x = (width / 2) - xView * zoom;
                        y = (height / 2) - yView * zoom;

                        gridContext.move_to((x - 10 * zoom), (y)            );
                        gridContext.line_to((x + 10 * zoom), (y)            );
                        gridContext.stroke();
                        gridContext.move_to((x)            , (y - 10 * zoom));
                        gridContext.line_to((x)            , (y + 10 * zoom));
                        gridContext.stroke();

                        gridContext.set_source_rgba(0, 0, 0, 1);
                    }

                    context.set_source_surface(gridCache, 0, 0);
                    context.paint();
                } else {
                    context.set_source_rgb(1, 1, 1);
                    context.paint();
                }

                context.translate(width / 2, height / 2);
                context.scale(zoom, zoom);
                context.translate(-xView, -yView);

                context.set_source_rgb(0, 0, 0);

                designer.render(context, showHints, highlightErrors, colourBackgrounds);
            }

            // Cache the non-overlay render, so that we can reuse it when the overlay changes.
            staticCache = offScreenSurface;
        }

        // Apply temporary off-screen buffer to actual display.
        displayContext.set_source_surface(offScreenSurface, 0, 0);
        displayContext.paint();

        render_overlay(displayContext);
    }

    /**
     * Called by //print//. Renders the circuit for printing.
     */
    public void print_render(Gtk.PrintContext printContext, int page_nr) {
        int width, height;
        Gtk.Allocation areaAllocation;

        display.get_allocation(out areaAllocation);
        width = areaAllocation.width;
        height = areaAllocation.height;

        int pageWidth = (int)printContext.get_width();
        int pageHeight = (int)printContext.get_height();
        double pageZoom;

        Cairo.Context context = printContext.get_cairo_context();

        printContext.get_cairo_context();

        context.set_source_rgb(1, 1, 1);
        context.paint();

        context.set_line_width(1);

        pageZoom = zoom;
        if (pageWidth / width > pageHeight / height) {
            pageZoom = pageZoom * (double)pageHeight / (double)height;
        } else {
            pageZoom = pageZoom * (double)pageWidth / (double)width;
        }

        stderr.printf("Printing design (render size = %i x %i, scale = %f)\n", pageWidth, pageHeight, pageZoom);

        context.translate(pageWidth / 2, pageHeight / 2);
        context.scale(pageZoom, pageZoom);
        context.translate(-xView, -yView);

        designer.render(context, false, false, colourBackgrounds);
    }

    public void export_png() {
        ImageExporter.export_png(file_render);
    }

    public void export_pdf() {
        ImageExporter.export_pdf(file_render);
    }

    public void export_svg() {
        ImageExporter.export_svg(file_render);
    }

    /**
     * Passed to ImageExporter as a delegate and called by an export
     * function to render to a file.
     */
    private void file_render(string filename, ImageExporter.ImageFormat imageFormat, double resolution) {
        Cairo.Surface surface;
        Gtk.Allocation areaAllocation;
        display.get_allocation(out areaAllocation);
        int width, height;
        width = areaAllocation.width;
        height = areaAllocation.height;

        int imageWidth = (int)((double)width * resolution);
        int imageHeight = (int)((double)height * resolution);
        double imageZoom = zoom * resolution;

        switch (imageFormat) {
        case ImageExporter.ImageFormat.PNG_RGB:
            surface = new Cairo.ImageSurface(Cairo.Format.RGB24, imageWidth, imageHeight);
            break;
        case ImageExporter.ImageFormat.PNG_ARGB:
            surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, imageWidth, imageHeight);
            break;
        case ImageExporter.ImageFormat.PDF:
            surface = new Cairo.PdfSurface(filename, imageWidth, imageHeight);
            break;
        case ImageExporter.ImageFormat.SVG:
        case ImageExporter.ImageFormat.SVG_CLEAR:
            surface = new Cairo.SvgSurface(filename, imageWidth, imageHeight);
            break;
        default:
            stderr.printf("Error: Unknown Export Format!\n");
            return;
        }

        Cairo.Context context = new Cairo.Context(surface);

        switch (imageFormat) {
        case ImageExporter.ImageFormat.PNG_ARGB:
        case ImageExporter.ImageFormat.SVG_CLEAR:
            context.set_operator(Cairo.Operator.SOURCE);
            context.set_source_rgba(0, 0, 0, 0);
            context.paint();
            context.set_operator(Cairo.Operator.OVER);
            break;
        default:
            context.set_source_rgb(1, 1, 1);
            context.paint();
            break;
        }

        context.set_line_width(1);

        stderr.printf("Exporting design (render size = %i x %i, scale = %f)\n", imageWidth, imageHeight, imageZoom);

        context.translate(imageWidth / 2, imageHeight / 2);
        context.scale(imageZoom, imageZoom);
        context.translate(-xView, -yView);

        designer.render(context, false, false, colourBackgrounds);

        switch (imageFormat) {
        case ImageExporter.ImageFormat.PNG_RGB:
        case ImageExporter.ImageFormat.PNG_ARGB:
            surface.write_to_png(filename);
            break;
        }
    }

    /**
     * Hides the window and unregisters it from the list of visible
     * DesignerWindows. Destroys only if there is no designer.
     */
    private bool close_window() {
        if (hasProject) {
            if (count_project_windows(project) == 1) {
                if (!comfirm_close()) {
                    return false;
                }
            }
        }

        if (hasDesigner) {
            window.hide();
            unregister_designerwindow();
            gridCache = null;
        } else {
            force_destroy_window();
        }
        return true;
    }

    private bool comfirm_close() {
        Gtk.MessageDialog messageDialog = new Gtk.MessageDialog(
            window,
            Gtk.DialogFlags.MODAL,
            Gtk.MessageType.QUESTION,
            Gtk.ButtonsType.NONE,
            "You are about to close project \"%s\".\nDo you wish to save this project?",
            project.name
        );

        messageDialog.add_button("_Yes", Gtk.ResponseType.YES);
        messageDialog.add_button("_No", Gtk.ResponseType.NO);
        messageDialog.add_button("_Cancel", Gtk.ResponseType.CANCEL);

        switch (messageDialog.run()) {
        case Gtk.ResponseType.CANCEL:
            messageDialog.destroy();
            return false;
        case Gtk.ResponseType.NO:
            messageDialog.destroy();
            return true;
        case Gtk.ResponseType.YES:
            messageDialog.destroy();
            return do_save_project(false);
        default:
            messageDialog.destroy();
            return false;
        }
    }

    public void force_destroy_window() {
        stderr.printf("Designer Window destroyed (not hidden)\n");

        project = null;
        designer = null;
        hasDesigner = false;
        hasProject = false;

        update_custom_menu();
        update_plugin_menu();

        unregister_designerwindow();

        window.destroy();
    }

    private bool remove_component() {
        if (!hasDesigner) {
            return false;
        }

        if (BasicDialog.ask_proceed(window, "Are you sure you want to remove this component from the project?\nAll unsaved progress will be lost.", "Remove", "Keep") == Gtk.ResponseType.OK) {
            if (project.remove_component(designer.customComponentDef) == 0) {
                project.update_custom_menus();
                project.update_plugin_menus();
                project.unregister_designer(designer);
                hasDesigner = false;
                update_title();
                update_display();
            }
        }

        return false;
    }

    private bool remove_plugin_component(PluginComponentDef pluginComponentDef) {
        if (!hasProject) {
            return false;
        }

        if (BasicDialog.ask_proceed(window, "Are you sure you want to remove this plugin component from the project?\nThis will only dissociate the plugin with the project. The plugin will remain loaded until SmartSim is closed.\n", "Remove", "Keep") == Gtk.ResponseType.OK) {
            if (project.remove_plugin_component(pluginComponentDef) == 0) {
                project.update_plugin_menus();
            }
        }

        return false;
    }

    /**
     * Called when user clicks Run>>Check circuit validity. Shows a
     * message dialog stating whether or not the circuit is valid.
     */
    private void validate_circuit() {
        CompiledCircuit compiledCircuit = project.validate();

        if (compiledCircuit == null) {
            stderr.printf("Cannot validate.\n");
            return;
        }

        if (compiledCircuit.errorMessage != "") {
            stderr.printf("Circuit is invalid!\n");
            stderr.flush();
            stderr.printf("Error Messages:\n%s\n", compiledCircuit.errorMessage);
        } else {
            stderr.printf("Circuit validated with no errors\n");
        }

        update_display();
    }

    /**
     * Called when the user clicks Run>>Run. Starts the circuit
     * simulating.
     */
    private void run_circuit() {
        if (project.running) {
            return;
        }

        bool startNow = !menuRunStartpaused.active;
        CompiledCircuit compiledCircuit = project.run(startNow);

        if (compiledCircuit == null) {
            stderr.printf("Run failure.\n");

            colourBackgrounds = false;

            update_display();

            return;
        }

        if (compiledCircuit.errorMessage != "") {
            stderr.printf("Circuit is invalid!\n");
            stderr.flush();
            stderr.printf("Error Messages:\n%s\n", compiledCircuit.errorMessage);

            colourBackgrounds = false;
        } else {
            stderr.printf("Circuit started with no errors\n");

            colourBackgrounds = menuViewColourbackgrounds.active;
        }

        update_display();
    }

    /**
     * Called when the user clicks Component>>Set as root. Sets the
     * component open in the designer as root.
     */
    public void set_root_component() {
        if (hasDesigner && hasProject) {
            project.set_root_component (designer.customComponentDef);
        }
    }

    public bool visible {
        public get {
            return window.visible;
        }
    }
    public void show() {
        window.show_all();
    }
    /**
     * Bring window to the front.
     */
    public void present() {
        window.present();
    }
    /**
     * Access the underlying Gtk.Window
     *
     * Use only when you need to use the window as a dialog parent.
     * Currently in used for a transition period.
     */
    public Gtk.Window gtk_window {
        get {return window;}
    }

    /**
     * Registers the window.
     */
    private void register_designerwindow() {
        DesignerWindow.register(this);
    }

    /**
     * Unregisters the window.
     */
    private void unregister_designerwindow() {
        DesignerWindow.unregister(this);
    }

    ~DesignerWindow() {
        stderr.printf("Designer Window Destroyed\n");
    }
}
