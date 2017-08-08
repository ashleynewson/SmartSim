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
 *   Filename: customiser.vala
 *
 *   Copyright Ashley Newson 2013
 */


/**
 * User interface element used to customise a component.
 *
 * Allows a user to design how a custom component can be used in another
 * component.
 * Used to edit names and descriptions, create a box design, and
 * configure pins.
 */
public class Customiser {
    private Gtk.Dialog dialog;
    private Gtk.EventBox controller;
    private Gtk.DrawingArea display;
    private Gtk.Entry nameEntry;
    private Gtk.Entry descriptionEntry;
    private Gtk.SpinButton pinSpinButton;
    private Gtk.Label tagNameLabel;
    private Gtk.CheckButton requiredCheck;
    private Gtk.RadioButton labelTypeNoneRadio;
    private Gtk.RadioButton labelTypeTextRadio;
    private Gtk.RadioButton labelTypeTextBarRadio;
    private Gtk.RadioButton labelTypeClockRadio;
    private Gtk.Entry pinLabelEntry;
    private Gtk.SpinButton rightBoundSpinButton;
    private Gtk.SpinButton downBoundSpinButton;
    private Gtk.SpinButton leftBoundSpinButton;
    private Gtk.SpinButton upBoundSpinButton;

    private Cairo.Surface gridCache;

    /**
     * Actions to perform when the mouse button is released.
     */
    private enum MouseMode {
        SCROLL,
        ZOOM,
        PIN
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
     * Specifies the action to perform when the mouse button is
     * released.
     */
    private MouseMode mouseMode = MouseMode.PIN;

    /**
     * The custom component being edited.
     */
    private CustomComponentDef customComponentDef;
    /**
     * The DesignerWindow which started the customisation.
     */
    private DesignerWindow parent;
    /**
     * The project the component belongs to.
     */
    private Project project;

    private int selectedPinID = 0;
    private PinDef selectedPin;
    /**
     * The x position where the user drags on the display area from.
     */
    private int xMouseStart;
    /**
     * The y position where the user drags on the display area from.
     */
    private int yMouseStart;
    /**
     * The interface tag which corrisponds to //selectedPin//.
     */
    private Tag tag;

    /**
     * Start the customiser, setting the caller DesignerWindow, target
     * custom component and its project.
     */
    public Customiser(DesignerWindow? parent, CustomComponentDef customComponentDef, Project project) {
        this.customComponentDef = customComponentDef;
        this.parent = parent;
        this.project = project;

        int tagCount = customComponentDef.count_tags();

        customComponentDef.pinDefs.resize(tagCount);

        for (int i = 0; i < tagCount; i++) {
            if (customComponentDef.pinDefs[i] == null) {
                Tag resolvedTag = customComponentDef.resolve_tag_id(i);
                if (resolvedTag != null) {
                    customComponentDef.pinDefs[i] = new PinDef(0, 0, Direction.RIGHT, resolvedTag.flow, 0, false);
                } else {
                    customComponentDef.pinDefs[i] = new PinDef(0, 0, Direction.RIGHT, Flow.NONE, 0, false);
                }
            }
        }

        if (customComponentDef.validate_interfaces() != 0) {
            BasicDialog.warning(null, "Warning:\nCould not associate all pins with interface tags. Make sure that all tags have unique and sequential IDs starting with 0. You can cycle through the pins to check the associations.\n");
        }

        populate();

        update_selection();
    }

    /**
     * Create a new Gtk Dialog and populate it with widgets
     */
    private void populate() {
        try {
            Gtk.Builder builder = new Gtk.Builder();
            try {
                builder.add_from_file(Config.resourcesDir + "ui/customiser.ui");
            } catch (FileError e) {
                throw new UICommon.LoadError.MISSING_RESOURCE(e.message);
            } catch (Error e) {
                throw new UICommon.LoadError.BAD_RESOURCE(e.message);
            }

            // Connect basic signals
            builder.connect_signals(this);

            // Get references to useful things
            dialog = UICommon.get_object_critical(builder, "dialog") as Gtk.Dialog;
            controller = UICommon.get_object_critical(builder, "controller") as Gtk.EventBox;
            display = UICommon.get_object_critical(builder, "display") as Gtk.DrawingArea;
            nameEntry = UICommon.get_object_critical(builder, "name") as Gtk.Entry;
            descriptionEntry = UICommon.get_object_critical(builder, "description") as Gtk.Entry;
            pinSpinButton = UICommon.get_object_critical(builder, "pin_select") as Gtk.SpinButton;
            tagNameLabel = UICommon.get_object_critical(builder, "tag_name") as Gtk.Label;
            requiredCheck = UICommon.get_object_critical(builder, "required") as Gtk.CheckButton;
            pinLabelEntry = UICommon.get_object_critical(builder, "pin_label") as Gtk.Entry;
            labelTypeNoneRadio = UICommon.get_object_critical(builder, "label_style_none") as Gtk.RadioButton;
            labelTypeTextRadio = UICommon.get_object_critical(builder, "label_style_text") as Gtk.RadioButton;
            labelTypeTextBarRadio = UICommon.get_object_critical(builder, "label_style_bartext") as Gtk.RadioButton;
            labelTypeClockRadio = UICommon.get_object_critical(builder, "label_style_clock") as Gtk.RadioButton;
            rightBoundSpinButton = UICommon.get_object_critical(builder, "right_bound") as Gtk.SpinButton;
            downBoundSpinButton = UICommon.get_object_critical(builder, "down_bound") as Gtk.SpinButton;
            leftBoundSpinButton = UICommon.get_object_critical(builder, "left_bound") as Gtk.SpinButton;
            upBoundSpinButton = UICommon.get_object_critical(builder, "up_bound") as Gtk.SpinButton;

            // Connect tools
            connect_tool(builder, "tool_scroll", MouseMode.SCROLL);
            connect_tool(builder, "tool_zoom", MouseMode.ZOOM);
            connect_tool(builder, "tool_pin", MouseMode.PIN);

            // Enable pin controls if we have pins
            if (customComponentDef.pinDefs.length > 0) {
                (UICommon.get_object_critical(builder, "pin_controls") as Gtk.Widget).sensitive = true;
                (UICommon.get_object_critical(builder, "pin_adjustment") as Gtk.Adjustment).upper = customComponentDef.pinDefs.length - 1;
            }

            dialog.set_transient_for(parent.gtk_window);

            dialog.show_all();
        } catch (UICommon.LoadError e) {
            UICommon.fatal_load_error(e);
        }
    }

    private void connect_tool(Gtk.Builder builder, string name, MouseMode mode) throws UICommon.LoadError.MISSING_OBJECT {
        (UICommon.get_object_critical(builder, name) as Gtk.RadioToolButton).clicked.connect(() => {mouseMode = mode; update_display();});
    }

    // Signal handlers.
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT customiser_ui_response")]
    public void ui_response(Gtk.Dialog dialog, int response_id) {
        update_values();
        dialog.destroy();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT customiser_ui_mouse_down")]
    public bool ui_mouse_down(Gtk.Widget widget, Gdk.EventButton event) {
        mouse_down(event);
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT customiser_ui_mouse_up")]
    public bool ui_mouse_up(Gtk.Widget widget, Gdk.EventButton event) {
        mouse_up(event);
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT customiser_ui_render")]
    public bool ui_render(Gtk.Widget widget, Cairo.Context context) {
        render_def(context);
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT customiser_ui_display_configure")]
    public bool ui_display_configure(Gtk.Widget widget, Gdk.Event event) {
        gridCache = null;
        update_display();
        return false;
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT customiser_ui_update_box_label")]
    public void ui_update_box_label(Gtk.Entry entry) {
        customComponentDef.label = entry.text;
        update_display();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT customiser_ui_pin_select")]
    public void ui_pin_select(Gtk.SpinButton spinButton) {
        update_selection();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT customiser_ui_update_required")]
    public void ui_update_required(Gtk.CheckButton checkButton) {
        if (selectedPin != null) {
            selectedPin.required = checkButton.active;
        }
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT customiser_ui_update_pin_label_style")]
    public void ui_update_pin_label_style(Gtk.RadioButton radioButton) {
        update_label_type();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT customiser_ui_update_pin_label")]
    public void ui_update_pin_label(Gtk.Entry entry) {
        if (selectedPin != null) {
            selectedPin.label = entry.text;
            update_display();
        }
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT customiser_ui_update_bounds")]
    public void ui_update_bounds(Gtk.SpinButton spinButton) {
        update_bounds();
    }
    [CCode (instance_pos = -1, cname = "G_MODULE_EXPORT customiser_ui_set_colour")]
    public void ui_set_colour(Gtk.Button button) {
        set_colour();
    }

    /**
     * Signal handler for the Gtk.EventBox. Handles a mouse button down
     * event on the display area.
     */
    private bool mouse_down(Gdk.EventButton event) {
        xMouseStart = (int)(event.x);
        yMouseStart = (int)(event.y);
        return false;
    }

    /**
     * Signal handler for the Gtk.EventBox. Handles a mouse button up
     * event on the display area. This is when an action is taken.
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

        int halfGridSize = gridSize / 2;

        int xBoardStart = (int)((float)xStart / zoom + (float)xView);
        int yBoardStart = (int)((float)yStart / zoom + (float)yView);
        int xBoardEnd = (int)((float)xEnd / zoom + (float)xView);
        int yBoardEnd = (int)((float)yEnd / zoom + (float)yView);

        switch (mouseMode) {
        case MouseMode.SCROLL:
        case MouseMode.ZOOM:
            break;
        case MouseMode.PIN:
            xBoardStart += (xBoardStart > 0) ? halfGridSize : -halfGridSize;
            yBoardStart += (yBoardStart > 0) ? halfGridSize : -halfGridSize;
            xBoardStart = (xBoardStart / gridSize) * gridSize;
            yBoardStart = (yBoardStart / gridSize) * gridSize;

            xBoardEnd += (xBoardEnd > 0) ? halfGridSize : -halfGridSize;
            yBoardEnd += (yBoardEnd > 0) ? halfGridSize : -halfGridSize;
            xBoardEnd = (xBoardEnd / gridSize) * gridSize;
            yBoardEnd = (yBoardEnd / gridSize) * gridSize;
            break;
        }

        stderr.printf("Customiser Interact @ %i, %i - %i, %i\n", xBoardStart, yBoardStart, xBoardEnd, yBoardEnd);

        int xBoardDiff = xBoardEnd - xBoardStart;
        int yBoardDiff = yBoardEnd - yBoardStart;

        int yDiffAbs = (yDiff > 0) ? yDiff : -yDiff;

        int rightBound = customComponentDef.rightBound;
        int downBound = customComponentDef.downBound;
        int leftBound = customComponentDef.leftBound;
        int upBound = customComponentDef.upBound;

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
        case MouseMode.PIN:
            if (selectedPin != null) {
                if (upBound <= yBoardEnd && yBoardEnd <= downBound) {
                    if (xBoardEnd < leftBound) {
                        selectedPin.set_position(leftBound, yBoardEnd, leftBound - xBoardEnd, Direction.LEFT);
                    }
                    if (xBoardEnd > rightBound) {
                        selectedPin.set_position(rightBound, yBoardEnd, xBoardEnd - rightBound, Direction.RIGHT);
                    }
                }
                if (leftBound <= xBoardEnd && xBoardEnd <= rightBound) {
                    if (yBoardEnd < upBound) {
                        selectedPin.set_position(xBoardEnd, upBound, upBound - yBoardEnd, Direction.UP);
                    }
                    if (yBoardEnd > downBound) {
                        selectedPin.set_position(xBoardEnd, downBound, yBoardEnd - downBound, Direction.DOWN);
                    }
                }
            }
            break;
        }

        update_values();

        update_display();

        return false;
    }

    /**
     * Called when the Customiser should become modal.
     */
    public void run() {
        dialog.run();
    }

    public void set_colour() {
        Gtk.ColorChooserDialog colorDialog = new Gtk.ColorChooserDialog("Component Background", dialog);
        Gdk.RGBA color = Gdk.RGBA();

        colorDialog.use_alpha = true;

        color.red   = (double)customComponentDef.backgroundRed   / 255.0;
        color.green = (double)customComponentDef.backgroundGreen / 255.0;
        color.blue  = (double)customComponentDef.backgroundBlue  / 255.0;

        if (customComponentDef.backgroundAlpha == 0) {
            color.alpha = 1.0;
        } else {
            color.alpha = (double)customComponentDef.backgroundAlpha / 255.0;
        }
        colorDialog.set_rgba(color);

        if (colorDialog.run() == Gtk.ResponseType.OK) {
            color = colorDialog.get_rgba ();

            customComponentDef.backgroundRed = (int)(color.red * 255.0);
            customComponentDef.backgroundGreen = (int)(color.green * 255.0);
            customComponentDef.backgroundBlue = (int)(color.blue * 255.0);
            customComponentDef.backgroundAlpha = (int)(color.alpha * 255.0);

            customComponentDef.backgroundAlphaF = (double)customComponentDef.backgroundAlpha / 255.0;
            customComponentDef.backgroundRedF = (double)customComponentDef.backgroundRed / 255.0;
            customComponentDef.backgroundGreenF = (double)customComponentDef.backgroundGreen / 255.0;
            customComponentDef.backgroundBlueF = (double)customComponentDef.backgroundBlue / 255.0;
        }

        colorDialog.destroy();

        update_display();
    }

    /**
     * Set generic information. Called when closing the dialog.
     */
    public void update_values() {
        if (nameEntry.text != customComponentDef.name) {
            if (project.resolve_def_name(nameEntry.text) == null) {
                customComponentDef.name = nameEntry.text;
            } else {
                BasicDialog.error(null, "A component with the name \"" + nameEntry.text + "\" already exists. It may be a built-in component or a custom component. This component's name will remain \"" + customComponentDef.name + "\".");
            }
        }
        customComponentDef.description = descriptionEntry.text;
    }

    /**
     * Set, from radio buttons, what type of label a pin should use.
     */
    public void update_label_type() {
        if (selectedPin != null) {
            if (labelTypeNoneRadio.active) {
                selectedPin.labelType = PinDef.LabelType.NONE;
            } else if (labelTypeTextRadio.active) {
                selectedPin.labelType = PinDef.LabelType.TEXT;
            } else if (labelTypeTextBarRadio.active) {
                selectedPin.labelType = PinDef.LabelType.TEXTBAR;
            } else if (labelTypeClockRadio.active) {
                selectedPin.labelType = PinDef.LabelType.CLOCK;
            }
            update_display();
        }
    }

    /**
     * Set, from spin buttons, what the bounds of the component are.
     */
    public void update_bounds() {
        customComponentDef.rightBound = rightBoundSpinButton.get_value_as_int();
        customComponentDef.downBound = downBoundSpinButton.get_value_as_int();
        customComponentDef.leftBound = leftBoundSpinButton.get_value_as_int();
        customComponentDef.upBound = upBoundSpinButton.get_value_as_int();

        update_display();
    }

    /**
     * Update widgets to show the information of the selected pin.
     */
    public void update_selection() {
        if (customComponentDef.pinDefs.length > 0) {
            selectedPinID = pinSpinButton.get_value_as_int();
            selectedPin = customComponentDef.pinDefs[selectedPinID];
            tag = customComponentDef.resolve_tag_id(selectedPinID);

            switch (selectedPin.labelType) {
            case PinDef.LabelType.NONE:
                labelTypeNoneRadio.set_active(true);
                break;
            case PinDef.LabelType.TEXT:
                labelTypeTextRadio.set_active(true);
                break;
            case PinDef.LabelType.TEXTBAR:
                labelTypeTextBarRadio.set_active(true);
                break;
            case PinDef.LabelType.CLOCK:
                labelTypeClockRadio.set_active(true);
                break;
            }

            if (tag != null) {
                tagNameLabel.label = "Maps to: " + tag.text;

                if (selectedPin.label == "") {
                    selectedPin.label = tag.text;
                }
            } else {
                tagNameLabel.label = "There is no matching tag!";
            }

            pinLabelEntry.text = selectedPin.label;
            requiredCheck.active = selectedPin.required;

        } else {
            selectedPin = null;
        }

        update_display();
    }

    public void update_display() {
        if (dialog.visible) {
            display.queue_draw();
        }
    }

    /**
     * Render the current box design.
     */
    public void render_def(Cairo.Context displayContext) {
        int width, height;
        Gtk.Allocation areaAllocation;

        display.get_allocation(out areaAllocation);
        width = areaAllocation.width;
        height = areaAllocation.height;

        Cairo.Surface offScreenSurface = new Cairo.Surface.similar(displayContext.get_target(), Cairo.Content.COLOR, width, height);
        Cairo.Context context = new Cairo.Context(offScreenSurface);

        context.set_line_width(1);

        if ( (parent != null) ? parent.showGrid : false ) {
            if (gridCache == null) {
                gridCache = new Cairo.Surface.similar(context.get_target(), context.get_target().get_content(), width, height);
                Cairo.Context gridContext = new Cairo.Context(gridCache);

                gridContext.set_source_rgb(1, 1, 1);
                gridContext.paint();

                float spacing = zoom * parent.gridSize;

                while (spacing < 2) {
                    spacing *= parent.gridSize;
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

                gridContext.set_source_rgba(0, 0, 0, 1.0);

                gridContext.set_dash({1.0, (spacing) - 1.0}, 0);

                for (; y < height; y += spacing) {
                    gridContext.move_to(x, y);
                    gridContext.line_to(width, y);
                    gridContext.stroke();
                }

                gridContext.set_dash(null, 0);

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

        customComponentDef.render(context, Direction.RIGHT, false, null, true);

        for (int i = 0; i < customComponentDef.pinDefs.length; i++) {
            PinDef pinDef = customComponentDef.pinDefs[i];

            if (selectedPinID == i) {
                context.set_source_rgb(0, 0, 1);
            } else {
                context.set_source_rgb(0, 0, 0);
            }

            pinDef.render(context, false);
        }

        displayContext.set_source_surface(offScreenSurface, 0, 0);
        displayContext.paint();
    }
}
