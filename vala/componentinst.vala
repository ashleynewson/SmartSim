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
 *   Filename: componentinst.vala
 *
 *   Copyright Ashley Newson 2013
 */


/**
 * ComponentInst load from file errors.
 */
public errordomain ComponentInstLoadError {
    /**
     * The data specified by the file is invalid.
     */
    INVALID,
    /**
     * There is a missing subcomponent dependency.
     */
    MISSING_DEF
}


/**
 * An instance of a component in a design.
 *
 * Holds information about an instance of a component in a design.
 */
public class ComponentInst {
    /**
     * The component which this is an instance of.
     */
    public weak ComponentDef componentDef;
    /**
     * IDs are unique to a custom component design.
     */
    public int myID;

    public int xPosition;
    public int yPosition;
    public Direction direction;
    public bool flipped = false;

    public int rightBound;
    public int downBound;
    public int leftBound;
    public int upBound;

    /**
     * Some components need extra data which cannot be held in a
     * ComponentInst ordinarily.
     */
    public PropertySet configuration;

    public bool selected = false;

    /**
     * Highlights a component in red when rendered.
     */
    public bool errorMark = false;

    /**
     * Holds information about pins and their connections.
     */
    public PinInst[] pinInsts;

    /**
     * Creates a new component instance of a //componentDef// with
     * details passed.
     */
    public ComponentInst(ComponentDef componentDef, int xPosition, int yPosition, Direction direction, bool flipped = false) {
        this.componentDef = componentDef;

        this.rightBound = componentDef.rightBound;
        this.downBound = componentDef.downBound;
        this.leftBound = componentDef.leftBound;
        this.upBound = componentDef.upBound;

        this.xPosition = xPosition;
        this.yPosition = yPosition;
        this.direction = direction;
        this.flipped = flipped;

        PinInst[] newPinInsts = {};

        foreach (PinDef pinDef in componentDef.pinDefs) {
            PinInst newPinInst;

            if (pinDef.array) {
                newPinInst = new PinInst(pinDef, pinDef.defaultArraySize);
            } else {
                newPinInst = new PinInst(pinDef);
            }
            newPinInsts += newPinInst;
        }

        pinInsts = newPinInsts;
        configuration = new PropertySet(componentDef.name + " configuration");

        componentDef.configure_inst(this, true);
    }

    /**
     * Load a component instance from a file using libxml.
     */
    public ComponentInst.load(Xml.Node* xmlnode, Project project, Gee.Collection<WireInst> newWireInsts) throws ComponentInstLoadError.INVALID, ComponentInstLoadError.MISSING_DEF {
        myID = -1;
        string defName = "";
        componentDef = null;
        xPosition = 0;
        yPosition = 0;
        direction = Direction.RIGHT;
        flipped = false;

        for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
            switch (xmlattr->name) {
            case "id":
                myID = int.parse(xmlattr->children->content);
                break;
            case "def":
                defName = xmlattr->children->content;
                break;
            case "x":
                xPosition = int.parse(xmlattr->children->content);
                break;
            case "y":
                yPosition = int.parse(xmlattr->children->content);
                break;
            case "direction":
                switch (xmlattr->children->content) {
                case "right":
                    direction = Direction.RIGHT;
                    break;
                case "down":
                    direction = Direction.DOWN;
                    break;
                case "left":
                    direction = Direction.LEFT;
                    break;
                case "up":
                    direction = Direction.UP;
                    break;
                }
                break;
            case "flip":
                if (xmlattr->children->content == "true") {
                    flipped = true;
                }
                break;
            }
        }

        ComponentDef temp = (ComponentDef)project.resolve_def_name(defName);
        componentDef = temp;

        if (componentDef != null && myID != -1) {
            PinInst[] newPinInsts = {};
            foreach (PinDef pinDef in componentDef.pinDefs) {
                PinInst newPinInst;

                if (pinDef.array) {
                    newPinInst = new PinInst(pinDef, pinDef.defaultArraySize);
                } else {
                    newPinInst = new PinInst(pinDef);
                }
                newPinInsts += newPinInst;
            }
            pinInsts = newPinInsts;

            componentDef.load_properties(xmlnode, out configuration);

            for (Xml.Node *xmlnodeComponent = xmlnode->children; xmlnodeComponent != null; xmlnodeComponent = xmlnodeComponent->next) {
                if (xmlnodeComponent->type != Xml.ElementType.ELEMENT_NODE) {
                    continue;
                }

                switch (xmlnodeComponent->name) {
                case "connection":
                    {
                        string flow = "";
                        int pinid = -1;
                        int wireid = 0;
                        bool isConnected = false;
                        bool invert = false;

                        for (Xml.Attr* xmlattr = xmlnodeComponent->properties; xmlattr != null; xmlattr = xmlattr->next) {
                            switch (xmlattr->name) {
                            case "flow":
                                flow = xmlattr->children->content;
                                break;
                            case "pinid":
                                pinid = int.parse(xmlattr->children->content);
                                break;
                            case "wireid":
                                if (xmlattr->children->content != "null") {
                                    wireid = int.parse(xmlattr->children->content);
                                    isConnected = true;
                                }
                                break;
                            case "invert":
                                if (xmlattr->children->content == "true") {
                                    invert = true;
                                }
                                break;
                            }
                        }

                        if (pinid >= 0 && pinid < componentDef.pinDefs.length) {
                            if (componentDef.pinDefs[pinid].array) {
                                pinInsts[pinid] = new PinInst(componentDef.pinDefs[pinid], 0);

                                for (Xml.Node *xmlnodeConnection = xmlnodeComponent->children; xmlnodeConnection != null; xmlnodeConnection = xmlnodeConnection->next) {
                                    if (xmlnodeConnection->type != Xml.ElementType.ELEMENT_NODE) {
                                        continue;
                                    }

                                    switch (xmlnodeConnection->name) {
                                    case "subpin":
                                        {
                                            wireid = 0;
                                            invert = false;
                                            isConnected = false;

                                            for (Xml.Attr* xmlattr = xmlnodeConnection->properties; xmlattr != null; xmlattr = xmlattr->next) {
                                                switch (xmlattr->name) {
                                                case "wireid":
                                                    if (xmlattr->children->content != "null") {
                                                        wireid = int.parse(xmlattr->children->content);
                                                        isConnected = true;
                                                    }
                                                    break;
                                                case "invert":
                                                    if (xmlattr->children->content == "true") {
                                                        invert = true;
                                                    }
                                                    break;
                                                }
                                            }
                                            int i = pinInsts[pinid].append();
                                            if (isConnected) {
                                                WireInst wireInst = resolve_wire_id(newWireInsts, wireid);
                                                if (wireInst != null) {
                                                    pinInsts[pinid].wireInsts[i] = wireInst;
                                                } else {
                                                    stderr.printf("Error: Missing wire %i\n", wireid);
                                                }
                                            }
                                            pinInsts[pinid].invert[i] = invert;
                                        }
                                        break;
                                    }
                                }
                                for (int i = 0; i < pinInsts[pinid].arraySize; i++) {
                                    WireInst wireInst = pinInsts[pinid].wireInsts[i];
                                    if (wireInst != null) {
                                        int xAbsolute;
                                        int yAbsolute;
                                        absolute_position(pinInsts[pinid].xConnect[i], pinInsts[pinid].yConnect[i], out xAbsolute, out yAbsolute);
                                        wireInst.register_component(this, xAbsolute, yAbsolute);
                                    }
                                }
                            } else {
                                if (isConnected) {
                                    WireInst wireInst = resolve_wire_id(newWireInsts, wireid);
                                    if (wireInst != null) {
                                        pinInsts[pinid].wireInsts[0] = wireInst;
                                        int xAbsolute;
                                        int yAbsolute;
                                        absolute_position(pinInsts[pinid].xConnect[0], pinInsts[pinid].yConnect[0], out xAbsolute, out yAbsolute);
                                        wireInst.register_component(this, xAbsolute, yAbsolute);
                                    } else {
                                        stderr.printf("Error: Missing wire %i\n", wireid);
                                    }
                                }
                                pinInsts[pinid].invert[0] = invert;
                            }
                        } else {
                            stderr.printf("Error: Pin is not within range or is not set\n");
                        }
                    }
                    break;
                }
            }

            this.rightBound = componentDef.rightBound;
            this.downBound = componentDef.downBound;
            this.leftBound = componentDef.leftBound;
            this.upBound = componentDef.upBound;

            componentDef.configure_inst(this, true);
        } else {
            if (componentDef == null) {
                throw new ComponentInstLoadError.MISSING_DEF("Failed to load due to a missing sub component: \"" + defName + "\"");
            } else {
                throw new ComponentInstLoadError.INVALID("Missing critical data on component XML tag. Must have valid id attribute.");
            }
        }
    }

    public void absolute_bounds(out int right, out int down, out int left, out int up) {
        int rightBound = this.rightBound;
        int leftBound = this.leftBound;
        int downBound = flipped ? this.upBound : this.downBound;
        int upBound = flipped ? this.downBound : this.upBound;

        switch (direction) {
        case Direction.RIGHT:
            right = rightBound;
            down = downBound;
            left = leftBound;
            up = upBound;
            break;
        case Direction.DOWN:
            down = rightBound;
            left = -downBound;
            up = leftBound;
            right = -upBound;
            break;
        case Direction.LEFT:
            left = -rightBound;
            up = -downBound;
            right = -leftBound;
            down = -upBound;
            break;
        case Direction.UP:
            up = -rightBound;
            right = downBound;
            down = -leftBound;
            left = upBound;
            break;
        default:
            right = rightBound;
            down = downBound;
            left = leftBound;
            up = upBound;
            break;
        }

        right += xPosition;
        down += yPosition;
        left += xPosition;
        up += yPosition;
    }

    /**
     * Finds a WireInst within an array of WireInsts with a given ID.
     */
    private WireInst? resolve_wire_id(Gee.Collection<WireInst> anyWireInsts, int wireid) {
        foreach (WireInst wireInst in anyWireInsts) {
            if (wireInst.myID == wireid) {
                return wireInst;
            }
        }

        return null;
    }

    /**
     * Converts an absolute position within the circuit design to a
     * position which is relative to the instance.
     */
    public void relative_position(int xRaw, int yRaw, out int xRelative, out int yRelative) {
        int xHalfRelative = xRaw - xPosition;
        int yHalfRelative = yRaw - yPosition;

        switch (direction) {
        case Direction.RIGHT:
            xRelative =  xHalfRelative;
            yRelative =  yHalfRelative;
            break;
        case Direction.DOWN:
            xRelative =  yHalfRelative;
            yRelative = -xHalfRelative;
            break;
        case Direction.LEFT:
            xRelative = -xHalfRelative;
            yRelative = -yHalfRelative;
            break;
        case Direction.UP:
            xRelative = -yHalfRelative;
            yRelative =  xHalfRelative;
            break;
        default:
            xRelative =  xHalfRelative;
            yRelative =  yHalfRelative;
            break;
        }

        if (flipped) {
            yRelative = -yRelative;
        }
    }

    /**
     * Converts a position which is relative to the instance to an
     * absolute position within the circuit design.
     */
    public void absolute_position(int xRelative, int yRelative, out int xRaw, out int yRaw) {
        int xHalfRelative;
        int yHalfRelative;

        if (flipped) {
            yRelative = -yRelative;
        }

        switch (direction) {
        case Direction.RIGHT:
            xHalfRelative =  xRelative;
            yHalfRelative =  yRelative;
            break;
        case Direction.DOWN:
            xHalfRelative = -yRelative;
            yHalfRelative =  xRelative;
            break;
        case Direction.LEFT:
            xHalfRelative = -xRelative;
            yHalfRelative = -yRelative;
            break;
        case Direction.UP:
            xHalfRelative =  yRelative;
            yHalfRelative = -xRelative;
            break;
        default:
            xHalfRelative =  xRelative;
            yHalfRelative =  yRelative;
            break;
        }

        xRaw = xHalfRelative + xPosition;
        yRaw = yHalfRelative + yPosition;
    }

    /**
     * If a pin end is at (//x//, //y//) then toggle its invert.
     */
    public void try_invert(int x, int y) {
        int xRelative, yRelative;
        relative_position(x, y, out xRelative, out yRelative);

        foreach (PinInst pinInst in pinInsts) {
            pinInst.try_invert(xRelative, yRelative);
        }
    }

    /**
     * Selects if the ComponentInst is on the point (//x//, //y//), else
     * it deselects.
     * If //toggle// is true, it toggles if on (//x//, //y//) instead.
     */
    public void try_select(int x, int y, bool toggle) {
        int xRelative, yRelative;
        relative_position(x, y, out xRelative, out yRelative);

        bool affect;

        if (
            xRelative >= leftBound &&
            xRelative <= rightBound &&
            yRelative >= upBound &&
            yRelative <= downBound
        ) {
            affect = true;
        } else {
            affect = false;
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
     * Changes any pin connections which reference the wire
     * //replaceWhat// to reference //replaceWith//.
     */
    public void change_wire(WireInst replaceWhat, WireInst replaceWith) {
        stderr.printf("Reconnecting component\n");

        for (int i = 0; i < pinInsts.length; i ++) {
            for (int i2 = 0; i2 < pinInsts[i].arraySize; i2 ++) {
                if (replaceWhat == pinInsts[i].wireInsts[i2]) {
                    pinInsts[i].wireInsts[i2] = replaceWith;
                    stderr.printf("Component connection changed: %i, %i\n", i, i2);
                }
            }
        }
    }

    /**
     * Disconnects the component from all wires.
     */
    public void detatch_all() {
        stderr.printf("Disconnecting component completely\n");

        for (int i = 0; i < pinInsts.length; i ++) {
            for (int i2 = 0; i2 < pinInsts[i].arraySize; i2 ++) {
                if (pinInsts[i].wireInsts[i2] != null) {
                    pinInsts[i].wireInsts[i2].unregister_component(this);
                    pinInsts[i].wireInsts[i2] = null;
                    stderr.printf("Component input disconnected: %i\n", i);
                }
            }
        }
    }

    /**
     * Disconnects from a specified wire. If //callWire// is false, the
     * wire will not be told to unregister the component (for when the
     * wire triggers the disconnection).
     */
    public void disconnect_wire(WireInst wireInst, bool callWire = true) {
        stderr.printf("Disconnecting component\n");

        for (int i = 0; i < pinInsts.length; i ++) {
            for (int i2 = 0; i2 < pinInsts[i].arraySize; i2 ++) {
                if (wireInst == pinInsts[i].wireInsts[i2]) {
                    if (callWire) {
                        pinInsts[i].wireInsts[i2].unregister_component(this);
                    }
                    pinInsts[i].wireInsts[i2] = null;
                    stderr.printf("Component input disconnected: %i\n", i);
                }
            }
        }
    }

    /**
     * If a pin end is at (//x//, //y//) connect it to //wireInst//.
     */
    public bool try_connect(int x, int y, WireInst wireInst) {
        int xRelative, yRelative;
        relative_position(x, y, out xRelative, out yRelative);

        for (int i = 0; i < pinInsts.length; i ++) {
            PinInst pinInst = pinInsts[i];
            if (pinInst.show) {
                if (pinInst.try_connect(xRelative, yRelative, wireInst, this)) {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * If a pin end is at (//x//, //y//) disconnect it from
     * //wireInst//.
     */
    public bool try_disconnect(int x, int y) {
        int xRelative, yRelative;
        relative_position(x, y, out xRelative, out yRelative);

        for (int i = 0; i < pinInsts.length; i ++) {
            PinInst pinInst = pinInsts[i];
            if (pinInst.try_disconnect(xRelative, yRelative, this)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Translates the component instance //x// right, //y// down.
     * If //ignoreSelect// is true, it will move without being selected.
     */
    public void move(int x, int y, bool ignoreSelect) {
        if (ignoreSelect || selected) {
            detatch_all();

            xPosition += x;
            yPosition += y;
        }
    }

    /**
     * Flips the component along its length. (Top flipped with bottom
     * when direction is right).
     * If //ignoreSelect// is true, it will flip without being selected.
     */
    public void flip(bool ignoreSelect) {
        if (ignoreSelect || selected) {
            flipped = flipped ? false : true;

            detatch_all();
        }
    }

    /**
     * Changes the rotation of the component.
     * If //ignoreSelect// is true, it will rotate without being
     * selected.
     */
    public void orientate(Direction direction, bool ignoreSelect) {
        if (ignoreSelect || selected) {
            this.direction = direction;

            detatch_all();
        }
    }

    /**
     * Return 1 if the component instance is at (//x//, //y//).
     */
    public int find(int x, int y) {
        int xRelative, yRelative;
        relative_position(x, y, out xRelative, out yRelative);

        if (
            xRelative >= leftBound &&
            xRelative <= rightBound &&
            yRelative >= upBound &&
            yRelative <= downBound
            ) {
            return 1;
        }
        return 0;
    }

    /**
     * Compiles a component instance by creating and passing connections
     * to //componentDef//'s compile method.
     */
    public void compile_component(CompiledCircuit compiledCircuit, WireState[] localWireStates, ComponentInst[] ancestry) {
        Connection[] connections = {};

        foreach (PinInst pinInst in pinInsts) {
            for (int i = 0; i < pinInst.arraySize; i++) {
                WireInst wireInst = pinInst.wireInsts[i];
                if (wireInst == null) {
                    connections += new Connection.fake();
                    continue;
                }
                foreach (WireState wireState in localWireStates) {
                    if (wireState.wireInst == wireInst) {
                        connections += new Connection(wireState, pinInst.invert[i]);
                    }
                }
            }
        }

        componentDef.compile_component(compiledCircuit, this, connections, ancestry);
    }

    /**
     * Saves all information about the component instance to an xml
     * document using libxml.
     */
    public void save(Xml.TextWriter xmlWriter) {
        xmlWriter.start_element("component");

        xmlWriter.write_attribute("id", myID.to_string());
        xmlWriter.write_attribute("def", componentDef.name);
        xmlWriter.write_attribute("x", xPosition.to_string());
        xmlWriter.write_attribute("y", yPosition.to_string());
        string tmpString;
        switch (direction) {
        case Direction.RIGHT:
            tmpString = "right";
            break;
        case Direction.DOWN:
            tmpString = "down";
            break;
        case Direction.LEFT:
            tmpString = "left";
            break;
        case Direction.UP:
            tmpString = "up";
            break;
        default:
            tmpString = "right";
            break;
        }
        xmlWriter.write_attribute("direction", tmpString);
        xmlWriter.write_attribute("flip", flipped ? "true" : "false");

        componentDef.save_properties(xmlWriter, configuration);

        for (int i = 0; i < pinInsts.length; i ++) {
            PinInst pinInst = pinInsts[i];

            xmlWriter.start_element("connection");

            switch (pinInst.pinDef.flow) {
            case Flow.IN:
                xmlWriter.write_attribute("flow", "in");
                break;
            case Flow.OUT:
                xmlWriter.write_attribute("flow", "out");
                break;
            }

            xmlWriter.write_attribute("pinid", i.to_string());

            if (pinInst.pinDef.array) {
                for (int i2 = 0; i2 < pinInst.arraySize; i2 ++) {
                    xmlWriter.start_element("subpin");
                    if (pinInst.wireInsts[i2] != null) {
                        xmlWriter.write_attribute("wireid", pinInst.wireInsts[i2].myID.to_string());
                    } else {
                        xmlWriter.write_attribute("wireid", "null");
                    }
                    xmlWriter.write_attribute("invert", pinInst.invert[i2] ? "true" : "false");
                    xmlWriter.end_element();
                }
            } else {
                if (pinInst.wireInsts[0] != null) {
                    xmlWriter.write_attribute("wireid", pinInst.wireInsts[0].myID.to_string());
                } else {
                    xmlWriter.write_attribute("wireid", "null");
                }
                xmlWriter.write_attribute("invert", pinInst.invert[0] ? "true" : "false");
            }

            xmlWriter.end_element();
        }

        xmlWriter.end_element();
    }

    /**
     * Renders the instance as part of a design by calling
     * //componentDef//'s and each PinInst in //pinInsts//' render
     * method.
     * If //showHints// is true, selection is shown as blue, and
     * disconnected pins show as red.
     * If //showErrors// is true and instance is erroneous, it
     * highlights the instance in red.
     */
    public void render(Cairo.Context context, bool showHints = false, bool showErrors = false, bool colourBackgrounds = true) {
        Cairo.Matrix oldMatrix;

        oldMatrix = context.get_matrix();

        context.translate(xPosition, yPosition);

        componentDef.render(context, direction, flipped, this, colourBackgrounds); // Handles its own transformations.

        double angle = 0;

        switch (direction) {
        case Direction.RIGHT:
            angle = 0;
            break;
        case Direction.DOWN:
            angle = Math.PI * 0.5;
            break;
        case Direction.LEFT:
            angle = Math.PI;
            break;
        case Direction.UP:
            angle = Math.PI * 1.5;
            break;
        }
        context.rotate(angle);

        if (flipped) {
            context.scale(1.0, -1.0);
        }

        foreach (PinInst pinInst in pinInsts) {
            pinInst.render(context, showHints);

            context.set_source_rgb(0, 0, 0);

            switch (pinInst.pinDef.direction) {
            case Direction.LEFT:
            case Direction.RIGHT:
                if (pinInst.yMin <= upBound || pinInst.yMax >= downBound) {
                    context.move_to(pinInst.xMin, pinInst.yMin);
                    context.line_to(pinInst.xMin, pinInst.yMax);
                    context.stroke();
                }
                break;
            case Direction.UP:
            case Direction.DOWN:
                if (pinInst.xMin <= leftBound || pinInst.xMax >= rightBound) {
                    context.move_to(pinInst.xMin, pinInst.yMin);
                    context.line_to(pinInst.xMax, pinInst.yMin);
                    context.stroke();
                }
                break;
            }
        }

        context.set_source_rgb(0, 0, 0);
        if (selected && showHints) {
            context.set_source_rgba(0, 0, 1, 0.25);
            context.rectangle(leftBound, upBound, rightBound - leftBound, downBound - upBound);
            context.fill();
            context.stroke();
            context.set_source_rgba(0, 0, 0, 1);
        }
        if (errorMark && showErrors) {
            context.set_source_rgba(1, 0, 0, 0.25);
            context.rectangle(leftBound, upBound, rightBound - leftBound, downBound - upBound);
            context.fill();
            context.stroke();
            context.set_source_rgba(0, 0, 0, 1);
        }

        context.set_matrix(oldMatrix);
    }

    ~ComponentInst() {
    }
}
