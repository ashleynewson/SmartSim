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
 *   Filename: compiledcircuit.vala
 *
 *   Copyright Ashley Newson 2013
 */


/**
 * Handles the back-end for simulation tasks.
 *
 * Used for high-level validation, compilation, and simulation.
 */
public class CompiledCircuit {
    /**
     * The Root Component is the component being simulated
     * (with its dependencies).
     */
    public CustomComponentDef rootComponent;
    public Project project;
    /**
     * Messages for errors which result in the compilation or simulation
     * failing.
     */
    public string errorMessage {
        public get;
        private set;
        default = "";
    }
    /**
     * Messages for problems which will allow a simulation to continue,
     * but will likely cause unexpected behaviour or later failure.
     */
    public string warningMessage {
        public get;
        private set;
        default = "";
    }
    /**
     * If true, an error has occurred, so do not proceed.
     */
    public bool errorOccurred {
        public get;
        private set;
        default = false;
    }
    /**
     * If true, a warning has occurred.
     */
    public bool warningOccurred {
        public get;
        private set;
        default = false;
    }

    private WireState[] wireStates;
    private ComponentState[] componentStates;

    private WireState[] watchedWireStates;

    public UpdateQueue<WireState> renderWireStates;
    public UpdateQueue<ComponentState> renderComponentStates;
    public UpdateQueue<WireState> processWireStates;
    public UpdateQueue<ComponentState> processComponentStates;

    /**
     * Specifies the exact component in the hierarchical design is being
     * viewed.
     */
    private ComponentInst[] viewedAncestry;
    /**
     * The definition of the component being viewed.
     */
    public CustomComponentDef viewedComponent;
    public int iterationCount;

    /**
     * Prepares for tasks within the project //project// and sets the
     * Root Component as //rootComponent//.
     */
    public CompiledCircuit(Project project, CustomComponentDef rootComponent) {
        this.rootComponent = rootComponent;
        this.project = project;
        this.iterationCount = 0;
        this.viewedComponent = rootComponent;
        this.viewedAncestry = {};
    }

    /**
     * Appends a message to //errorMessage// and sets //errorOccurred//
     * to true.
     */
    public void appendError(string errorString) {
        errorOccurred = true;
        errorMessage += errorString + "\n";
    }

    /**
     * Appends a message to //warningMessage// and sets //warningOccurred//
     * to true.
     */
    public void appendWarning(string warningString) {
        warningOccurred = true;
        warningMessage += warningString + "\n";
    }

    /**
     * Checks that the circuit can be compiled, and warns about
     * situations which could cause problems.
     *
     * A circuit cannot be compiled if:
     * * a subcomponent contains itself,
     * * any required pins do not have a connection,
     * * pins on custom components without matching interface tags.
     * <<BR>>
     * Warnings include:
     * * overlapping components,
     * * interface tags in custom components without matching pins.
     */
    public int check_validity() {
        CustomComponentDef[] componentChain;
        int pinErrorCountTotal = 0;
        errorMessage = "";
        warningMessage = "";
        int returnState = 0;

        foreach (CustomComponentDef customComponentDef in project.customComponentDefs) {
            foreach (ComponentInst componentInst in customComponentDef.componentInsts) {
                componentInst.errorMark = false;
            }
        }

        stdout.printf("Checking circuit for cyclic dependences.\n");
        componentChain = rootComponent.validate_dependencies({});

        if (componentChain != null) {
            stdout.printf("Component Failed Cyclic Dependency Test\n");
            appendError("Circuit failed cyclic dependency test. Failed ancestry:");
            foreach (CustomComponentDef customComponentDef in componentChain) {
                appendError("  " + customComponentDef.name + ".");
            }
            appendError("");

            returnState += 1;
        }

        stdout.printf("Checking circuit for unsatisfied connections.\n");
        foreach (CustomComponentDef customComponentDef in project.customComponentDefs) {
            int pinErrorCount = 0;

            customComponentDef.update_ids();

            pinErrorCount = customComponentDef.validate_pins();

            pinErrorCountTotal += pinErrorCount;

            if (pinErrorCount > 0) {
                stdout.printf("Component Failed Connection Test\n");
                appendError("Component \"" + customComponentDef.name + "\" has " + pinErrorCount.to_string() + " pin errors.");
            }
        }

        if (pinErrorCountTotal > 0) {
            returnState += 2;
        }

        stdout.printf("Checking custom components for unsatisfied interfaces.\n");
        bool interfaceFailure = false;

        foreach (CustomComponentDef customComponentDef in project.customComponentDefs) {
            if (customComponentDef.validate_interfaces() != 0) {
                interfaceFailure = true;
                stdout.printf("Component Failed Interface Test\n");
                appendError("Component \"" + customComponentDef.name + "\" has unsatisfied interfaces.");
            }
        }

        if (interfaceFailure) {
            returnState += 4;
        }

        foreach (CustomComponentDef customComponentDef in project.customComponentDefs) {
            int errorCount = customComponentDef.validate_overlaps();
            if (errorCount != 0) {
                stdout.printf("Component Failed Overlap Test\n");
                appendWarning("Component \"" + customComponentDef.name + "\" has " + errorCount.to_string() + " overlapping components.");
            }
        }

        return returnState;
    }

    /**
     * High level compilation.
     *
     * Calls lower level components and wires to compile themselves into
     * the CompiledCircuit. Also presets the CompiledCircuit.
     */
    public int compile() {
        rootComponent.compile_component(this, null, {}, {});

        update_displayed();

        ComponentState[] permanentComponentStates = {};

        foreach (ComponentState componentState in componentStates) {
            if (componentState.alwaysUpdate) {
                permanentComponentStates += componentState;
            }
        }

        processComponentStates = new UpdateQueue<ComponentState>(componentStates, permanentComponentStates);
        processComponentStates.full_update();
        processWireStates = new UpdateQueue<WireState>(wireStates, null);
        processWireStates.full_update();

        watchedWireStates = {};

        return 0;
    }

    /**
     * Called by WireInsts. Used to add a wire to the CompiledCircuit,
     * and interfaces it with the higher level if needed.
     */
    public WireState compile_wire(WireInst wireInst, Connection[] connections, ComponentInst[] ancestry) {
        WireState wireState = new WireState(wireInst, ancestry);

        if (wireInst.interfaceTag != null) {
            if (wireInst.interfaceTag.pinid < connections.length) {
                wireState.add_interface(connections[wireInst.interfaceTag.pinid]);
                if (!connections[wireInst.interfaceTag.pinid].isFake) {
                    Connection reflectedConnection = new Connection(wireState, connections[wireInst.interfaceTag.pinid].invert);
                    connections[wireInst.interfaceTag.pinid].wireState.add_interface(reflectedConnection);
                }
            } else {
                stdout.printf("Warning: Cannot link tagged wire.\n");
                if (ancestry.length == 0) {
                    appendWarning("Found interface tag in the root component.");
                } else {
                    appendWarning("Cannot link tagged wire in component \"" + ancestry[ancestry.length-1].componentDef.name + "\".");
                }
            }
        }

        wireState.processQueueID = wireStates.length;
        wireState.compiledCircuit = this;
        wireStates += wireState;

        return wireState;
    }

    public void add_component(ComponentState componentState) {
        componentState.processQueueID = componentStates.length;
        componentState.compiledCircuit = this;
        componentStates += componentState;
    }

    public void add_watch(WireState wireState) {
        if (!(wireState in watchedWireStates)) {
            watchedWireStates += wireState;
        }
    }

    public void remove_watch(WireState wireState) {
        WireState[] newWatchedWireStates = {};

        foreach (WireState watchedWireState in watchedWireStates) {
            if (watchedWireState != wireState) {
                newWatchedWireStates += watchedWireState;
            }
        }

        watchedWireStates = newWatchedWireStates;
    }

    /**
     * Goes through one iteration of the simulation (high level).
     */
    public int update_cycle() {
        bool multiOutputError = false;

        {
            processComponentStates.swap(iterationCount);

            ComponentState componentState;
            while ((componentState = processComponentStates.get_next_element()) != null) {
                componentState.update();
            }
        }

        {
            processWireStates.swap(iterationCount);

            WireState wireState;
            while ((wireState = processWireStates.get_next_element()) != null) {
                if (wireState.users > 1) {
                    multiOutputError = true;
                    wireState.errorMark = true;
                }
                wireState.swap_buffers();
            }
        }

        foreach (WireState wireState in watchedWireStates) {
            wireState.record();
        }

        iterationCount++;

        if (multiOutputError) {
            appendError("Multiple Output Error: Two or more components are using the same wire at once.");

            return 1;
        }

        return 0;
    }

    /**
     * Return to viewing the higher level component.
     */
    public void shrink_component() {
        if (viewedAncestry.length > 0) {
            viewedAncestry.resize(viewedAncestry.length - 1);
            update_displayed();
        }
    }

    /**
     * Change the view to look at what is going on inside a subcomponent.
     */
    public int expand_component(int x, int y) {
        ComponentInst foundComponentInst = viewedComponent.find_inst(x, y);

        if (foundComponentInst != null) {
            if (foundComponentInst.componentDef is CustomComponentDef) {
                viewedAncestry += foundComponentInst;
                update_displayed();
                return 0;
            }
            return 2;
        }

        return 1;
    }

    /**
     * Figure out what components need to be displayed.
     * Used After changing which custom component is being viewed.
     */
    public void update_displayed() {
        ComponentState[] displayedComponentStates = {};
        WireState[] displayedWireStates = {};

        if (viewedAncestry.length > 0) {
            viewedComponent = (CustomComponentDef)(viewedAncestry[viewedAncestry.length - 1].componentDef);
        } else {
            viewedComponent = rootComponent;
        }

        {
            int i = 0;
            foreach (ComponentState componentState in componentStates) {
                if (check_ancestry(componentState.ancestry) == 1) {
                    componentState.display = true;
                    componentState.renderQueueID = i++; // Post Increment;
                    displayedComponentStates += componentState;
                } else {
                    componentState.display = false;
                }
            }
        }

        {
            int i = 0;
            foreach (WireState wireState in wireStates) {
                if (check_ancestry(wireState.ancestry) == 1) {
                    wireState.display = true;
                    wireState.renderQueueID = i++; // Post Increment;
                    displayedWireStates += wireState;
                } else {
                    wireState.display = false;
                }
            }
        }

        renderWireStates = new UpdateQueue<WireState>(displayedWireStates, null);
        renderComponentStates = new UpdateQueue<ComponentState>(displayedComponentStates, null);
    }

    /**
     * Check whether //ancestry// is the same as //viewedAncestry//.
     */
    private int check_ancestry(ComponentInst[] ancestry) {
        if (ancestry.length == viewedAncestry.length) {
            for (int i = 0; i < ancestry.length; i++) {
                if (ancestry[i] != viewedAncestry[i]) {
                    return 0;
                }
            }

            return 1;
        } else {
            return 0;
        }
    }

    /**
     * Interact with any components which are on the point
     * (//xInteract//, //yInteract//).
     */
    public void interact_components(int xInteract, int yInteract) {
        stdout.printf("Simulation Interaction @ (%i, %i)\n", xInteract, yInteract);
        foreach (ComponentState componentState in componentStates) {
            if (componentState.display) {
                if (componentState.componentInst.find(xInteract, yInteract) == 1) {
                    componentState.click();
                    renderComponentStates.add_element(componentState.renderQueueID);
                }
            }
        }
    }

    public WireState? find_wire(int x, int y) {
        stdout.printf("Simulation Find Wire @ (%i, %i)\n", x, y);
        foreach (WireState wireState in wireStates) {
            if (wireState.display) {
                if (wireState.wireInst.find(x, y) != null ||
                    wireState.wireInst.find_tag(x, y) == 1) {
                    return wireState;
                }
            }
        }

        return null;
    }

    /**
     * High level render method which calls the viewedComponent and
     * displayed objects to render. If //fullRender// is false, the
     * viewedComponent's design is not rerendered.
     */
    public void render(Cairo.Context context, bool fullRender = true, float zoom = 1) {
        if (fullRender) {
            context.set_line_width(1.0);
            viewedComponent.render_insts(context, false, true);
        }

        if (zoom < 1.0) {
            context.set_line_width(1.0 / zoom);
        } else {
            context.set_line_width(1.0);
        }

        if (fullRender) {
            foreach (ComponentState componentState in renderComponentStates.elements) {
                componentState.render(context);
            }
        } else {
            ComponentState componentState;
            while ((componentState = renderComponentStates.get_next_element()) != null) {
                componentState.render(context);
            }
        }

        renderComponentStates.swap(iterationCount);

        context.set_antialias(Cairo.Antialias.NONE);

        if (fullRender) {
            foreach (WireState wireState in renderWireStates.elements) {
                wireState.render(context);
            }
        } else {
            WireState wireState;
            while ((wireState = renderWireStates.get_next_element()) != null) {
                wireState.render(context);
            }
        }

        renderWireStates.swap(iterationCount);
    }
}
