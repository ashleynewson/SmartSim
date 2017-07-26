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
 *   Filename: wireinst.vala
 *
 *   Copyright Ashley Newson 2013
 */


/**
 * An instance of a wire in a design.
 *
 * Holds information about an instance of a wire in a design.
 */
public class WireInst {
    /**
     * Stores information about a connection to a component, including
     * a marker.
     */
    public struct RegisteredComponent {
        weak ComponentInst componentInst;
        Marker marker;
    }

    /**
     * Stores information about all connections to components.
     */
    public RegisteredComponent[] registeredComponents;

    /**
     * IDs are unique to a custom component design.
     */
    public int myID;

    public bool selected = false;

    /**
     * Specifies a coordinate, and whether to display a dot there.
     */
    public struct Marker {
        int x;
        int y;
        bool display;
    }

    /**
     * All path-path binding markers.
     */
    public Marker[] markers;
    /**
     * All paths which make up the wire.
     */
    public Path[] paths;
    /**
     * An interface tag which defines that the wire should link with
     * the higher level. Null if there is no interface tag.
     */
    public Tag interfaceTag;

    public enum PresetSignal {
        DEFAULT,
        FALSE,
        TRUE
    }

    public PresetSignal presetSignal = PresetSignal.DEFAULT;

    /**
     * Creates a new WireInst.
     */
    public WireInst() {
    }

    ~WireInst() {
    }

    /**
     * Loads a WireInst from a file using libxml.
     */
    public WireInst.load(Xml.Node* xmlnode) {
        for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
            switch (xmlattr->name) {
            case "id":
                myID = int.parse(xmlattr->children->content);
                break;
            case "preset":
                switch (xmlattr->children->content) {
                case "true":
                    presetSignal = PresetSignal.TRUE;
                    break;
                case "false":
                    presetSignal = PresetSignal.FALSE;
                    break;
                }
                break;
            }
        }

        for (Xml.Node *xmlnodeWire = xmlnode->children; xmlnodeWire != null; xmlnodeWire = xmlnodeWire->next) {
            if (xmlnodeWire->type != Xml.ElementType.ELEMENT_NODE) {
                continue;
            }

            switch (xmlnodeWire->name) {
            case "path":
                {
                    Path path = null;
                    bool firstLine = true;

                    for (Xml.Node *xmlnodePath = xmlnodeWire->children; xmlnodePath != null; xmlnodePath = xmlnodePath->next) {
                        if (xmlnodePath->type != Xml.ElementType.ELEMENT_NODE) {
                            continue;
                        }

                        switch (xmlnodePath->name) {
                        case "point":
                            {
                                int x = 0;
                                int y = 0;

                                for (Xml.Attr* xmlattr = xmlnodePath->properties; xmlattr != null; xmlattr = xmlattr->next) {
                                    switch (xmlattr->name) {
                                    case "x":
                                        x = int.parse(xmlattr->children->content);
                                        break;
                                    case "y":
                                        y = int.parse(xmlattr->children->content);
                                        break;
                                    }
                                }

                                if (path == null) {
                                    path = new Path(x, y);
                                } else {
                                    path.append(x, y);

                                    firstLine = false;
                                }

                            }
                            break;
                        }
                    }

                    if (path != null && !firstLine) {
                        import_path(path);
                    } else {
                        stderr.printf("Warning: Could not load path from points!\n");
                    }
                }
                break;
            case "marker":
                {
                    int x = 0;
                    int y = 0;

                    for (Xml.Attr* xmlattr = xmlnodeWire->properties; xmlattr != null; xmlattr = xmlattr->next) {
                        switch (xmlattr->name) {
                        case "x":
                            x = int.parse(xmlattr->children->content);
                            break;
                        case "y":
                            y = int.parse(xmlattr->children->content);
                            break;
                        }
                    }

                    mark(x, y);
                }
                break;
            case "tag":
                {
                    string typeString = "";
                    string flowString = "";
                    int xWire = 0;
                    int yWire = 0;
                    int xTag = 0;
                    int yTag = 0;
                    int pinid = 0;
                    string text = "";
                    Tag newTag;

                    for (Xml.Attr* xmlattr = xmlnodeWire->properties; xmlattr != null; xmlattr = xmlattr->next) {
                        switch (xmlattr->name) {
                        case "type":
                            typeString = xmlattr->children->content;
                            break;
                        case "xwire":
                            xWire = int.parse(xmlattr->children->content);
                            break;
                        case "ywire":
                            yWire = int.parse(xmlattr->children->content);
                            break;
                        case "xtag":
                            xTag = int.parse(xmlattr->children->content);
                            break;
                        case "ytag":
                            yTag = int.parse(xmlattr->children->content);
                            break;
                        case "flow":
                            flowString = xmlattr->children->content;
                            break;
                        case "pinid":
                            pinid = int.parse(xmlattr->children->content);
                            break;
                        case "text":
                            text = xmlattr->children->content;
                            break;
                        }
                    }

                    newTag = new Tag(xWire, yWire, xTag, yTag);
                    switch (flowString) {
                    case "in":
                        newTag.flow = Flow.IN;
                        break;
                    case "out":
                        newTag.flow = Flow.OUT;
                        break;
                    case "bi":
                        newTag.flow = Flow.BIDIRECTIONAL;
                        break;
                    }

                    switch (typeString) {
                    case "interface":
                        interfaceTag = newTag;
                        break;
                    }

                    newTag.text = text;
                    newTag.pinid = pinid;
                }
                break;
            }
        }
    }

    /**
     * Adds a path to the wire.
     */
    public void import_path(Path path) {
        Path[] newPaths = paths;
        newPaths += path;
        paths = newPaths;
    }

    /**
     * Registers the component //newComponentInst//, which connects with
     * the wire at (//x//, //y//).
     */
    public void register_component(ComponentInst newComponentInst, int x, int y) {

        foreach (RegisteredComponent registeredComponent in registeredComponents) {
            if (registeredComponent.componentInst == newComponentInst) {
                Marker marker = registeredComponent.marker;
                if (marker.x == x && marker.y == y) {
                    return;
                }
            }
        }

        RegisteredComponent[] newRegisteredComponents = registeredComponents;
        RegisteredComponent newRegisteredComponent = RegisteredComponent();

        Marker newMarker = Marker();

        newMarker.x = x;
        newMarker.y = y;
        newMarker.display = false;

        foreach (Path path in paths) {
            int result = path.find(x, y);

            if (result == 1) {
                newMarker.display = true;
            }
        }

        newRegisteredComponent.componentInst = newComponentInst;
        newRegisteredComponent.marker = newMarker;

        newRegisteredComponents += newRegisteredComponent;

        registeredComponents = newRegisteredComponents;
    }

    /**
     * Unregisters all connections to component //oldComponentInst//.
     */
    public void unregister_component(ComponentInst oldComponentInst) {
        RegisteredComponent[] newRegisteredComponents = {};

        foreach (RegisteredComponent registeredComponent in registeredComponents) {
            if (registeredComponent.componentInst != oldComponentInst) {
                newRegisteredComponents += registeredComponent;
            }
        }

        registeredComponents = newRegisteredComponents;
    }

    /**
     * Unregisters the connection to the component //oldComponentInst//
     * which is at (//x//, //y//).
     */
    public void unregister_component_xy(ComponentInst oldComponentInst, int x, int y) {
        RegisteredComponent[] newRegisteredComponents = {};

        foreach (RegisteredComponent registeredComponent in registeredComponents) {
            Marker marker = registeredComponent.marker;
            if (registeredComponent.componentInst != oldComponentInst || marker.x != x || marker.y != y) {
                newRegisteredComponents += registeredComponent;
            }
        }

        registeredComponents = newRegisteredComponents;
    }

    /**
     * Disconnects from all components. Calls all diconnecting
     * components to lose their connection to the wire.
     */
    public void disconnect_components() {
        foreach (RegisteredComponent registeredComponent in registeredComponents) {
            registeredComponent.componentInst.disconnect_wire(this, false);
        }
        registeredComponents = {};
    }

    /**
     * Merges the data of the WireInst //sourceWireInst// into this
     * WireInst. Paths and connections will be merged, and the interface
     * tag of this component will take priority when merging.
     */
    public void merge(WireInst sourceWireInst) {
        Path[] newPaths = paths;
        Marker[] newMarkers = markers;
        RegisteredComponent[] newRegisteredComponents = registeredComponents;

        foreach (Path path in sourceWireInst.paths) {
            if (!try_merge_paths(path)) {
                newPaths += path;
            } else {
                stderr.printf("Merged Paths\n");
            }
        }

        foreach (Marker marker in sourceWireInst.markers) {
            newMarkers += marker;
        }

        foreach (RegisteredComponent registeredComponent in sourceWireInst.registeredComponents) {
            registeredComponent.componentInst.change_wire(sourceWireInst, this);
            newRegisteredComponents += registeredComponent;
        }

        paths = newPaths;
        markers = newMarkers;
        registeredComponents = newRegisteredComponents;

        if (interfaceTag == null) {
            interfaceTag = sourceWireInst.interfaceTag;
        }
    }

    /**
     * Splits the up a wire at the binding point (//x//, //y//).
     * The new WireInsts created are returned in an array.
     * Paths and connections are reassigned based on where they are.
     * Components are updated to reference the new wires.
     */
    public WireInst[] unmerge(int x, int y) {
        bool foundMarker = false;
        Marker unmergeMarker = Marker();
        WireInst[] wireInsts = {};
        Path[] availablePaths = {};
        Marker[] availableMarkers = {};

        foreach (Marker marker in markers) {
            if (marker.x == x && marker.y == y) {
                unmergeMarker = marker;
                foundMarker = true;
            } else {
                availableMarkers += marker;
            }
        }

        if (!foundMarker) {
            return {this};
        }

        foreach (Path path in paths) {
            if (path.find(unmergeMarker.x, unmergeMarker.y) != 0) {
                WireInst wireInst = new WireInst();
                wireInst.import_path(path);
                wireInsts += wireInst;
            } else {
                availablePaths += path;
            }
        }

        bool keepGoing = true;
        while (keepGoing) {
            keepGoing = false;

            foreach (WireInst wireInst in wireInsts) {
                Marker[] newAvailableMarkers = {};
                foreach (Marker marker in availableMarkers) {
                    if (wireInst.find(marker.x, marker.y) != null) {
                        Path[] newAvailablePaths = {};
                        foreach (Path path in availablePaths) {
                            if (path.find(marker.x, marker.y) != 0) {
                                wireInst.import_path(path);
                                keepGoing = true;
                            } else {
                                newAvailablePaths += path;
                            }
                        }
                        wireInst.mark(marker.x, marker.y);
                        availablePaths = newAvailablePaths;
                    } else {
                        newAvailableMarkers += marker;
                    }
                }
                availableMarkers = newAvailableMarkers;
            }
        }

        foreach (RegisteredComponent registeredComponent in registeredComponents) {
            Marker marker = registeredComponent.marker;
            ComponentInst componentInst = registeredComponent.componentInst;

            componentInst.disconnect_wire(this, false);

            foreach (WireInst wireInst in wireInsts) {
                if (wireInst.find(marker.x, marker.y) != null) {
                    componentInst.try_connect(marker.x, marker.y, wireInst);
                }
            }
        }

        if (interfaceTag != null) {
            foreach (WireInst wireInst in wireInsts) {
                if (wireInst.find(interfaceTag.xWire, interfaceTag.yWire) != null) {
                    wireInst.interfaceTag = interfaceTag;
                    break;
                }
            }
        }

        return wireInsts;
    }

    /**
     * Creates a marker at the point (//x//, //y//).
     */
    public void mark(int x, int y) {
        Marker[] newMarkers = markers;
        Marker marker = Marker();

        marker.x = x;
        marker.y = y;
        marker.display = true;

        newMarkers += marker;

        markers = newMarkers;
    }

    /**
     * Return the Path which is at (//x//, //y//), or null if there
     * isn't one.
     */
    public int find_tag(int x, int y) {
        if (interfaceTag != null) {
            if (x >= interfaceTag.leftBound && x <= interfaceTag.rightBound &&
                y >= interfaceTag.upBound && y <= interfaceTag.downBound) {
                return 1;
            }
        }

        return 0;
    }

    public Path? find(int x, int y) {
        foreach (Path path in paths) {
            if (path.find(x, y) != 0) {
                return path;
            }
        }

        return null;
    }

    public int count_find(int x, int y) {
        int count = 0;

        foreach (Path path in paths) {
            if (path.find(x, y) != 0) {
                count++;
            }
        }

        return count;
    }

    public bool try_merge_paths(Path checkPath) {
        if (checkPath.lines.length == 0) {
            return false;
        }

        int xFirstCheckPath = checkPath.lines[0].x1;
        int yFirstCheckPath = checkPath.lines[0].y1;
        int xLastCheckPath = checkPath.xLast;
        int yLastCheckPath = checkPath.yLast;

        foreach (Path path in paths) {
            if (path.lines.length == 0) {
                continue;
            }

            int xFirstPath = path.lines[0].x1;
            int yFirstPath = path.lines[0].y1;
            int xLastPath = path.xLast;
            int yLastPath = path.yLast;

            if (xFirstCheckPath == xFirstPath && yFirstCheckPath == yFirstPath) {
                path.merge(checkPath, true, true); // Prepend, Reverse.
                return true;
            }
            if (xLastCheckPath == xFirstPath && yLastCheckPath == yFirstPath) {
                path.merge(checkPath, true, false); // Prepend, Reverse.
                return true;
            }
            if (xFirstCheckPath == xLastPath && yFirstCheckPath == yLastPath) {
                path.merge(checkPath, false, false); // Prepend, Reverse.
                return true;
            }
            if (xLastCheckPath == xLastPath && yLastCheckPath == yLastPath) {
                path.merge(checkPath, false, true); // Prepend, Reverse.
                return true;
            }
        }

        return false;
    }

    /**
     * Creates a tag going from (//x1//, //y1//) to (//x2//, //y2//).
     */
    public Tag set_tag(int x1, int y1, int x2, int y2) {
        bool found1 = (find(x1, y1) != null);
        bool found2 = (find(x2, y2) != null);

        if (found1 && found2) {
            interfaceTag = null;
        } else if (found1 || found2) {
            int xDiff = x2 - x1;
            int yDiff = y2 - y1;
            int xDiffAbs = (xDiff > 0) ? xDiff : -xDiff;
            int yDiffAbs = (yDiff > 0) ? yDiff : -yDiff;

            if (found1) {
                if (xDiffAbs < yDiffAbs) {
                    x2 = x1;
                } else {
                    y2 = y1;
                }
                interfaceTag = new Tag(x1, y1, x2, y2);
                interfaceTag.flow = Flow.OUT;
            } else {
                if (xDiffAbs < yDiffAbs) {
                    x1 = x2;
                } else {
                    y1 = y2;
                }
                interfaceTag = new Tag(x2, y2, x1, y1);
                interfaceTag.flow = Flow.IN;
            }
            return interfaceTag;
        }

        return (Tag)null;
    }

    /**
     * Selects if the WireInst is on the point (//x//, //y//), else
     * it deselects.
     * If //toggle// is true, it toggles if on (//x//, //y//) instead.
     */
    public void try_select(int x, int y, bool toggle, bool includeTag = true) {
        bool affect = false;

        if (find(x, y) != null) {
            affect = true;
        }
        if (includeTag) {
            if (find_tag(x, y) == 1) {
                affect = true;
            }
        }

        if (toggle) {
            if (affect) {
                selected = selected ? false : true;
            }
        } else {
            if (affect) {
                selected = true;
            } else {
                selected = false;
            }
        }
    }

    /**
     * Translates the wire instance //x// right, //y// down.
     * If //ignoreSelect// is true, it will move without being selected.
     */
    public void move(int x, int y, bool ignoreSelect) {
        if (ignoreSelect || selected) {
            disconnect_components();

            foreach (Path path in paths) {
                path.move(x, y);
            }
            for (int i = 0; i < markers.length; i++) {
                markers[i].x += x;
                markers[i].y += y;
            }

            if (interfaceTag != null) {
                interfaceTag.xTag += x;
                interfaceTag.yTag += y;
                interfaceTag.xWire += x;
                interfaceTag.yWire += y;
                interfaceTag.calculate_bounds();
            }
        }
    }

    /**
     * Saves the WireInst to a file using libxml.
     */
    public void save(Xml.TextWriter xmlWriter) {
        xmlWriter.start_element("wire");

        xmlWriter.write_attribute("id", myID.to_string());
        switch (presetSignal) {
        case PresetSignal.FALSE:
            xmlWriter.write_attribute("preset", "false");
            break;
        case PresetSignal.TRUE:
            xmlWriter.write_attribute("preset", "true");
            break;
        }

        foreach (Path path in paths) {
            xmlWriter.start_element("path");

            foreach (Path.Line line in path.lines) {
                xmlWriter.start_element("point");

                xmlWriter.write_attribute("x", line.x1.to_string());
                xmlWriter.write_attribute("y", line.y1.to_string());

                xmlWriter.end_element();
            }

            xmlWriter.start_element("point");
            xmlWriter.write_attribute("x", path.xLast.to_string());
            xmlWriter.write_attribute("y", path.yLast.to_string());
            xmlWriter.end_element();

            xmlWriter.end_element();
        }

        foreach (Marker marker in markers) {
            xmlWriter.start_element("marker");

            xmlWriter.write_attribute("x", marker.x.to_string());
            xmlWriter.write_attribute("y", marker.y.to_string());

            xmlWriter.end_element();
        }

        if (interfaceTag != null) {
            xmlWriter.start_element("tag");

            xmlWriter.write_attribute("type", "interface");

            xmlWriter.write_attribute("xwire", interfaceTag.xWire.to_string());
            xmlWriter.write_attribute("ywire", interfaceTag.yWire.to_string());
            xmlWriter.write_attribute("xtag", interfaceTag.xTag.to_string());
            xmlWriter.write_attribute("ytag", interfaceTag.yTag.to_string());
            string tmpString = "";
            switch (interfaceTag.flow) {
            case Flow.IN:
                tmpString = "in";
                break;
            case Flow.OUT:
                tmpString = "out";
                break;
            case Flow.BIDIRECTIONAL:
                tmpString = "bi";
                break;
            }
            if (tmpString != "") {
                xmlWriter.write_attribute("flow", tmpString);
            }
            xmlWriter.write_attribute("pinid", interfaceTag.pinid.to_string());
            xmlWriter.write_attribute("text", interfaceTag.text);

            xmlWriter.end_element();
        }

        xmlWriter.end_element();
    }

    /**
     * Renders the wire, using render_colour.
     */
    public void render(Cairo.Context context, bool showHints = false, bool showErrors = false) {
        if (showHints) {
            if (selected) {
                render_colour(context, 0, 0, 1);
            } else if (presetSignal != PresetSignal.DEFAULT) {
                render_colour(context, 0, 0, 0);

                context.set_dash({5.0, 5.0}, 0);
                context.set_line_width(2);

                switch (presetSignal) {
                case PresetSignal.TRUE:
                    render_colour(context, 0.8f, 0, 0);
                    break;
                case PresetSignal.FALSE:
                    render_colour(context, 0, 0, 0.8f);
                    break;
                }

                context.set_dash(null, 0);
                context.set_line_width(1);
            } else {
                render_colour(context, 0, 0, 0);
            }
        } else {
            render_colour(context, 0, 0, 0);
        }
    }

    /**
     * Renders the wire in a given colour, drawing paths and
     * dot juntion markers.
     */
    public void render_colour(Cairo.Context context, float r, float g, float b) {
        context.set_source_rgba(r, g, b, 1);

        foreach (Path path in paths) {
            path.render(context);
        }
        foreach (Marker marker in markers) {
            if (marker.display) {
                context.arc(marker.x, marker.y, 2.5, 0, Math.PI * 2);
                context.fill();
                context.stroke();
            }
        }

        foreach (RegisteredComponent registeredComponent in registeredComponents) {
            Marker marker = registeredComponent.marker;
            if (marker.display) {
                context.arc(marker.x, marker.y, 2.5, 0, Math.PI * 2);
                context.fill();
                context.stroke();
            }
        }

        if (interfaceTag != null) {
            interfaceTag.render(context);
        }
    }
}
