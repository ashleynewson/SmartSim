/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentstate/tristate.vala
 *   
 *   Copyright Ashley Newson 2012
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
