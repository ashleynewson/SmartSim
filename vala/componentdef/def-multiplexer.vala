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
 *   Filename: componentdef/def-multiplexer.vala
 *
 *   Copyright Ashley Newson 2013
 */


public class MultiplexerComponentDef : ComponentDef {
    private const string infoFilename = Config.resourcesDir + "components/info/multiplexer.xml";

    public MultiplexerComponentDef() throws ComponentDefLoadError.LOAD {
        try {
            load_from_file(infoFilename);
        } catch {
            stdout.printf("Failed to load built in component \"%s\"\n", infoFilename);
            throw new ComponentDefLoadError.LOAD("Failed to load \"" + infoFilename + "\"\n");
        }
    }

    public override void compile_component(CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
        Connection[] selectWires = new Connection[componentInst.pinInsts[0].arraySize];
        Connection[] dataWires = new Connection[componentInst.pinInsts[1].arraySize];
        Connection outputWire = new Connection.fake();

        foreach (Connection connection in connections) {
            for (int i = 0; i < componentInst.pinInsts[0].arraySize; i++) {
                WireInst wireInst = componentInst.pinInsts[0].wireInsts[i];
                if (connection.wireInst == wireInst) {
                    selectWires[i] = connection;
                }
            }
            for (int i = 0; i < componentInst.pinInsts[1].arraySize; i++) {
                WireInst wireInst = componentInst.pinInsts[1].wireInsts[i];
                if (connection.wireInst == wireInst) {
                    dataWires[i] = connection;
                }
            }
            if (connection.wireInst == componentInst.pinInsts[2].wireInsts[0]) {
                outputWire = connection;
            }
        }

        ComponentState componentState = new MultiplexerComponentState(selectWires, dataWires, outputWire, ancestry, componentInst);

        compiledCircuit.add_component(componentState);
    }

    public override void configure_inst(ComponentInst componentInst, bool firstLoad = false) {
        int selectWires = componentInst.pinInsts[0].arraySize;
        int dataWires = 1 << selectWires;
        bool changedWires = false;

        if (dataWires != componentInst.pinInsts[1].arraySize) {
            componentInst.detatch_all();

            componentInst.pinInsts[1] = new PinInst(pinDefs[1], dataWires);

            changedWires= true;
        }

        if (changedWires || firstLoad) {
            componentInst.downBound =   15 + (dataWires-1)   * (int)pinDefs[1].minSpace / 2;
            componentInst.rightBound =  10 + (selectWires-1) * (int)pinDefs[0].minSpace / 2;
            componentInst.upBound =    -15 - (dataWires-1)   * (int)pinDefs[1].minSpace / 2;
            componentInst.leftBound =  -10 - (selectWires-1) * (int)pinDefs[0].minSpace / 2;

            for (int i = 0; i < selectWires; i++) {
                componentInst.pinInsts[0].y[i] = componentInst.upBound + i * (int)pinDefs[0].minSpace / 2 + 5;
                componentInst.pinInsts[0].yConnect[i] = componentInst.upBound + i * (int)pinDefs[0].minSpace / 2 + 5 - pinDefs[0].length;
            }
            for (int i = 0; i < dataWires; i++) {
                componentInst.pinInsts[1].x[i] = componentInst.leftBound;
                componentInst.pinInsts[1].xConnect[i] = componentInst.leftBound - pinDefs[0].length;
            }
            componentInst.pinInsts[2].x[0] = componentInst.rightBound;
            componentInst.pinInsts[2].xConnect[0] = componentInst.rightBound + pinDefs[0].length;
        }
    }

    public override void extra_render(Cairo.Context context, Direction direction, bool flipped, ComponentInst? componentInst) {
        Cairo.Matrix oldMatrix;

        if (componentInst == null) {
            return;
        }

        oldMatrix = context.get_matrix();

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

        context.set_source_rgb(0, 0, 0);

        context.set_line_width(2);

        context.move_to(componentInst.leftBound, componentInst.upBound);
        context.line_to(componentInst.rightBound, componentInst.upBound + componentInst.rightBound);
        context.line_to(componentInst.rightBound, componentInst.downBound - componentInst.rightBound);
        context.line_to(componentInst.leftBound, componentInst.downBound);
        context.close_path();

        context.stroke();

        context.set_line_width(1);

        context.set_matrix(oldMatrix);
    }
}
