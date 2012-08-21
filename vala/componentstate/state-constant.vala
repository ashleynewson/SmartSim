/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentstate/constant.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class ConstantComponentState : ComponentState {
	public override bool alwaysUpdate {
		get {return true;}
	}
	
	private bool output;
	private Connection outputWire;
	
	public ConstantComponentState (Connection outputWire, bool constantValue, ComponentInst[] ancestry, ComponentInst componentInst) {
		this.outputWire = outputWire;
		
		output = constantValue;
		
		this.ancestry = ancestry;
		this.componentInst = componentInst;
	}
	
	public override void render (Cairo.Context context) {
		string text;
		
		Cairo.Matrix oldmatrix;
		
		context.get_matrix (out oldmatrix);
		
		context.translate (componentInst.xPosition, componentInst.yPosition);
		
		if (output) {
			context.set_source_rgb (1.0, 0, 0);
			text = "1";
		} else {
			context.set_source_rgb (0, 0, 1.0);
			text = "0";
		}
		
		Cairo.TextExtents textExtents;
		
		context.set_font_size (16);
		context.text_extents (text, out textExtents);
		context.move_to (-textExtents.width/2, +textExtents.height/2);
		context.show_text (text);
		
		context.set_matrix (oldmatrix);
	}
	
	public override void update () {
		outputWire.signalState = output;
//stderr.printf ("DEBUG!\n");
	}
}
