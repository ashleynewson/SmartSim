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
 *   Filename: timingdiagram.vala
 *
 *   Copyright Ashley Newson 2013
 */


public class TimingDiagram {
    private Gtk.Window window;
    private Gtk.EventBox controller;
    private Gtk.DrawingArea display;

    private Cairo.Surface backgroundCache;
    private int largestLengthCache;

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


    public TimingDiagram(CompiledCircuit compiledCircuit) {
        this.compiledCircuit = compiledCircuit;
        populate();
    }

    /**
     * Populate the window with widgets.
     */
    public void populate() {
        stderr.printf("Timing Diagram Window Created\n");

        try {
            Gtk.Builder builder = new Gtk.Builder();
            try {
                builder.add_from_file(Config.resourcesDir + "ui/timingdiagram.ui");
            } catch (FileError e) {
                throw new UICommon.LoadError.MISSING_RESOURCE(e.message);
            } catch (Error e) {
                throw new UICommon.LoadError.BAD_RESOURCE(e.message);
            }

            // Connect basic signals
            builder.connect_signals(this);

            // Get references to useful things
            window = UICommon.get_object_critical(builder, "window") as Gtk.Window;
            controller = UICommon.get_object_critical(builder, "controller") as Gtk.EventBox;
            display = UICommon.get_object_critical(builder, "display") as Gtk.DrawingArea;

            // Connect tools
            connect_tool(builder, "tool_scroll", MouseMode.SCROLL);
            connect_tool(builder, "tool_zoom", MouseMode.ZOOM);
            connect_tool(builder, "tool_move", MouseMode.MOVE);
            connect_tool(builder, "tool_adjust", MouseMode.ADJUST);
            connect_tool(builder, "tool_delete", MouseMode.DELETE);

            window.set_title(Core.programName + " - Timing Diagram");

            window.show_all();
        } catch (UICommon.LoadError e) {
            UICommon.fatal_load_error(e);
        }

        window.hide();
        update_display();
    }

    private void connect_tool(Gtk.Builder builder, string name, MouseMode mode) throws UICommon.LoadError.MISSING_OBJECT {
        (UICommon.get_object_critical(builder, name) as Gtk.RadioToolButton).clicked.connect(() => {mouseMode = mode; update_display();});
    }

    // Signal handlers.
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT timing_diagram_ui_delete_window")]
    public bool ui_delete_window(Gtk.Window window, Gdk.Event event) {
        hide_diagram();
        return true;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT timing_diagram_ui_close")]
    public void ui_close(Gtk.Activatable activatable) {
        hide_diagram();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT timing_diagram_ui_export_png")]
    public void ui_export_png(Gtk.Activatable activatable) {
        export_png();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT timing_diagram_ui_export_pdf")]
    public void ui_export_pdf(Gtk.Activatable activatable) {
        export_pdf();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT timing_diagram_ui_export_svg")]
    public void ui_export_svg(Gtk.Activatable activatable) {
        export_svg();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT timing_diagram_ui_reset_recording")]
    public void ui_reset_recording(Gtk.Activatable activatable) {
        reset_timings();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT timing_diagram_ui_always_on_top")]
    public void ui_always_on_top(Gtk.CheckMenuItem checkMenuItem) {
        window.set_keep_above(checkMenuItem.active);
        alwaysOnTop = checkMenuItem.active;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT timing_diagram_ui_show_grid")]
    public void ui_show_grid(Gtk.CheckMenuItem checkMenuItem) {
        showGrid = checkMenuItem.active;
        update_display(true);
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT timing_diagram_ui_reset_view")]
    public void ui_reset_view(Gtk.Activatable activatable) {
        reset_view();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT timing_diagram_ui_mouse_down")]
    public bool ui_mouse_down(Gtk.Widget widget, Gdk.EventButton event) {
        mouse_down(event);
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT timing_diagram_ui_mouse_move")]
    public bool ui_mouse_move(Gtk.Widget widget, Gdk.EventMotion event) {
        mouse_move(event);
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT timing_diagram_ui_mouse_up")]
    public bool ui_mouse_up(Gtk.Widget widget, Gdk.EventButton event) {
        mouse_up(event);
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT timing_diagram_ui_render")]
    public bool ui_render(Gtk.Widget widget, Cairo.Context context) {
        render(context);
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT timing_diagram_ui_display_configure")]
    public bool ui_display_configure(Gtk.Widget widget, Gdk.Event event) {
        update_display(true);
        return false;
    }

    public void close_diagram() {
        window.destroy();
    }

    public bool hide_diagram() {
        window.hide();
        return true;
    }

    public void show_diagram() {
        window.show_all();
        window.present();
        window.set_keep_above(alwaysOnTop);
        update_display(true);
    }

    public void add_wire(WireState newWireState) {
        foreach (WireState wireState in wireStates) {
            if (wireState == newWireState) {
                return;
            }
        }

        PropertySet propertySet = new PropertySet("Watch Wire", "Record this wire in the timing diagram.");
        PropertyItemString labelProperty = new PropertyItemString("Label", "Display this text next to the graph.", "");
        propertySet.add_item(labelProperty);

        PropertiesQuery propertiesQuery = new PropertiesQuery("Watch Wire", this.window, propertySet);

        window.set_keep_above(false);

        if (propertiesQuery.run() == Gtk.ResponseType.APPLY) {
            string label = labelProperty.data;

            wireStates += newWireState;

            if (label == "") {
                labels += "Wire " + wireStates.length.to_string();
            } else {
                labels += label;
            }

            newWireState.start_recording(compiledCircuit.iterationCount - iterationCountOffset);

            update_display(true);
        }

        window.set_keep_above(alwaysOnTop);
    }

    private void forget_wire(int wireNumber) {
        WireState[] newWireStates = {};
        string[] newLabels = {};

        for (int i = 0; i < wireStates.length; i++) {
            if (i != wireNumber) {
                newWireStates += wireStates[i];
                newLabels += labels[i];
            } else {
                wireStates[i].stop_recording();
            }
        }

        wireStates = newWireStates;
        labels = newLabels;
    }

    private void move_wire(int fromNumber, int toNumber) {
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

    private void adjust_wire(int wireNumber) {
        if (0 <= wireNumber && wireNumber < wireStates.length) {
            PropertySet propertySet = new PropertySet("Watch Wire", "Record this wire in the timing diagram.");
            PropertyItemString labelProperty = new PropertyItemString("Label", "Display this text next to the graph.", labels[wireNumber]);
            propertySet.add_item(labelProperty);

            PropertiesQuery propertiesQuery = new PropertiesQuery("Watch Wire", this.window, propertySet);

            window.set_keep_above(false);

            if (propertiesQuery.run() == Gtk.ResponseType.APPLY) {
                string label = labelProperty.data;

                if (label == "") {
                    labels[wireNumber] = "Wire " + (wireNumber + 1).to_string();
                } else {
                    labels[wireNumber] = label;
                }

                update_display(true);
            }

            window.set_keep_above(alwaysOnTop);
        }
    }

    public void reset_timings() {
        foreach (WireState wireState in wireStates) {
            wireState.start_recording(0);
        }

        xView = 0;
        iterationCountOffset = compiledCircuit.iterationCount;

        update_display(true);
    }

    public void reset_view() {
        xView = 0;
        yView = 0;
        xZoom = 1;
        yZoom = 25;

        update_display(true);
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

    private bool mouse_move(Gdk.EventMotion event) {
        barPosition = event.x;

        update_display(false);
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

        int xStart = xMouseStart;
        int yStart = yMouseStart - 20;
        int xEnd = (int)event.x;
        int yEnd = (int)event.y - 20;
        int xDiff = xEnd - xStart;
        int yDiff = yEnd - yStart;

        int wireStart = (int)Math.floorf((float)((float)(yStart + yView) / (yZoom * 2.4)));
        int wireEnd = (int)Math.floorf((float)((float)(yEnd + yView) / (yZoom * 2.4)));

        int xDiffAbs = (xDiff > 0) ? xDiff : -xDiff;
        int yDiffAbs = (yDiff > 0) ? yDiff : -yDiff;

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
            move_wire(wireStart, wireEnd);
            break;
        case MouseMode.DELETE:
            forget_wire(wireEnd);
            break;
        case MouseMode.ADJUST:
            adjust_wire(wireEnd);
            break;
        }

        update_display(true);

        return false;
    }

    public int text_length() {
        int largestLength = 0;

        Cairo.TextExtents textExtents;
        Cairo.ImageSurface imageSurface = new Cairo.ImageSurface(Cairo.Format.ARGB32, 0, 0);
        Cairo.Context context = new Cairo.Context(imageSurface);

        context.set_font_size(16);

        foreach (string label in labels) {
            context.text_extents(label, out textExtents);
            if (largestLength < (int)textExtents.width) {
                largestLength = (int)textExtents.width;
            }
        }

        return largestLength;
    }

    // Also does horizontal grid
    public void render_labels(Cairo.Context context, int width, out int largestLength) {
        largestLength = 0;

        Cairo.Matrix oldMatrix;
        Cairo.TextExtents textExtents;
        oldMatrix = context.get_matrix();
        context.translate(10, yZoom * 1.2 - yView + 20);

        foreach (string label in labels) {
            context.set_source_rgb(0, 0, 0);
            context.set_font_size(16);
            context.text_extents(label, out textExtents);
            if (largestLength < (int)textExtents.width) {
                largestLength = (int)textExtents.width;
            }
            context.show_text(label);
            context.stroke();

            context.set_source_rgba(0, 0, 0, 0.25);
            context.move_to(-10, -yZoom * 1.2);
            context.line_to(width, -yZoom * 1.2);
            context.stroke();

            context.translate(0, yZoom * 2.4);
        }

        context.set_matrix(oldMatrix);
    }

    public void render_graphs(Cairo.Context context, int width, int largestLength) {
        Cairo.Matrix oldMatrix;
        oldMatrix = context.get_matrix();

        context.translate(largestLength + 20 - ((float)xView * xZoom), yZoom * 1.2 - yView + 20);
        int xLimit = (int)((float)(width - (largestLength + 20) + xView) / xZoom);

        foreach (WireState wireState in wireStates) {
            wireState.render_history(context, xView, xLimit, yZoom, xZoom);

            context.translate(0, yZoom * 2.4);
        }

        context.set_matrix(oldMatrix);
    }

    // Also does vertical grid
    public void render_ruler(Cairo.Context context, int width, int height, int largestLength) {
        float xLabel;
        int labelValue;

        context.set_source_rgb(1, 1, 1);
        context.rectangle(0, 0, width, 20);
        context.fill();
        context.stroke();

        if (xView < 0) {
            xLabel = largestLength + 20 - (float)xView * xZoom;
            labelValue = 0;
        } else {
            xLabel = largestLength + 20 - (float)(xView % 50) * xZoom;
            labelValue = xView - (xView % 50);
        }

        for (; xLabel < width; xLabel += 5 * xZoom, labelValue += 5) {
            if (labelValue % 50 == 0) {
                context.set_source_rgba(0, 0, 0, 1);
                context.move_to(xLabel, 0);
                context.line_to(xLabel, 19);
                context.set_font_size(12);
                context.move_to(xLabel + 2, 16);
                context.show_text(labelValue.to_string());
                context.stroke();

                if (showGrid && xLabel >= largestLength + 20) {
                    context.set_source_rgba(0, 0, 0, 0.25);
                    context.move_to(xLabel, 20);
                    context.line_to(xLabel, height);
                    context.stroke();
                }
            } else {
                context.set_source_rgba(0, 0, 0, 0.25);
                context.move_to(xLabel, 5);
                context.line_to(xLabel, 15);
                context.stroke();

                if (showGrid && xLabel >= largestLength + 20) {
                    context.set_source_rgba(0, 0, 0, 0.125);
                    context.move_to(xLabel, 20);
                    context.line_to(xLabel, height);
                    context.stroke();
                }
            }
        }
    }

    private void render_bar(Cairo.Context context, int height, int largestLength) {
        if (barPosition > largestLength + 20) {
            context.set_source_rgba(0, 0, 0, 0.25);
            context.move_to(barPosition, 0);
            context.line_to(barPosition, height);
            context.stroke();
        }
    }

    public void update_display(bool fullRefresh = true) {
        if (fullRefresh) {
            backgroundCache = null;
        }

        if (window.visible) {
            display.queue_draw();
        }
    }

    public void render(Cairo.Context displayContext) {
        if (!window.visible) {
            return;
        }

        int width, height;
        Gtk.Allocation areaAllocation;

        display.get_allocation(out areaAllocation);
        width = areaAllocation.width;
        height = areaAllocation.height;

        int largestLength;

        Cairo.Surface offScreenSurface = new Cairo.Surface.similar(displayContext.get_target(), displayContext.get_target().get_content(), width, height);
        Cairo.Context context = new Cairo.Context(offScreenSurface);

        if (backgroundCache == null) {
            backgroundCache = new Cairo.Surface.similar(context.get_target(), Cairo.Content.COLOR_ALPHA, width, height);
            Cairo.Context backgroundContext = new Cairo.Context(backgroundCache);

            backgroundContext.set_source_rgb(1, 1, 1);
            backgroundContext.paint();

            render_labels(backgroundContext, width, out largestLength);
            render_ruler(backgroundContext, width, height, largestLength);

            largestLengthCache = largestLength;
        } else {
            largestLength = largestLengthCache;
        }

        // Use cached background.
        context.set_source_surface(backgroundCache, 0, 0);
        context.paint();

        // Render the graph data
        render_graphs(context, width, largestLength);

        render_bar(context, height, largestLength);

        // Update on screen
        displayContext.set_source_surface(offScreenSurface, 0, 0);
        displayContext.paint();
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
        int duration = (compiledCircuit.iterationCount - iterationCountOffset);
        int width, height;
        width = (int)((float)(duration - xView) * xZoom) + text_length() + 21;
        height = (int)((float)(this.wireStates.length) * (yZoom * 2.4)) - yView + 21;

        int imageWidth = (int)((double)width * resolution);
        int imageHeight = (int)((double)height * resolution);
        double imageXZoom = xZoom * resolution;
        double imageYZoom = yZoom * resolution / 25;

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

        context.scale(imageXZoom, imageYZoom);

        context.set_line_width(1);

        stderr.printf("Exporting timing diagram (render size = %i x %i, scale = %f x %f)\n", imageWidth, imageHeight, imageXZoom, imageYZoom);

        int largestLength;
        render_labels(context, width, out largestLength);
        render_graphs(context, width, largestLength);
        render_ruler(context, width, height, largestLength);

        switch (imageFormat) {
        case ImageExporter.ImageFormat.PNG_RGB:
        case ImageExporter.ImageFormat.PNG_ARGB:
            surface.write_to_png(filename);
            break;
        }
    }
}
