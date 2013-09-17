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
 *   Filename: componentstate/state-multiplexer.vala
 *   
 *   Copyright Ashley Newson 2013
 */


public class MultiplexerComponentState : ComponentState {
	private Connection[] selectWires;
	private Connection[] dataWires;
	private Connection outputWire;
	
	public MultiplexerComponentState (Connection[] selectWires, Connection[] dataWires, Connection outputWire, ComponentInst[] ancestry, ComponentInst componentInst) {
		this.selectWires = selectWires;
		foreach (Connection selectWire in selectWires) {
			selectWire.set_affects (this);
		}
		this.dataWires = dataWires;
		foreach (Connection dataWire in dataWires) {
			dataWire.set_affects (this);
		}
		this.outputWire = outputWire;
		
		this.ancestry = ancestry;
		this.componentInst = componentInst;
	}
	
	public override void update () {
		bool output = false;
		int selected = 0;
		
		for (int i = 0; i < selectWires.length; i++) {
			selected <<= 1;
			if (selectWires[i].signalState) {
				selected |= 1;
			}
		}
		
		if (selected < dataWires.length) {
			output = dataWires[selected].signalState;
		}
		
		outputWire.signalState = output;
	}
}
