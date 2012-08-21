/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentstate/buffer.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class BufferComponentState : ComponentState {
	private Connection inputWire;
	private Connection outputWire;
	
	public BufferComponentState (Connection inputWire, Connection outputWire, ComponentInst[] ancestry, ComponentInst componentInst) {
		this.inputWire = inputWire;
		inputWire.set_affects (this);
		this.outputWire = outputWire;
		
		this.ancestry = ancestry;
		this.componentInst = componentInst;
	}
	
	public override void update () {
		bool output;
		
		output = inputWire.signalState;
		
		outputWire.signalState = output;
	}
}
