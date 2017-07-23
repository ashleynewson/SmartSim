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
 *   Filename: componentdef/def-reader.vala
 *
 *   Copyright Ashley Newson 2013
 */


public class ReaderComponentDef : ComponentDef {
    private const string infoFilename = Config.resourcesDir + "components/info/reader.xml";


    public ReaderComponentDef() throws ComponentDefLoadError.LOAD {
        try {
            load_from_file(infoFilename);
        } catch {
            stdout.printf("Failed to load built in component \"%s\"\n", infoFilename);
            throw new ComponentDefLoadError.LOAD("Failed to load \"" + infoFilename + "\"\n");
        }
    }

    public override void compile_component(CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
        Connection inputWire = new Connection.fake();

        foreach (Connection connection in connections) {
            if (connection.wireInst == componentInst.pinInsts[0].wireInsts[0]) {
                inputWire = connection;
            }
        }

        ComponentState componentState = new ReaderComponentState(inputWire, ancestry, componentInst);

        compiledCircuit.add_component(componentState);
    }
}
