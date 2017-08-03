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
 *   Filename: designer.vala
 *
 *   Copyright Ashley Newson 2013
 */


/**
 * Used to edit a custom component.
 */
public class Designer {
    /**
     * The DesignerWindow which is being used as a front-end for
     * editing a design.
     */
    public weak DesignerWindow window;
    /**
     * The project the designer and component belong to.
     */
    private weak Project project;
    /**
     * The component being designed.
     */
    public weak CustomComponentDef customComponentDef;
    private bool _hasComponent = false;
    /**
     * Whether the component being designed is actually ready.
     */
    public bool hasComponent {
        public get { return _hasComponent; }
        private set {
            _hasComponent = value;
        }
    }
    private bool _hasInsert = false;
    /**
     * If there is a component to insert.
     */
    private bool hasInsert {
        get { return _hasInsert; }
        set {
            _hasInsert = value;
        }
    }
    public string designerName {private set; public get;}
    public int myID;
    /**
     * The type of component selected for insertion.
     */
    public weak ComponentDef insertComponentDef;
    /**
     * The last custom component selected for insertion.
     */
    public weak ComponentDef lastInsertCustomComponentDef;
    /**
     * The last plugin component selected for insertion.
     */
    public weak ComponentDef lastInsertPluginComponentDef;

    public ComponentInst shadowComponentInst;

    /**
     * Before a wire is created, it is drawn. This holds the current
     * path being drawn.
     */
    private Path currentPath;
    /**
     * Whether or not the user is in the process of drawing a wire path.
     */
    private bool hasPath = false;


    /**
     * Create a Designer with the specified front-end DesignerWindow and
     * project.
     */
    public Designer(DesignerWindow viewerWindow, Project parentProject) {
        window = viewerWindow;
        project = parentProject;
        stderr.printf("New Designer Created\n");
    }

    ~Designer() {
        stderr.printf("Designer Destroyed\n");
    }

    /**
     * Sets the name of the designer.
     */
    public void set_name(string newName) {
        designerName = newName;
    }

    /**
     * Sets the component to design.
     */
    public void set_component(CustomComponentDef? customComponentDef) {
        this.customComponentDef = customComponentDef;
        if (customComponentDef != null) {
            hasComponent = true;
        }
        window.update_title();
    }

    /**
     * Sets the component for insertion.
     */
    public void set_insert_component(ComponentDef insertComponentDef) {
        this.insertComponentDef = insertComponentDef;
        if (insertComponentDef is CustomComponentDef) {
            lastInsertCustomComponentDef = insertComponentDef;
        } else if (insertComponentDef is PluginComponentDef) {
            lastInsertPluginComponentDef = insertComponentDef;
        }
        hasInsert = true;
        shadowComponentInst = new ComponentInst(insertComponentDef, 0, 0, Direction.RIGHT, false);
    }

    /**
     * Sets the component for insertion as the last custom component
     * which was selected for insertion.
     */
    public bool set_insert_last_custom() {
        if (lastInsertCustomComponentDef != null) {
            set_insert_component(lastInsertCustomComponentDef);
            return true;
        } else {
            return false;
        }
    }

    /**
     * Sets the component for insertion as the last plugin component
     * which was selected for insertion.
     */
    public bool set_insert_last_plugin() {
        if (lastInsertPluginComponentDef != null) {
            set_insert_component(lastInsertPluginComponentDef);
            return true;
        } else {
            return false;
        }
    }

    /**
     * Add a subcomponent to the design.
     */
    public void add_componentInst(int x, int y, Direction direction, bool autoBind = false) {
        if (hasInsert) {
            foreach (ComponentInst componentInst in customComponentDef.componentInsts) {
                if (componentInst.xPosition == x && componentInst.yPosition == y) {
                    return;
                }
            }

            ComponentInst componentInst = customComponentDef.add_componentInst(insertComponentDef, x, y, direction);

            if (autoBind) {
                auto_connect_component(componentInst);
            }
        }
    }

    /**
     * Add an annotation to the design.
     */
    public void add_annotation(int x, int y, string text, double fontSize = 12) {
        customComponentDef.add_annotation(x, y, text, fontSize);
    }

    /**
     * Used to draw a wire. If there is no path being drawn, start one
     * at (//x//, //y//). If there is a path, add a point at
     * (//x//, //y//). Finishes and adds a wire when the last point is
     * already at (//x//, //y//).
     */
    public void draw_wire(int x, int y, float diagonalThreshold, bool autoBind = false) {
        if (hasPath) {
            switch (currentPath.append (x, y, diagonalThreshold)) {
            case 1:
                WireInst wireInst = customComponentDef.add_wire();
                wireInst.import_path(currentPath);
                if (autoBind) {
                    auto_connect_path(currentPath);
                }
                hasPath = false;
                break;
            case 2:
                hasPath = false;
                break;
            }
        } else {
            hasPath = true;
            currentPath = new Path(x, y);
        }
    }

    public void forget_wire() {
        hasPath = false;
    }

    /**
     * Combines two wires together to form one complex wire. Combines
     * any wires passing through (//x//, //y//).
     */
    public int bind_wire(int x, int y) {
        WireInst[] wireInsts = {};
        WireInst compositeWireInst = new WireInst();
        bool addComposite = false;
        int wiresAdded = 0;

        foreach (WireInst wireInst in customComponentDef.wireInsts) {
            if (wireInst.find(x, y) != null) {
                addComposite = true;
                wiresAdded ++;
                compositeWireInst.merge(wireInst);
            } else {
                wireInsts += wireInst;
            }
        }

        if (compositeWireInst.count_find(x, y) > 1) {
            compositeWireInst.mark(x, y);
        }
        if (addComposite) {
            wireInsts += compositeWireInst;
        }

        customComponentDef.wireInsts = wireInsts;

        return wiresAdded;
    }

    /**
     * Splits a complex wire into two or more simpler wires at point
     * (//x//, //y//). This only seperates wires that were joined with
     * //bind_wire// - it does not break up paths.
     */
    public int unbind_wire(int x, int y) {
        WireInst[] wireInsts = {};
        int wiresUnbound = 0;

        foreach (WireInst wireInst in customComponentDef.wireInsts) {
            if (wireInst.find(x, y) != null) {
                WireInst[] addWireInsts;
                addWireInsts = wireInst.unmerge(x, y);
                foreach (WireInst addWireInst in addWireInsts) {
                    wireInsts += addWireInst;
                }
            } else {
                wireInsts += wireInst;
            }
        }

        customComponentDef.wireInsts = wireInsts;

        return wiresUnbound;
    }

    /**
     * Creates an interface tag going from (//x1//, //y1//) to
     * (//x2//, //y2//) and prompts the user to configure it.
     * If both points are the same, it will remove a tag.
     */
    public void tag_wire(int x1, int y1, int x2, int y2, bool oldDirection = false) {
        foreach (WireInst wireInst in customComponentDef.wireInsts) {
            string text = "Tag";
            int pinid = customComponentDef.new_tag_id();
            Flow flow = Flow.NONE;

            Tag oldTag = wireInst.interfaceTag;

            if (oldTag != null) {
                text = oldTag.text;
                pinid = oldTag.pinid;
                flow = oldTag.flow;
            }

            Tag tag = wireInst.set_tag(x1, y1, x2, y2);

            if (tag != null) {
                tag.text = text;
                tag.pinid = tag.pinid;
                if (oldDirection && oldTag != null) {
                    tag.flow = oldTag.flow;
                }

                PropertySet tagProperties = new PropertySet("Interface Tag", "Interface reference and label query");
                tagProperties.add_item(new PropertyItemString("Text", "Text to display.", tag.text));
                {
                    PropertyItemSelection selection = new PropertyItemSelection("Flow", "Type of pin (from this component's view).");
                    selection.add_option("Input");
                    selection.add_option("Output");
                    selection.add_option("Bidirectional");
                    switch (tag.flow) {
                    case Flow.IN:
                        selection.set_option("Input");
                        break;
                    case Flow.OUT:
                        selection.set_option("Output");
                        break;
                    case Flow.BIDIRECTIONAL:
                        selection.set_option("Bidirectional");
                        break;
                    }
                    tagProperties.add_item(selection);
                }
                tagProperties.add_item(new PropertyItemInt("Pin ID", "ID of the pin which this tag represents a connection to. Each pin has its own unique ID.", pinid, 0, int.MAX));

                bool notValid = true;
                while (notValid) {
                    notValid = false;
                    PropertiesQuery tagQuery = new PropertiesQuery("Interface Tag Properties", window.gtk_window, tagProperties);

                    if (tagQuery.run() == Gtk.ResponseType.APPLY) {
                        string option;

                        text = PropertyItemString.get_data(tagProperties, "Text");
                        pinid = PropertyItemInt.get_data(tagProperties, "Pin ID");
                        option = PropertyItemSelection.get_data(tagProperties, "Flow");

                        if (pinid < 0) {
                            notValid = true;
                            Gtk.MessageDialog messageDialog = new Gtk.MessageDialog(
                                null,
                                Gtk.DialogFlags.MODAL,
                                Gtk.MessageType.ERROR,
                                Gtk.ButtonsType.OK,
                                "Pin ID must be greater than or equal to 0.\n"
                            );

                            messageDialog.run();
                            messageDialog.destroy();
                        }

                        switch (option) {
                        case "Input":
                            tag.flow = Flow.IN;
                            break;
                        case "Output":
                            tag.flow = Flow.OUT;
                            break;
                        case "Bidirectional":
                            tag.flow = Flow.BIDIRECTIONAL;
                            break;
                        }

                        tag.pinid = pinid;
                        tag.text = text;
                    } else {
                        wireInst.interfaceTag = oldTag;
                    }
                }
                return;
            }
        }
    }

    public void auto_connect_wire(WireInst wireInst) {
        foreach (Path path in wireInst.paths) {
            auto_connect_path(path);
        }
    }

    public void auto_connect_path(Path path) {
        bind_wire(path.lines[0].x1, path.lines[0].y1);
        connect_component(path.lines[0].x1, path.lines[0].y1);

        foreach (Path.Line line in path.lines) {
            bind_wire(line.x2, line.y2);
            connect_component(line.x2, line.y2);
        }
    }

    public void auto_connect_component(ComponentInst componentInst) {
        foreach (PinInst pinInst in componentInst.pinInsts) {
            if (pinInst.show) {
                for (int i = 0; i < pinInst.arraySize; i++) {
                    if (pinInst.wireInsts[i] == null) {
                        foreach (WireInst wireInst in customComponentDef.wireInsts) {
                            int xAbs;
                            int yAbs;

                            componentInst.absolute_position(pinInst.xConnect[i], pinInst.yConnect[i], out xAbs, out yAbs);

                            if (wireInst.find(xAbs, yAbs) != null) {
                                pinInst.try_connect(pinInst.xConnect[i], pinInst.yConnect[i], wireInst, componentInst);
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * Connects a wire with any pins at point (//x//, //y//).
     */
    public int connect_component(int x, int y) {
        int connectedComponents = 0;
        foreach (WireInst wireInst in customComponentDef.wireInsts) {
            if (wireInst.find(x, y) != null) {
                foreach (ComponentInst componentInst in customComponentDef.componentInsts) {
                    if (componentInst.try_connect(x, y, wireInst)) {
                        connectedComponents++;
                    }
                }
            }
        }

        return connectedComponents;
    }

    /**
     * Disconnects any pins at point (//x//, //y//) from all wires.
     */
    public int disconnect_component(int x, int y) {
        int disconnectedComponents = 0;
        foreach (WireInst wireInst in customComponentDef.wireInsts) {
            if (wireInst.find(x, y) != null) {
                foreach (ComponentInst componentInst in customComponentDef.componentInsts) {
                    if (componentInst.try_disconnect(x, y)) {
                        disconnectedComponents++;
                    }
                }
            }
        }

        return disconnectedComponents;
    }

    /**
     * Invert any pins with their ends at point (//x//, //y//).
     */
    public void invert_pin(int x, int y) {
        foreach (ComponentInst componentInst in customComponentDef.componentInsts) {
            componentInst.try_invert(x, y);
        }
    }

    /**
     * Snap //x// and //y// to the nearest pin within a square range.
     */
    public int snap_pin(ref int x, ref int y, int range) {
        bool match = false;
        int xNew = 0;
        int yNew = 0;
        int winningDiff = 2 * range + 1;

        foreach (ComponentInst componentInst in customComponentDef.componentInsts) {
            foreach (PinInst pinInst in componentInst.pinInsts) {
                for (int i = 0; i < pinInst.arraySize; i++) {
                    int xPin, yPin;
                    componentInst.absolute_position(pinInst.xConnect[i], pinInst.yConnect[i], out xPin, out yPin);

                    int xDiff = x - xPin;
                    int yDiff = y - yPin;
                    int xDiffAbs = (xDiff > 0) ? xDiff : -xDiff;
                    int yDiffAbs = (yDiff > 0) ? yDiff : -yDiff;

                    if (xDiffAbs <= range && yDiffAbs <= range) {
                        int diff = xDiffAbs + yDiffAbs;
                        if (diff < winningDiff) {
                            match = true;
                            xNew = xPin;
                            yNew = yPin;
                            winningDiff = diff;
                        }
                    }
                }
            }
        }

        if (match) {
            x = xNew;
            y = yNew;
            return 0;
        } else {
            return 1;
        }
    }

    /**
     * Change the properties of a component at (//x//, //y//), including
     * any pin array sizes and component specific properties.
     */
    public void adjust_components(int x, int y, bool autoBind = false) {
        foreach (ComponentInst componentInst in customComponentDef.componentInsts) {
            if (componentInst.find(x, y) == 1) {
                PropertySet componentProperties = new PropertySet(componentInst.componentDef.name + " Component Instance", "Component Instance Properties");

                for (int i = 0; i < componentInst.pinInsts.length; i++) {
                    if (componentInst.pinInsts[i].pinDef.array && componentInst.pinInsts[i].pinDef.userArrayResize) {
                        string propertyName = "";

                        switch (componentInst.pinInsts[i].pinDef.flow) {
                        case Flow.IN:
                            propertyName = "Input - ";
                            break;
                        case Flow.OUT:
                            propertyName = "Output - ";
                            break;
                        case Flow.BIDIRECTIONAL:
                            propertyName = "Bidirectional - ";
                            break;
                        }
                        propertyName += "Set width of \"" + componentInst.pinInsts[i].pinDef.label + "\" / ID " + i.to_string();

                        componentProperties.add_item(new PropertyItemInt(propertyName, "The number of pins that this component should use.", componentInst.pinInsts[i].arraySize, 1, int.MAX));
                    }
                }

                componentInst.componentDef.add_properties(componentProperties, componentInst.configuration);

                string title = componentInst.componentDef.name + " Component Properties";

                PropertiesQuery componentQuery = new PropertiesQuery(title, window.gtk_window, componentProperties);

                if (componentQuery.run() == Gtk.ResponseType.APPLY) {
                    for (int i = 0; i < componentInst.pinInsts.length; i++) {
                        if (componentInst.pinInsts[i].pinDef.array && componentInst.pinInsts[i].pinDef.userArrayResize) {
                            int arraySize;
                            string propertyName = "";

                            switch (componentInst.pinInsts[i].pinDef.flow) {
                            case Flow.IN:
                                propertyName = "Input - ";
                                break;
                            case Flow.OUT:
                                propertyName = "Output - ";
                                break;
                            case Flow.BIDIRECTIONAL:
                                propertyName = "Bidirectional - ";
                                break;
                            }
                            propertyName += "Set width of \"" + componentInst.pinInsts[i].pinDef.label + "\" / ID " + i.to_string();

                            arraySize = PropertyItemInt.get_data(componentProperties, propertyName);
                            if (arraySize != componentInst.pinInsts[i].arraySize && arraySize >= 1) {
                                componentInst.pinInsts[i].disconnect(componentInst);
                                componentInst.pinInsts[i] = new PinInst(componentInst.componentDef.pinDefs[i], arraySize);
                            }
                        }
                    }
                }

                componentInst.componentDef.get_properties(componentProperties, out componentInst.configuration);
                componentInst.componentDef.configure_inst(componentInst);
                if (autoBind) {
                    auto_connect_component(componentInst);
                }
            }
        }
    }

    /**
     * Change the text and font size of any annotation at
     * (//x//, //y//).
     */
    public void adjust_annotations(int x, int y) {
        foreach (Annotation annotation in customComponentDef.annotations) {
            if (annotation.find(x, y) == 1) {
                string text = annotation.text;
                double fontSize = annotation.fontSize;

                PropertySet annotationProperties = new PropertySet("Annotation", "Annotation text query");
                annotationProperties.add_item(new PropertyItemString("Text", "Text to display.", text));
                annotationProperties.add_item(new PropertyItemDouble("Font Size", "Font size with which to display text", fontSize, 0, 10000));
                PropertiesQuery annotationQuery = new PropertiesQuery("Annotation Properties", window.gtk_window, annotationProperties);

                if (annotationQuery.run() == Gtk.ResponseType.APPLY) {
                    text = PropertyItemString.get_data(annotationProperties, "Text");
                    fontSize = PropertyItemDouble.get_data(annotationProperties, "Font Size");

                    annotation.text = text;
                    annotation.fontSize = fontSize;
                }
            }
        }
    }

    public void adjust_wires(int x, int y) {
        foreach (WireInst wireInst in customComponentDef.wireInsts) {
            if (wireInst.find(x, y) != null) {
                PropertySet wireProperties = new PropertySet("Wire", "Wire Properties");

                PropertyItemSelection selection = new PropertyItemSelection("Initial Signal", "Wire's preset signal at the start of simulation");
                selection.add_option("default", "Default");
                selection.add_option("0", "0 (False)");
                selection.add_option("1", "1 (True)");
                switch (wireInst.presetSignal) {
                case WireInst.PresetSignal.DEFAULT:
                    selection.set_option("default");
                    break;
                case WireInst.PresetSignal.FALSE:
                    selection.set_option("0");
                    break;
                case WireInst.PresetSignal.TRUE:
                    selection.set_option("1");
                    break;
                }

                wireProperties.add_item(selection);
                PropertiesQuery wireQuery = new PropertiesQuery("Wire Properties", window.gtk_window, wireProperties);

                if (wireQuery.run() == Gtk.ResponseType.APPLY) {
                    switch (selection.get_option()) {
                    case "default":
                        wireInst.presetSignal = WireInst.PresetSignal.DEFAULT;
                        break;
                    case "0":
                        wireInst.presetSignal = WireInst.PresetSignal.FALSE;
                        break;
                    case "1":
                        wireInst.presetSignal = WireInst.PresetSignal.TRUE;
                        break;
                    }
                }
            }
            if (wireInst.find_tag(x, y) == 1) {
                tag_wire (wireInst.interfaceTag.xWire, wireInst.interfaceTag.yWire, wireInst.interfaceTag.xTag, wireInst.interfaceTag.yTag, true);
            }
        }
    }

    /**
     * Selects any components on the point (//x//, //y//), deselecting
     * others.
     * If //toggle// is true, it toggles if on (//x//, //y//) instead.
     */
    public void select_components(int x, int y, bool toggle) {
        foreach (ComponentInst componentInst in customComponentDef.componentInsts) {
            componentInst.try_select(x, y, toggle);
        }
    }

    /**
     * Selects any wires passing through (//x//, //y//), deselecting
     * others.
     * If //toggle// is true, it toggles if on (//x//, //y//) instead.
     */
    public void select_wires(int x, int y, bool toggle, bool includeTag = true) {
        foreach (WireInst wireInst in customComponentDef.wireInsts) {
            wireInst.try_select(x, y, toggle, includeTag);
        }
    }

    /**
     * Selects any annotations on the point (//x//, //y//), deselecting
     * others.
     * If //toggle// is true, it toggles if on (//x//, //y//) instead.
     */
    public void select_annotations(int x, int y, bool toggle) {
        foreach (Annotation annotation in customComponentDef.annotations) {
            annotation.try_select(x, y, toggle);
        }
    }

    /**
     * Translates any selected components by //x// horizontally, //y//
     * vertically. If //ignoreSelect// is true, all components move.
     */
    public void move_components(int x, int y, bool ignoreSelect, bool autoBind = false) {
        foreach (ComponentInst componentInst in customComponentDef.componentInsts) {
            componentInst.move(x, y, false);
            if (componentInst.selected && autoBind) {
                auto_connect_component(componentInst);
            }
        }
    }

    /**
     * Translates any selected wires by //x// horizontally, //y//
     * vertically. If //ignoreSelect// is true, all wires move.
     */
    public void move_wires(int x, int y, bool ignoreSelect, bool autoBind = false) {
        foreach (WireInst wireInst in customComponentDef.wireInsts) {
            wireInst.move(x, y, false);
            if (wireInst.selected && autoBind) {
                auto_connect_wire(wireInst);
            }
        }
    }

    /**
     * Translates any selected annotations by //x// horizontally, //y//
     * vertically. If //ignoreSelect// is true, all annotations move.
     */
    public void move_annotations(int x, int y, bool ignoreSelect) {
        foreach (Annotation annotation in customComponentDef.annotations) {
            annotation.move(x, y, false);
        }
    }

    /**
     * Flips any selected components.
     */
    public void flip_component(bool autoBind = false) {
        foreach (ComponentInst componentInst in customComponentDef.componentInsts) {
            componentInst.flip(false);
            if (componentInst.selected && autoBind) {
                auto_connect_component(componentInst);
            }
        }
    }

    /**
     * Changes the rotation of any selected components.
     */
    public void orientate_component(Direction direction, bool autoBind = false) {
        foreach (ComponentInst componentInst in customComponentDef.componentInsts) {
            componentInst.orientate(direction, false);
            if (componentInst.selected && autoBind) {
                auto_connect_component(componentInst);
            }
        }
    }

    /**
     * Deletes any components at (//x//, //y//).
     */
    public void delete_components(int x, int y) {
        select_components(x, y, false);
        customComponentDef.delete_selected_components();
    }

    /**
     * Deletes any wires passing through (//x//, //y//).
     */
    public void delete_wires(int x, int y) {
        select_wires(x, y, false, false);
        customComponentDef.delete_selected_wires();
        if (hasPath) {
            if (currentPath.find(x, y) != 0) {
                hasPath = false;
            }
        }
    }

    /**
     * Deletes any tags at (//x//, //y//).
     */
    public void delete_tags(int x, int y) {
        foreach (WireInst wireInst in customComponentDef.wireInsts) {
            if (wireInst.find_tag(x, y) == 1) {
                wireInst.interfaceTag = null;
            }
        }
    }

    /**
     * Deletes any annotations at (//x//, //y//).
     */
    public void delete_annotations(int x, int y) {
        select_annotations(x, y, false);
        customComponentDef.delete_selected_annotations();
    }

    /**
     * Saves the component being designed to the file specified by
     * //fileName//.
     */
    public int save_component(string filename) {
        CustomComponentDef[] componentChain;

        stderr.printf("Checking circuit for cyclic dependences before saving.\n");
        componentChain = customComponentDef.validate_dependencies({});

        if (componentChain != null) {
            string errorMessage = "";

            stderr.printf("Component Failed Cyclic Dependency Test\n");
            foreach (CustomComponentDef customComponentDef in componentChain) {
                errorMessage += "  " + customComponentDef.name + "\n";
            }

            stderr.printf("Circuit failed validation check.\n");
            Gtk.MessageDialog messageDialog = new Gtk.MessageDialog(
                null,
                Gtk.DialogFlags.MODAL,
                Gtk.MessageType.ERROR,
                Gtk.ButtonsType.OK,
                "You cannot save this circuit because it contains a cyclic dependency. This means that it contains something which contains itself. The failed ancestry is shown:\n%s",
                errorMessage
            );

            messageDialog.run();
            messageDialog.destroy();
        } else {
            customComponentDef.save(filename);
            customComponentDef.filename = filename;
        }

        return 0;
    }

    /**
     * Starts a Customiser to prepare the component being designed for
     * insertion and wiring in another component.
     */
    public void customise_component() {
        Customiser customiser = new Customiser(window, customComponentDef, project);

        customiser.run();

        window.update_title();

        project.update_custom_menus();
    }

    /**
     * Renders the current component's design.
     */
    public void render(Cairo.Context context, bool showHints = false, bool showErrors = false, bool colourBackgrounds = true) {
        if (!hasComponent) {
            Cairo.TextExtents textExtents;
            context.set_font_size(12.0);
            context.text_extents("There is no component.", out textExtents);
            context.translate(-textExtents.width / 2, +textExtents.height / 2);
            context.set_source_rgb(0.75, 0.75, 0.75);
            context.paint();
            context.set_source_rgb(0, 0, 0);
            context.show_text("There is no component.");
            context.stroke();
            return;
        }

        customComponentDef.render_insts(context, showHints, showErrors, colourBackgrounds);

        context.set_source_rgb(0.5, 0.5, 0.5);

        if (hasPath) {
            currentPath.render(context);
        }
    }
}
