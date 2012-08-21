/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentstate/t-flipflop.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class TFlipflopComponentState : ComponentState {
	private Connection toggleWire;
	private Connection clockWire;
	private Connection outputWire;
	private Connection outputNotWire;
	
	private bool output;
	private bool previousClockSignal;
	
	public TFlipflopComponentState (Connection toggleWire, Connection clockWire, Connection outputWire, Connection outputNotWire, ComponentInst[] ancestry, ComponentInst componentInst) {
		this.toggleWire = toggleWire;
		clockWire.set_affects (this);
		this.clockWire = clockWire;
		this.outputWire = outputWire;
		this.outputNotWire = outputNotWire;
		
		output = false;
		previousClockSignal = true;
		
		this.ancestry = ancestry;
		this.componentInst = componentInst;
	}
	
	public override void update () {
		if (clockWire.signalState && !previousClockSignal && toggleWire.signalState) {
			output = output ? false : true;
		}
		
		previousClockSignal = clockWire.signalState;
		
		outputWire.signalState = output;
		outputNotWire.signalState = !output;
	}
}
