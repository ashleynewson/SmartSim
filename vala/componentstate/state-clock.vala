/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentstate/clock.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class ClockComponentState : ComponentState {
	public override bool alwaysUpdate {
		get {return true;}
	}
	
	private bool output;
	private Connection outputWire;
	private int nextToggle;
	private int onFor;
	private int offFor;
	
	
	public ClockComponentState (Connection outputWire, int onFor, int offFor, ComponentInst[] ancestry, ComponentInst componentInst) {
		this.outputWire = outputWire;
		this.onFor = onFor;
		this.offFor = offFor;
		
		nextToggle = offFor;
		output = false;
		
		this.ancestry = ancestry;
		this.componentInst = componentInst;
	}
	
	public override void update () {
		if (nextToggle == 0) {
			if (output) {
				output = false;
				nextToggle = offFor;
			} else {
				output = true;
				nextToggle = onFor;
			}
		}
		
		nextToggle--;
		
		outputWire.signalState = output;
	}
}
