/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentstate/and.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class AndComponentState : ComponentState {
	private Connection[] inputWires;
	private Connection outputWire;
	
	public AndComponentState (Connection[] inputWires, Connection outputWire, ComponentInst[] ancestry, ComponentInst componentInst) {
		this.inputWires = inputWires;
		foreach (Connection inputWire in inputWires) {
			inputWire.set_affects (this);
		}
		this.outputWire = outputWire;
		
		this.ancestry = ancestry;
		this.componentInst = componentInst;
	}
	
	public override void update () {
		bool output = true;
		
		foreach (Connection inputWire in inputWires) {
			if (inputWire.signalState == false) {
				output = false;
			}
		}
		
		outputWire.signalState = output;
	}
}
