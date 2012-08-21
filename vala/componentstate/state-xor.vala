/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentstate/xor.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class XorComponentState : ComponentState {
	private Connection[] inputWires;
	private Connection outputWire;
	
	public XorComponentState (Connection[] inputWires, Connection outputWire, ComponentInst[] ancestry, ComponentInst componentInst) {
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
			output = (inputWire.signalState != output);
		}
		
		outputWire.signalState = output;
	}
}
