/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentstate/pe-d-flipflop.vala
 *   
 *   Copyright Ashley Newson 2012
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
