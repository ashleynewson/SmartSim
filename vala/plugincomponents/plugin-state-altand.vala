/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Example - Public Domain
 *   
 *   Filename: plugincomponents/plugin-state-altand.vala
 *   
 *   Copyright Ashley Newson 2013
 */


public class AndPluginComponentState : ComponentState {
	private Connection[] inputWires;
	private Connection outputWire;
	
	public AndPluginComponentState (Connection[] inputWires, Connection outputWire, ComponentInst[] ancestry, ComponentInst componentInst) {
		this.inputWires = inputWires;
		foreach (Connection inputWire in inputWires) {
			inputWire.set_affects (this);
		}
		this.outputWire = outputWire;
		
		this.ancestry = ancestry;
		this.componentInst = componentInst;
	}
	
	~AndPluginComponentState () {
		pluginManager.print_info ("Plugin AND Deconstucted.\n");
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
