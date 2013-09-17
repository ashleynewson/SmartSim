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
 *   Filename: componentstate/state-pe-d-flipflop.vala
 *   
 *   Copyright Ashley Newson 2013
 */


public class PeDFlipflopComponentState : ComponentState {
	private Connection dataWire;
	private Connection clockWire;
	private Connection outputWire;
	private Connection outputNotWire;
	
	private bool output;
	private bool previousClockSignal;
	
	public PeDFlipflopComponentState (Connection dataWire, Connection clockWire, Connection outputWire, Connection outputNotWire, ComponentInst[] ancestry, ComponentInst componentInst) {
		this.dataWire = dataWire;
		this.clockWire = clockWire;
		clockWire.set_affects (this);
		this.outputWire = outputWire;
		this.outputNotWire = outputNotWire;
		
		output = false;
		previousClockSignal = true;
		
		this.ancestry = ancestry;
		this.componentInst = componentInst;
	}
	
	public override void update () {
		if (clockWire.signalState && !previousClockSignal) {
			output = dataWire.signalState;
		}
		
		previousClockSignal = clockWire.signalState;
		
		outputWire.signalState = output;
		outputNotWire.signalState = !output;
	}
}
