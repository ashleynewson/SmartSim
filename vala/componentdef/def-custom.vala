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
 *   Filename: componentdef/def-custom.vala
 *
 *   Copyright Ashley Newson 2013
 */


/**
 * CustomComponentDef load from file errors.
 */
public errordomain CustomComponentDefLoadError {
    NOT_CUSTOM,
    MISSING_DEPENDENCY,
    NAME_CONFLICT,
    INVALID
}

/**
 * Definition of a custom component.
 *
 * A CustomComponentDef is the design and specification of
 * a user defined component, which can be included in another component.
 */
public class CustomComponentDef : ComponentDef {
    /**
     * All the components contained within the design.
     */
    public Gee.Set<ComponentInst> componentInsts;
    /**
     * All the wires contained within the design.
     */
    public Gee.Set<WireInst> wireInsts;
    /**
     * All the annotations contained within the design.
     */
    public Gee.Set<Annotation> annotations;
    /**
     * The project which this component belongs to.
     */
    private weak Project project;

    public ComponentDef[] immediateDependencies;

    /**
     * Creates a new custom component, associated with //project//.
     */
    public CustomComponentDef(Project project) {
        base();

        componentInsts = new Gee.HashSet<ComponentInst>();
        wireInsts = new Gee.HashSet<WireInst>();
        annotations = new Gee.HashSet<Annotation>();
        this.project = project;
    }

    /**
     * Loads a CustomComponentDef from a file using libxml.
     */
    public CustomComponentDef.from_file(string infoFilename, Project project) throws ComponentDefLoadError, CustomComponentDefLoadError {
        try {
            load_from_file(infoFilename);
        } catch (ComponentDefLoadError error) {
            throw error;
        } catch (CustomComponentDefLoadError error) {
            throw error;
        } catch (PluginComponentDefLoadError error) {
            throw new CustomComponentDefLoadError.NOT_CUSTOM("Got Plugin.");
        }

        if (project.resolve_def_name(name) != null) {
            throw new CustomComponentDefLoadError.NAME_CONFLICT("A component with the name \"" + name + "\" already exists. Rename the component which is already open using the customiser dialog, accessible via the component menu.");
        }

        this.project = project;

        try {
            load(infoFilename);
        } catch (CustomComponentDefLoadError error) {
            throw error;
        }

        filename = infoFilename;
    }

    public void get_design_bounds(out int right, out int down, out int left, out int up) {
        right = int.MIN;
        down = int.MIN;
        left = int.MAX;
        up = int.MAX;

        foreach (ComponentInst componentInst in componentInsts) {
            int currentRight;
            int currentDown;
            int currentLeft;
            int currentUp;

            componentInst.absolute_bounds(out currentRight, out currentDown, out currentLeft, out currentUp);

            if (currentRight > right) {
                right = currentRight;
            }
            if (currentDown > down) {
                down = currentDown;
            }
            if (currentLeft < left) {
                left = currentLeft;
            }
            if (currentUp < up) {
                up = currentUp;
            }
        }

        foreach (WireInst wireInst in wireInsts) {
            foreach (Path path in wireInst.paths) {
                if (path.lines.length == 0) {
                    continue;
                }

                if (path.lines[0].x1 > right) {
                    right = path.lines[0].x1;
                }
                if (path.lines[0].y1 > down) {
                    down = path.lines[0].y1;
                }
                if (path.lines[0].x1 < left) {
                    left = path.lines[0].x1;
                }
                if (path.lines[0].y1 < up) {
                    up = path.lines[0].y1;
                }

                foreach (Path.Line line in path.lines) {
                    if (line.x2 > right) {
                        right = line.x2;
                    }
                    if (line.y2 > down) {
                        down = line.y2;
                    }
                    if (line.x2 < left) {
                        left = line.x2;
                    }
                    if (line.y2 < up) {
                        up = line.y2;
                    }
                }
            }

            if (wireInst.interfaceTag != null) {
                if (wireInst.interfaceTag.rightBound > right) {
                    right = wireInst.interfaceTag.rightBound;
                }
                if (wireInst.interfaceTag.downBound > down) {
                    down = wireInst.interfaceTag.downBound;
                }
                if (wireInst.interfaceTag.leftBound < left) {
                    left = wireInst.interfaceTag.leftBound;
                }
                if (wireInst.interfaceTag.upBound < up) {
                    up = wireInst.interfaceTag.upBound;
                }
            }
        }

        foreach (Annotation annotation in annotations) {
            int currentRight = annotation.xPosition + annotation.width;
            int currentDown = annotation.yPosition + annotation.height;
            int currentLeft = annotation.xPosition;
            int currentUp = annotation.yPosition;

            if (currentRight > right) {
                right = currentRight;
            }
            if (currentDown > down) {
                down = currentDown;
            }
            if (currentLeft < left) {
                left = currentLeft;
            }
            if (currentUp < up) {
                up = currentUp;
            }
        }

        if (right < left || down < up) {
            right = 0;
            down = 0;
            left = 0;
            up = 0;
        }
    }

    /**
     * Renders the design of the circuitry.
     * If //showHints// is true, design-aiding elements will be
     * displayed.
     * If //showErrors// is true, errors will be highlighted.
     */
    public void render_insts(Cairo.Context context, bool showHints = false, bool showErrors = false, bool colourBackgrounds = true) {
        foreach (Annotation annotation in annotations) {
            annotation.render(context, showHints);
        }
        foreach (ComponentInst componentInst in componentInsts) {
            componentInst.render(context, showHints, showErrors, colourBackgrounds);
        }
        foreach (WireInst wireInst in wireInsts) {
            wireInst.render(context, showHints);
        }
    }

    public Gee.Set<ComponentInst> get_components_satisfying(Util.TestFunction<ComponentInst> test) {
        return Util.filter_set(componentInsts, test);
    }
    public Gee.Set<WireInst> get_wires_satisfying(Util.TestFunction<WireInst> test) {
        return Util.filter_set(wireInsts, test);
    }
    public Gee.Set<Annotation> get_annotations_satisfying(Util.TestFunction<Annotation> test) {
        return Util.filter_set(annotations, test);
    }

    /**
     * Add a new ComponentInst of type //componentDef//, at
     * (//x//, //y//), facing //direction// to the design.
     */
    public ComponentInst new_component(ComponentDef componentDef, int x, int y, Direction direction) {
        ComponentInst componentInst = new ComponentInst(componentDef, x, y, direction);
        componentInsts.add(componentInst);
        stderr.printf("Added component\n");
        return componentInst;
    }
    /**
     * Add an pre-made component to the design.
     */
    public void add_component(ComponentInst toAdd) {
        componentInsts.add(toAdd);
    }
    public void add_components(Gee.Collection<ComponentInst> toAdd) {
        componentInsts.add_all(toAdd);
    }
    public void add_components_array(ComponentInst[] toAdd) {
        componentInsts.add_all_array(toAdd);
    }

    /**
     * Add a new Annotation at (//x//, //y//), with text //text// of
     * font size //fontSize// to the design.
     */
    public Annotation new_annotation(int x, int y, string text, double fontSize = 12) {
        Annotation annotation = new Annotation(x, y, text, fontSize);
        annotations.add(annotation);
        stderr.printf("Added annotation\n");
        return annotation;
    }
    /**
     * Add an pre-made annotation to the design.
     */
    public void add_annotation(Annotation toAdd) {
        annotations.add(toAdd);
    }
    public void add_annotations(Gee.Collection<Annotation> toAdd) {
        annotations.add_all(toAdd);
    }
    public void add_annotations_array(Annotation[] toAdd) {
        annotations.add_all_array(toAdd);
    }

    /**
     * Adds a new wire to the design and returns it.
     */
    public WireInst new_wire() {
        WireInst wireInst = new WireInst();
        wireInsts.add(wireInst);
        stderr.printf("Added wire\n");
        return wireInst;
    }
    /**
     * Add an pre-made wire to the design.
     */
    public void add_wire(WireInst toAdd) {
        wireInsts.add(toAdd);
    }
    public void add_wires(Gee.Collection<WireInst> toAdd) {
        wireInsts.add_all(toAdd);
    }
    public void add_wires_array(WireInst[] toAdd) {
        wireInsts.add_all_array(toAdd);
    }

    /**
     * Deletes any selected components.
     */
    public void delete_selected_components() {
        delete_components(
            get_components_satisfying((i)=>{return i.selected;})
        );
    }
    /**
     * Deletes specified components from the component.
     */
    public void delete_components(Gee.Collection<ComponentInst> toRemove) {
        foreach (ComponentInst componentInst in toRemove) {
            componentInst.detatch_all();
        }
        componentInsts.remove_all(toRemove);
    }
    public void delete_components_array(ComponentInst[] toRemove) {
        foreach (ComponentInst componentInst in toRemove) {
            componentInst.detatch_all();
        }
        componentInsts.remove_all_array(toRemove);
    }
    public void delete_component(ComponentInst toRemove) {
        toRemove.detatch_all();
        componentInsts.remove(toRemove);
    }

    /**
     * Deletes any selected wires.
     */
    public void delete_selected_wires() {
        delete_wires(
            get_wires_satisfying((i)=>{return i.selected;})
        );
    }
    /**
     * Deletes specified wires from the component.
     */
    public void delete_wires(Gee.Collection<WireInst> toRemove) {
        foreach (WireInst wireInst in toRemove) {
            wireInst.disconnect_components();
        }
        wireInsts.remove_all(toRemove);
    }
    public void delete_wires_array(WireInst[] toRemove) {
        foreach (WireInst wireInst in toRemove) {
            wireInst.disconnect_components();
        }
        wireInsts.remove_all_array(toRemove);
    }
    public void delete_wire(WireInst toRemove) {
        toRemove.disconnect_components();
        wireInsts.remove(toRemove);
    }

    /**
     * Deletes any selected annotations.
     */
    public void delete_selected_annotations() {
        delete_annotations(
            get_annotations_satisfying((i)=>{return i.selected;})
        );
    }
    /**
     * Deletes specified annotations from the component.
     */
    public void delete_annotations(Gee.Collection<Annotation> toRemove) {
        annotations.remove_all(toRemove);
    }
    public void delete_annotations_array(Annotation[] toRemove) {
        annotations.remove_all_array(toRemove);
    }
    public void delete_annotation(Annotation toRemove) {
        annotations.remove(toRemove);
    }

    /**
     * Assigns new unique IDs to components and wires.
     */
    public void update_ids() {
        stdout.printf("Updating Component IDs\n");

        {
            int i = 0;
            foreach (ComponentInst componentInst in componentInsts) {
                componentInst.myID = i++;
            }
        }

        stdout.printf("Updating Wire IDs\n");

        {
            int i = 0;
            foreach (WireInst wireInst in wireInsts) {
                wireInst.myID = i++;
            }
        }
    }

    /**
     * Recursive function to check for any cyclic dependencies. Returns
     * an ancestry up to the point of failure if there is a cyclic
     * dependency, else returns null.
     */
    public CustomComponentDef[]? validate_dependencies(CustomComponentDef[] componentChain) {
        CustomComponentDef[] newComponentChain
            = new CustomComponentDef[componentChain.length + 1];

        for (int i = 0; i < componentChain.length; i++) {
            newComponentChain[i] = componentChain[i];
        }
        newComponentChain[newComponentChain.length-1] = this;

        foreach (CustomComponentDef chainPart in componentChain) {
            if (chainPart == this) {
                return newComponentChain;
            }
        }

        foreach (ComponentInst componentInst in componentInsts) {
            if (componentInst.componentDef is CustomComponentDef) {
                CustomComponentDef[] result;
                result = (componentInst.componentDef as CustomComponentDef).validate_dependencies(newComponentChain);

                if (result != null) {
                    return result;
                }
            }
        }

        return null;
    }

    /**
     * Checks that all ComponentInsts are adequately connected to wires.
     * Returns the number of erroneous components.
     */
    public int validate_pins() {
        int errorCount = 0;

        foreach (ComponentInst componentInst in componentInsts) {
            foreach (PinInst pinInst in componentInst.pinInsts) {
                if (pinInst.validate_connections() == 1) {
                    componentInst.errorMark = true;
                    errorCount++;
                    break;
                }
            }
        }

        return errorCount;
    }

    /**
     * Checks that all pins map to an interface tag. Return 0 on success
     * or 1 on failure.
     */
    public int validate_interfaces() {
        for (int i = 0; i < pinDefs.length; i++) {
            if (resolve_tag_id(i) == null) {
                return 1;
            }
        }

        return 0;
    }

    /**
     * Check for any components sharing the same centre. Return the
     * number of erroneous components.
     */
    public int validate_overlaps() {
        int errorCount = 0;

        ComponentInst[] componentInstsArray = componentInsts.to_array();

        for (int i1 = 0; i1 < componentInstsArray.length; i1++) {
            ComponentInst componentInst1 = componentInstsArray[i1];
            for (int i2 = i1+1; i2 < componentInstsArray.length; i2++) {
                ComponentInst componentInst2 = componentInstsArray[i2];
                if (componentInst1.xPosition == componentInst2.xPosition
                    && componentInst1.yPosition == componentInst2.yPosition) {
                    stdout.printf("Found overlaping components!\n");
                    componentInst1.errorMark = true;
                    componentInst2.errorMark = true;
                    errorCount++;
                }
            }
        }

        return errorCount;
    }

    /**
     * Loads a component from the file //infoFilename//, using libxml.
     */
    public int load(string infoFilename) throws CustomComponentDefLoadError.MISSING_DEPENDENCY, CustomComponentDefLoadError.INVALID {
        if (infoFilename == "") {
            stdout.printf("Defining component later\n");
            return 0;
        }

        stdout.printf("Loading custom component specific data from \"%s\"\n", infoFilename);

        Xml.Doc* xmldoc;
        Xml.Node* xmlroot;
        Xml.Node* xmlnode;

        xmldoc = Xml.Parser.parse_file(infoFilename);

        if (xmldoc == null) {
            stdout.printf("Error loading info xml file \"%s\".\n", infoFilename);
            stdout.printf("File inaccessible.\n");
            return 1;
        }

        xmlroot = xmldoc->get_root_element();

        if (xmlroot == null) {
            stdout.printf("Error loading info xml file \"%s\".\n", infoFilename);
            stdout.printf("File is empty.\n");
            return 1;
        }

        if (xmlroot->name != "custom_component") {
            stdout.printf("Error loading info xml file \"%s\".\n", infoFilename);
            stdout.printf("Wanted \"custom_component\" info, but got \"%s\"\n", xmlroot->name);
            return 1;
        }

        Gee.HashSet<ComponentInst> newComponentInsts = new Gee.HashSet<ComponentInst>();
        Gee.HashSet<WireInst> newWireInsts = new Gee.HashSet<WireInst>();
        Gee.HashSet<Annotation> newAnnotations = new Gee.HashSet<Annotation>();

        for (xmlnode = xmlroot->children; xmlnode != null; xmlnode = xmlnode->next) {
            if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
                continue;
            }

            switch (xmlnode->name) {
            case "wire":
                {
                    WireInst newWireInst = new WireInst.load(xmlnode);

                    newWireInsts.add(newWireInst);
                }
                break;
            case "component":
                {
                    ComponentInst newComponentInst;

                    try {
                        newComponentInst = new ComponentInst.load(xmlnode, project, newWireInsts);
                        newComponentInsts.add(newComponentInst);
                    } catch (ComponentInstLoadError.INVALID error) {
                        stderr.printf("Error adding new component: %s\n", error.message);
                        throw new CustomComponentDefLoadError.INVALID(error.message);
                    } catch (ComponentInstLoadError.MISSING_DEF error) {
                        stderr.printf("Error adding new component: %s\n", error.message);
                        throw new CustomComponentDefLoadError.MISSING_DEPENDENCY(error.message);
                    }

                }
                break;
            case "annotation":
                {
                    try {
                        Annotation newAnnotation = new Annotation.load(xmlnode);
                        newAnnotations.add(newAnnotation);
                    } catch (AnnotationLoadError.EMPTY error) {
                        stderr.printf("Error adding new annotation: %s\n", error.message);
                    }

                }
                break;
            }
        }

        delete xmldoc;

        wireInsts = newWireInsts;
        componentInsts = newComponentInsts;
        annotations = newAnnotations;

        return 0;
    }

    /**
     * Saves the ComponentInst to the file //fileName//, using libxml.
     */
    public int save(string fileName) {
        stdout.printf("Saving Component \"%s\" to \"%s\"\n", name, fileName);

        update_ids();

        Xml.TextWriter xmlWriter = new Xml.TextWriter.filename(fileName);

        xmlWriter.set_indent(true);
        xmlWriter.set_indent_string("\t");

        xmlWriter.start_document();
        xmlWriter.start_element("custom_component");

        stdout.printf("Saving description data...\n");

        xmlWriter.start_element("metadata");
        xmlWriter.start_element("version");
        xmlWriter.write_attribute("smartsim", Core.shortVersionString);
        xmlWriter.end_element();
        xmlWriter.end_element();

        xmlWriter.write_element("name", (name != null) ? name : "Untitled");
        xmlWriter.write_element("description", description);
        xmlWriter.write_element("label", label);
        if (this.graphicReferenceFilename != null) {
            xmlWriter.write_element("graphic", this.graphicReferenceFilename);
        }

        xmlWriter.start_element("bound");
        xmlWriter.write_attribute("right", rightBound.to_string());
        xmlWriter.write_attribute("down", downBound.to_string());
        xmlWriter.write_attribute("left", leftBound.to_string());
        xmlWriter.write_attribute("up", upBound.to_string());
        xmlWriter.end_element();

        xmlWriter.start_element("colour");
        xmlWriter.write_attribute("a", backgroundAlpha.to_string());
        xmlWriter.write_attribute("r", backgroundRed.to_string());
        xmlWriter.write_attribute("g", backgroundGreen.to_string());
        xmlWriter.write_attribute("b", backgroundBlue.to_string());
        xmlWriter.end_element();

        stdout.printf("Saving pin data...\n");

        for (int i = 0; i < pinDefs.length; i ++) {
            pinDefs[i].save(xmlWriter, i);
        }

        stdout.printf("Saving wire data...\n");

        foreach (WireInst wireInst in wireInsts) {
            wireInst.save(xmlWriter);
        }

        stdout.printf("Saving component data...\n");

        foreach (ComponentInst componentInst in componentInsts) {
            componentInst.save(xmlWriter);
        }

        stdout.printf("Saving annotation data...\n");

        foreach (Annotation annotation in annotations) {
            annotation.save(xmlWriter);
        }

        xmlWriter.end_element();
        xmlWriter.end_document();
        xmlWriter.flush();

        stdout.printf("Saving complete...\n");

        return 0;
    }

    /**
     * Recursive method to compile custom components. Compiles to
     * //compiledCircuit//. Compile the //componentInst// representing
     * the custom component. The high level connections are stored in
     * //connections//. The sub-components are part of the ancestry
     * //ancestry//.
     */
    public override void compile_component(CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
        WireState[] localWireStates = {};
        ComponentInst[] newAncestry = {};

        if (componentInst != null) {
            foreach (ComponentInst prevComponentInst in ancestry) {
                newAncestry += prevComponentInst;
            }
            newAncestry += componentInst;
        }

        foreach (WireInst wireInst in wireInsts) {
            WireState wireState = compiledCircuit.compile_wire(wireInst, connections, newAncestry);
            localWireStates += wireState;
        }

        foreach (ComponentInst childComponentInst in componentInsts) {
            childComponentInst.compile_component(compiledCircuit, localWireStates, newAncestry);
        }
    }

    /**
     * Returns the ComponentInst at (//x//, //y//). Returns null if
     * there isn't one.
     */
    public ComponentInst? find_inst(int x, int y) {
        foreach (ComponentInst componentInst in componentInsts) {
            if (componentInst.find(x, y) == 1) {
                return componentInst;
            }
        }
        return null;
    }

    /**
     * Returns the interface tag with the given ID. Returns null if
     * there isn't one.
     */
    public Tag? resolve_tag_id(int tagID) {
        foreach (WireInst wireInst in wireInsts) {
            if (wireInst.interfaceTag != null) {
                if (wireInst.interfaceTag.pinid == tagID) {
                    return wireInst.interfaceTag;
                }
            }
        }

        return null;
    }

    /**
     * Returns the lowest unused interface tag ID in the design.
     */
    public int new_tag_id() {
        int tagID = 0;
        bool keepGoing = true;

        while (keepGoing) {
            keepGoing = false;
            foreach (WireInst wireInst in wireInsts) {
                if (wireInst.interfaceTag != null) {
                    if (wireInst.interfaceTag.pinid == tagID) {
                        keepGoing = true;
                        tagID++;
                    }
                }
            }
        }

        return tagID;
    }

    /**
     * Return the number of interface tags.
     */
    public int count_tags() {
        int tagCount = 0;

        foreach (WireInst wireInst in wireInsts) {
            if (wireInst.interfaceTag != null) {
                tagCount++;
            }
        }

        return tagCount;
    }

    public override void create_information(CircuitInformation circuitInformation) {
        circuitInformation.count_component(this);

        foreach (ComponentInst componentInst in componentInsts) {
            componentInst.componentDef.create_information(circuitInformation);
        }
    }

    public void update_immediate_dependencies(bool includePlugins = false) {
        ComponentDef[] newImmediateDependencies = {};

        foreach (ComponentInst componentInst in componentInsts) {
            if (componentInst.componentDef is CustomComponentDef ||
                (includePlugins == true && componentInst.componentDef is PluginComponentDef)) {
                ComponentDef componentDef = componentInst.componentDef;

                if (!(componentDef in immediateDependencies)) {
                    newImmediateDependencies += componentDef;
                }
            }
        }

        immediateDependencies = newImmediateDependencies;
    }

    public void remove_immediate_dependency(ComponentDef removeComponent) {
        ComponentDef[] newImmediateDependencies = {};

        foreach (ComponentDef componentDef in immediateDependencies) {
            if (componentDef != removeComponent) {
                newImmediateDependencies += componentDef;
            }
        }

        immediateDependencies = newImmediateDependencies;
    }

    ~CustomComponentDef() {
        stdout.printf("Custom Component Destroyed\n");
    }
}
