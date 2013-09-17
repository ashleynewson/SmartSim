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
 *   Filename: componentstate/state-tristate.vala
 *   
 *   Copyright Ashley Newson 2013
 */


public class TristateComponentState : ComponentState {
	private Connection inputWire;
	private Connection controlWire;
	private Connection outputWire;
	
	public TristateComponentState (Connection inputWire, Connection controlWire, Connection outputWire, ComponentInst[] ancestry, ComponentInst componentInst) {
		this.inputWire = inputWire;
		inputWire.set_affects (this);
		this.controlWire = controlWire;
		controlWire.set_affects (this);
		this.outputWire = outputWire;
		
		this.ancestry = ancestry;
		this.componentInst = componentInst;
	}
	
	public override void update () {
		bool output;
		
		if (controlWire.signalState) {
			output = inputWire.signalState;
			
			outputWire.signalState = output;
		} else {
			outputWire.disable_signal ();
		}
	}
}
