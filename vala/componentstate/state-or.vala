/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentstate/or.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class OrComponentState : ComponentState {
	private Connection[] inputWires;
	private Connection outputWire;
	
	public OrComponentState (Connection[] inputWires, Connection outputWire, ComponentInst[] ancestry, ComponentInst componentInst) {
		this.inputWires = inputWires;
		foreach (Connection inputWire in inputWires) {
			inputWire.set_affects (this);
		}
		this.outputWire = outputWire;
		
		this.ancestry = ancestry;
		this.componentInst = componentInst;
	}
	
	public override void update () {
		bool output = false;
		
		foreach (Connection inputWire in inputWires) {
			if (inputWire.signalState == true) {
				output = true;
			}
		}
		
		outputWire.signalState = output;
	}
}
