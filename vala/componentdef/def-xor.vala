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
 *   Filename: componentdef/def-xor.vala
 *
 *   Copyright Ashley Newson 2013
 */


public class XorComponentDef : ComponentDef {
    private const string infoFilename = Config.resourcesDir + "components/info/xor.xml";

    public XorComponentDef() throws ComponentDefLoadError.LOAD {
        try {
            load_from_file(infoFilename);
        } catch {
            stdout.printf("Failed to load built in component \"%s\"\n", infoFilename);
            throw new ComponentDefLoadError.LOAD("Failed to load \"" + infoFilename + "\"\n");
        }
    }

    public override void compile_component(CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
        Connection[] inputWires = new Connection[componentInst.pinInsts[0].arraySize];
        Connection outputWire = new Connection.fake();

        foreach (Connection connection in connections) {
            for (int i = 0; i < componentInst.pinInsts[0].arraySize; i++) {
                WireInst wireInst = componentInst.pinInsts[0].wireInsts[i];
                if (connection.wireInst == wireInst) {
                    inputWires[i] = connection;
                }
            }
            if (connection.wireInst == componentInst.pinInsts[1].wireInsts[0]) {
                outputWire = connection;
            }
        }

        ComponentState componentState = new XorComponentState(inputWires, outputWire, ancestry, componentInst);

        compiledCircuit.add_component(componentState);
    }
}
