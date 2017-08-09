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
 *   Filename: simulatorwindow.vala
 *
 *   Copyright Ashley Newson 2013
 */


/**
 * Interface for the user when running a circuit.
 *
 * Allows a user to control and explore a circuit, using the
 * CompiledCircuit as a back-end.
 */
public class SimulatorWindow {
    private Gtk.Window window;
    private Gtk.ToggleToolButton toolRun;
    private Gtk.SpinButton toolSpeedSpin;
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

    private Cairo.Surface renderCache = null;
    private bool inhibitRender = false;

    private bool autoFitDesign = true;



    TimingDiagram timingDiagram;



    /**
     * Creates a new Simulator window associated with the
     * CompiledCircuit //compiledCircuit//.
     */
    public SimulatorWindow(CompiledCircuit compiledCircuit) {
        this.compiledCircuit = compiledCircuit;
        runState = RunState.PAUSED;
        populate();
    }

    ~SimulatorWindow() {
        timingDiagram.close_diagram();
    }

    /**
     * Populate the window with widgets.
     */
    public void populate() {
        stderr.printf("Simulation Window Created\n");

        try {
            Gtk.Builder builder = new Gtk.Builder();
            try {
                builder.add_from_file(Config.resourcesDir + "ui/simulator.ui");
            } catch (FileError e) {
                throw new UICommon.LoadError.MISSING_RESOURCE(e.message);
            } catch (Error e) {
                throw new UICommon.LoadError.BAD_RESOURCE(e.message);
            }

            // Connect basic signals
            builder.connect_signals(this);

            // Get references to useful things
            window = UICommon.get_object_critical(builder, "window") as Gtk.Window;
            toolSpeedSpin = UICommon.get_object_critical(builder, "speed") as Gtk.SpinButton;
            toolRun = UICommon.get_object_critical(builder, "tool_run") as Gtk.ToggleToolButton;
            controller = UICommon.get_object_critical(builder, "controller") as Gtk.EventBox;
            display = UICommon.get_object_critical(builder, "display") as Gtk.DrawingArea;

            // Connect tools
            connect_tool(builder, "tool_scroll", MouseMode.SCROLL);
            connect_tool(builder, "tool_zoom", MouseMode.ZOOM);
            connect_tool(builder, "tool_context", MouseMode.CONTEXT);
            connect_tool(builder, "tool_interact", MouseMode.INTERACT);
            connect_tool(builder, "tool_explore", MouseMode.EXPLORE);
            connect_tool(builder, "tool_watch", MouseMode.WATCH);

            window.set_title(Core.programName + " - Simulation");

            window.show_all();
        } catch (UICommon.LoadError e) {
            UICommon.fatal_load_error(e);
        }

        timingDiagram = new TimingDiagram(compiledCircuit);
    }

    private void connect_tool(Gtk.Builder builder, string name, MouseMode mode) throws UICommon.LoadError.MISSING_OBJECT {
        (UICommon.get_object_critical(builder, name) as Gtk.RadioToolButton).clicked.connect(() => {mouseMode = mode; update_display();});
    }

    // Signal handlers.
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_delete_window")]
    public bool ui_delete_window(Gtk.Window window, Gdk.Event event) {
        close_simulation();
        return true;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_close")]
    public void ui_close(Gtk.Activatable activatable) {
        close_simulation();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_fit_design")]
    public void ui_fit_design(Gtk.Activatable activatable) {
        fit_design();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_autofit")]
    public void ui_autofit(Gtk.CheckMenuItem checkMenuItem) {
        autoFitDesign = checkMenuItem.active;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_show_timing_diagram")]
    public void ui_show_timing_diagram(Gtk.Activatable activatable) {
        show_timing_diagram();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_shrink")]
    public void ui_shrink(Gtk.ToolButton toolButton) {
        compiledCircuit.shrink_component();
        if (autoFitDesign) {
            fit_design();
        }
        update_display(true);
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_run")]
    public void ui_run(Gtk.ToggleToolButton toggleToolButton) {
        if (toggleToolButton.active) {
            run();
        } else {
            pause();
        }
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_singlestep")]
    public void ui_singlestep(Gtk.ToolButton toolButton) {
        step(false);
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_multistep")]
    public void ui_multistep(Gtk.ToolButton toolButton) {
        step(true);
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_change_speed")]
    public void ui_change_speed(Gtk.SpinButton spinButton) {
        change_speed((int)(1000.0 / toolSpeedSpin.get_value()));
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_max_speed")]
    public void ui_max_speed(Gtk.ToggleToolButton toggleToolButton) {
        if (toggleToolButton.active) {
            toolSpeedSpin.set_sensitive(false);
            change_speed(0);
        } else {
            toolSpeedSpin.set_sensitive(true);
            change_speed((int)(1000.0 / toolSpeedSpin.get_value()));
        }
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_change_step")]
    public void ui_change_step(Gtk.SpinButton spinButton) {
        multistepSize = spinButton.get_value_as_int();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_mouse_down")]
    public bool ui_mouse_down(Gtk.Widget widget, Gdk.EventButton event) {
        mouse_down(event);
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_mouse_up")]
    public bool ui_mouse_up(Gtk.Widget widget, Gdk.EventButton event) {
        mouse_up(event);
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_render")]
    public bool ui_render(Gtk.Widget widget, Cairo.Context context) {
        render(context);
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT simulator_window_ui_display_configure")]
    public bool ui_display_configure(Gtk.Widget widget, Gdk.Event event) {
        update_display(true);
        return false;
    }

    private void change_speed(int newCycleDelay) {
        bool running = (runState == RunState.RUNNING);

        pause();

        cycleDelay = newCycleDelay;

        if (running) {
            run();
        }

        if (cycleDelay < 0) {
            cycleDelay = 0;
        } else if (cycleDelay > 10000) {
            cycleDelay = 10000;
        }

        microCycleDelay = cycleDelay * 1000;
    }

    private void step(bool multistep) {
        stepsLeft = multistep ? multistepSize : 1;

        run();

        runState = RunState.STEPPING;
    }

    /**
     * Sets the simulation state to running. Does nothing if the circuit
     * is in the ERROR state.
     */
    public void run() {
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
                Source.remove(cycleSourceID);
            }
            if (refreshSourceID != 0) {
                Source.remove(refreshSourceID);
            }

            cycleSourceID = Timeout.add(cycleDelay, update_cycle, Priority.DEFAULT_IDLE);
            refreshSourceID = Timeout.add(refreshDelay, refresh_cycle, Priority.DEFAULT);
        }
        runState = RunState.RUNNING;
        toolRun.active = true;

        timeBeforeRender = 0;
    }

    /**
     * Sets the simulation state to paused. Does nothing if the circuit
     * is in the ERROR state.
     */
    public void pause() {
        if (runState == RunState.ERROR) {
            return;
        }

        if (cycleSourceID != 0) {
            Source.remove(cycleSourceID);
            cycleSourceID = 0;
        }
        if (refreshSourceID != 0) {
            Source.remove(refreshSourceID);
            refreshSourceID = 0;
        }

        runState = RunState.PAUSED;
        toolRun.active = false;

        update_display(true);
        timingDiagram.update_display(true);
    }

    private void show_timing_diagram() {
        timingDiagram.show_diagram();
    }

    private void fit_design() {
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

        compiledCircuit.viewedComponent.get_design_bounds(out rightBound, out downBound, out leftBound, out upBound);

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

        update_display(true);
    }

    /**
     * Run periodically using a timer. Updates the display.
     */
    private bool refresh_cycle() {
        Timer renderingTimer = new Timer();

        if (runState != RunState.HALTING && timeBeforeRender <= 0.0) {
            renderingTimer.start();

            update_display(false);
            timingDiagram.update_display(false);

            renderingTimer.stop();

            timeBeforeRender = renderingTimer.elapsed();
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
    private bool update_cycle() {
        Timer simulationTimer = new Timer();

        simulationTimer.start();

        int result = compiledCircuit.update_cycle();

        simulationTimer.stop();

        if (simulationTimer.elapsed() < microCycleDelay) {
            timeBeforeRender -= (double)microCycleDelay;
        } else {
            timeBeforeRender -= simulationTimer.elapsed();
        }

        if (result == 1) {
            runState = RunState.ERROR;
            update_display(true);

            stderr.printf("Simulation Error!\n");
            stderr.flush();
            stderr.printf("Error Messages:\n%s\n", compiledCircuit.errorMessage);

            BasicDialog.error(null, "Circuit Runtime Error:\n" + compiledCircuit.errorMessage);
        }

        if (runState == RunState.RUNNING) {
            return true;
        } else if (runState == RunState.STEPPING) {
            stepsLeft --;
            if (stepsLeft <= 0) {
                pause();
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
    private bool mouse_down(Gdk.EventButton event) {
        xMouseStart = (int)(event.x);
        yMouseStart = (int)(event.y);
        return false;
    }

    /**
     * Handles mouse button up in the work area. Performs an action
     * which is determined by //mouseMode//.
     */
    private bool mouse_up(Gdk.EventButton event) {
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

        int yDiffAbs = (yDiff > 0) ? yDiff : -yDiff;

        switch (mouseMode) {
        case MouseMode.SCROLL:
            xView -= xBoardDiff;
            yView -= yBoardDiff;
            update_display(true);
            break;
        case MouseMode.ZOOM:
            if (yDiff > 0) {
                zoom *= 1.0f + ((float)yDiffAbs / (float)height);
            } else {
                zoom /= 1.0f + ((float)yDiffAbs / (float)height);
            }
            update_display(true);
            break;
        case MouseMode.INTERACT:
            compiledCircuit.interact_components(xBoardEnd, yBoardEnd);
            update_display(true, true);
            break;
        case MouseMode.CONTEXT:
            int result = compiledCircuit.expand_component(xBoardEnd, yBoardEnd);

            switch (result) {
            case 0: // Expand
                if (autoFitDesign) {
                    fit_design();
                }
                update_display(true);
                break;
            case 1: // Shrink
                compiledCircuit.shrink_component();
                if (autoFitDesign) {
                    fit_design();
                }
                update_display(true);
                break;
            case 2: // No Action happened, so interact
                compiledCircuit.interact_components(xBoardEnd, yBoardEnd);
                update_display(true, true);
                break;
            }
            break;
        case MouseMode.EXPLORE:
            int result = compiledCircuit.expand_component(xBoardEnd, yBoardEnd);

            switch (result) {
            case 0: // Expand
                if (autoFitDesign) {
                    fit_design();
                }
                update_display(true);
                break;
            case 1: // Shrink
                compiledCircuit.shrink_component();
                if (autoFitDesign) {
                    fit_design();
                }
                update_display(true);
                break;
            case 2: // No Action
                break;
            }
            break;
        case MouseMode.WATCH:
            WireState wireState = compiledCircuit.find_wire(xBoardEnd, yBoardEnd);

            if (wireState != null) {
                timingDiagram.add_wire(wireState);
            }
            break;
        }

        return false;
    }

    public void update_display(bool fullRefresh = true, bool cancelIfRunning = false) {
        if (fullRefresh) {
            renderCache = null;
        }

        if (cancelIfRunning && runState == RunState.RUNNING) {
            return;
        }

        if (window.visible) {
            display.queue_draw();
        }
    }

    /**
     * Renders the currently viewed part of the simulation. If
     * //fullRefresh// is false, then the circuit design is not redrawn.
     */
    public void render(Cairo.Context displayContext) {
        int width, height;
        Gtk.Allocation areaAllocation;

        // If the display will not naturally update, don't update too much.
        if (runState == RunState.PAUSED) {
            if (inhibitRender) {
                return;
            }

            inhibitRender = true;

            while (Gtk.events_pending()) {
                Gtk.main_iteration();
            }

            inhibitRender = false;
        }

        display.get_allocation(out areaAllocation);
        width = areaAllocation.width;
        height = areaAllocation.height;

        Cairo.Surface offScreenSurface = new Cairo.Surface.similar(displayContext.get_target(), displayContext.get_target().get_content(), width, height);

        Cairo.Context context = new Cairo.Context(offScreenSurface);

        if (renderCache == null) {
            // Full render required. Clear to white.
            context.set_source_rgb(1, 1, 1);
            context.paint();
        } else {
            // Reuse the previous render.
            context.set_source_surface(renderCache, 0, 0);
            context.paint();
        }

        context.translate(width / 2, height / 2);
        context.scale(zoom, zoom);
        context.translate(-xView, -yView);

        if (renderCache == null) {
            // Update everything.
            compiledCircuit.render(context, true, zoom);
        } else {
            // Only update state visualisation.
            compiledCircuit.render(context, false, zoom);
        }

        // Store the render for future partial updates.
        renderCache = offScreenSurface;

        displayContext.set_source_surface(offScreenSurface, 0, 0);
        displayContext.paint();
    }

    /**
     * Ends the simulation. Presenting a summary.
     */
    public void close_simulation() {
        stderr.printf("Ending Simulation.\n");

        runState = RunState.HALTING;

        timingDiagram.close_diagram();

        BasicDialog.information(null, "Simulation Summary:\nIterations: " + compiledCircuit.iterationCount.to_string());

        compiledCircuit.project.running = false;

        window.destroy();
    }
}
