/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentstate/reader.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class ReaderComponentState : ComponentState {
	private bool input;
	private bool zState;
	private Connection inputWire;
	
	public ReaderComponentState (Connection inputWire, ComponentInst[] ancestry, ComponentInst componentInst) {
		this.inputWire = inputWire;
		inputWire.set_affects (this);
		
		input = false;
		zState = true;
		
		this.ancestry = ancestry;
		this.componentInst = componentInst;
	}
	
	public override void render (Cairo.Context context) {
		string text;
		
		Cairo.Matrix oldmatrix;
		
		context.get_matrix (out oldmatrix);
		
		context.translate (componentInst.xPosition, componentInst.yPosition);
		
		context.set_source_rgb (1.0, 1.0, 1.0);
		
		if (zState) {
			text = "Z";
		} else if (input) {
			text = "1";
		} else {
			text = "0";
		}
		
		Cairo.TextExtents textExtents;
		
		context.set_font_size (16);
		context.text_extents (text, out textExtents);
		context.move_to (-10, +10);
		context.line_to (+10, +10);
		context.line_to (+10, -10);
		context.line_to (-10, -10);
		context.line_to (-10, +10);
		context.fill ();
		context.stroke ();
		
		if (zState) {
			context.set_source_rgb (0, 1.0, 0);
		} else if (input) {
			context.set_source_rgb (1.0, 0, 0);
		} else {
			context.set_source_rgb (0, 0, 1.0);
		}
		
		context.move_to (-textExtents.width/2, +textExtents.height/2);
		
		context.show_text (text);
		
		context.set_matrix (oldmatrix);
	}
	
	public override void update () {
		if (display) {
			if (input != inputWire.signalState ||
				zState != (inputWire.users == 0)) {
					compiledCircuit.renderComponentStates.add_element (renderQueueID);
			}
		}
		
		input = inputWire.signalState;
		zState = (inputWire.users == 0);
	}
}
