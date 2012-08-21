/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentstate/multiplexer.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class MultiplexerComponentState : ComponentState {
	private Connection[] selectWires;
	private Connection[] dataWires;
	private Connection outputWire;
	
	public MultiplexerComponentState (Connection[] selectWires, Connection[] dataWires, Connection outputWire, ComponentInst[] ancestry, ComponentInst componentInst) {
		this.selectWires = selectWires;
		foreach (Connection selectWire in selectWires) {
			selectWire.set_affects (this);
		}
		this.dataWires = dataWires;
		foreach (Connection dataWire in dataWires) {
			dataWire.set_affects (this);
		}
		this.outputWire = outputWire;
		
		this.ancestry = ancestry;
		this.componentInst = componentInst;
	}
	
	public override void update () {
		bool output = false;
		int selected = 0;
		
		for (int i = 0; i < selectWires.length; i++) {
			selected <<= 1;
			if (selectWires[i].signalState) {
				selected |= 1;
			}
		}
		
		if (selected < dataWires.length) {
			output = dataWires[selected].signalState;
		}
		
		outputWire.signalState = output;
	}
}
