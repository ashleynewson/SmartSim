/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: componentstate/basic-ss-display.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class BasicSsDisplayComponentState : ComponentState {
	private bool aLight;
	private bool bLight;
	private bool cLight;
	private bool dLight;
	private bool eLight;
	private bool fLight;
	private bool gLight;
	private bool pointLight;
	private int8 input;
	
	private Connection input1Wire;
	private Connection input2Wire;
	private Connection input4Wire;
	private Connection input8Wire;
	private Connection inputPWire;
	
	private bool displayPoint;
	
	public BasicSsDisplayComponentState (Connection input1Wire, Connection input2Wire, Connection input4Wire, Connection input8Wire, Connection inputPWire, bool displayPoint, ComponentInst[] ancestry, ComponentInst componentInst) {
		this.input1Wire = input1Wire;
		input1Wire.set_affects (this);
		this.input2Wire = input2Wire;
		input2Wire.set_affects (this);
		this.input4Wire = input4Wire;
		input4Wire.set_affects (this);
		this.input8Wire = input8Wire;
		input8Wire.set_affects (this);
		this.inputPWire = inputPWire;
		inputPWire.set_affects (this);
		this.displayPoint = displayPoint;
		
		input = -1;
		
		this.ancestry = ancestry;
		this.componentInst = componentInst;
	}
	
	public override void render (Cairo.Context context) {
		Cairo.Matrix oldmatrix;
		
		context.get_matrix (out oldmatrix);
		
		double oldLineWidth = context.get_line_width ();
		
		context.translate (componentInst.xPosition, componentInst.yPosition);
		
		double angle;
		
		switch (componentInst.direction) {
			case Direction.DOWN:
				angle = Math.PI * 0.5;
				break;
			case Direction.UP:
				angle = Math.PI * 1.5;
				break;
			default:
				angle = 0;
				break;
		}
		context.rotate (angle);
		
		context.set_line_width (1);
		context.set_source_rgb (1.0, 1.0, 1.0);
		
		context.rectangle (componentInst.leftBound, componentInst.upBound + 1, componentInst.rightBound - componentInst.leftBound, componentInst.downBound - componentInst.upBound - 2);
		context.fill ();
		context.stroke ();
		
		if (input == -1) {
			context.set_line_width (oldLineWidth);
			context.set_matrix (oldmatrix);
			return;
		}
		
		context.set_line_width (5);
		
		if (aLight) {
			context.set_source_rgb (0.5, 0.0, 0.0);
		} else {
			context.set_source_rgb (0.9, 0.9, 0.9);
		}
		context.move_to (-12, -30);
		context.line_to ( 12, -30);
		context.stroke ();
		
		if (bLight) {
			context.set_source_rgb (0.5, 0.0, 0.0);
		} else {
			context.set_source_rgb (0.9, 0.9, 0.9);
		}
		context.move_to ( 15, -27);
		context.line_to ( 15,  -3);
		context.stroke ();
		
		if (cLight) {
			context.set_source_rgb (0.5, 0.0, 0.0);
		} else {
			context.set_source_rgb (0.9, 0.9, 0.9);
		}
		context.move_to ( 15,   3);
		context.line_to ( 15,  27);
		context.stroke ();
		
		if (dLight) {
			context.set_source_rgb (0.5, 0.0, 0.0);
		} else {
			context.set_source_rgb (0.9, 0.9, 0.9);
		}
		context.move_to ( 12,  30);
		context.line_to (-12,  30);
		context.stroke ();
		
		if (eLight) {
			context.set_source_rgb (0.5, 0.0, 0.0);
		} else {
			context.set_source_rgb (0.9, 0.9, 0.9);
		}
		context.move_to (-15,  27);
		context.line_to (-15,   3);
		context.stroke ();
		
		if (fLight) {
			context.set_source_rgb (0.5, 0.0, 0.0);
		} else {
			context.set_source_rgb (0.9, 0.9, 0.9);
		}
		context.move_to (-15,  -3);
		context.line_to (-15, -27);
		context.stroke ();
		
		if (gLight) {
			context.set_source_rgb (0.5, 0.0, 0.0);
		} else {
			context.set_source_rgb (0.9, 0.9, 0.9);
		}
		context.move_to ( 12,   0);
		context.line_to (-12,   0);
		context.stroke ();
		
		if (displayPoint) {
			if (pointLight) {
				context.set_source_rgb (0.5, 0.0, 0.0);
			} else {
				context.set_source_rgb (0.9, 0.9, 0.9);
			}
			Cairo.LineCap oldLineCap = context.get_line_cap ();
			context.set_line_cap (Cairo.LineCap.ROUND);
			context.set_line_width (8);
			context.move_to (22.5, 27.5);
			context.line_to (22.5, 27.5);
			context.stroke ();
			context.set_line_cap (oldLineCap);
		}
		
		context.set_line_width (oldLineWidth);
		
		context.set_matrix (oldmatrix);
	}
	
	public override void update () {
		int8 newInput;
		newInput  = input1Wire.signalState ? 1 : 0;
		newInput += input2Wire.signalState ? 2 : 0;
		newInput += input4Wire.signalState ? 4 : 0;
		newInput += input8Wire.signalState ? 8 : 0;
		
		if (display) {
			if (input != newInput) {
				compiledCircuit.renderComponentStates.add_element (renderQueueID);
			}
		}
		
		input = newInput;
		
		switch (input) {
			case 0:
				aLight = true;
				bLight = true;
				cLight = true;
				dLight = true;
				eLight = true;
				fLight = true;
				gLight = false;
				break;
			case 1:
				aLight = false;
				bLight = true;
				cLight = true;
				dLight = false;
				eLight = false;
				fLight = false;
				gLight = false;
				break;
			case 2:
				aLight = true;
				bLight = true;
				cLight = false;
				dLight = true;
				eLight = true;
				fLight = false;
				gLight = true;
				break;
			case 3:
				aLight = true;
				bLight = true;
				cLight = true;
				dLight = true;
				eLight = false;
				fLight = false;
				gLight = true;
				break;
			case 4:
				aLight = false;
				bLight = true;
				cLight = true;
				dLight = false;
				eLight = false;
				fLight = true;
				gLight = true;
				break;
			case 5:
				aLight = true;
				bLight = false;
				cLight = true;
				dLight = true;
				eLight = false;
				fLight = true;
				gLight = true;
				break;
			case 6:
				aLight = true;
				bLight = false;
				cLight = true;
				dLight = true;
				eLight = true;
				fLight = true;
				gLight = true;
				break;
			case 7:
				aLight = true;
				bLight = true;
				cLight = true;
				dLight = false;
				eLight = false;
				fLight = false;
				gLight = false;
				break;
			case 8:
				aLight = true;
				bLight = true;
				cLight = true;
				dLight = true;
				eLight = true;
				fLight = true;
				gLight = true;
				break;
			case 9:
				aLight = true;
				bLight = true;
				cLight = true;
				dLight = true;
				eLight = false;
				fLight = true;
				gLight = true;
				break;
			case 10: //A
				aLight = true;
				bLight = true;
				cLight = true;
				dLight = false;
				eLight = true;
				fLight = true;
				gLight = true;
				break;
			case 11: //b
				aLight = false;
				bLight = false;
				cLight = true;
				dLight = true;
				eLight = true;
				fLight = true;
				gLight = true;
				break;
			case 12: //C
				aLight = true;
				bLight = false;
				cLight = false;
				dLight = true;
				eLight = true;
				fLight = true;
				gLight = false;
				break;
			case 13: //d
				aLight = false;
				bLight = true;
				cLight = true;
				dLight = true;
				eLight = true;
				fLight = false;
				gLight = true;
				break;
			case 14: //E
				aLight = true;
				bLight = false;
				cLight = false;
				dLight = true;
				eLight = true;
				fLight = true;
				gLight = true;
				break;
			case 15: //F
				aLight = true;
				bLight = false;
				cLight = false;
				dLight = false;
				eLight = true;
				fLight = true;
				gLight = true;
				break;
		}
		
		pointLight = inputPWire.signalState;
	}
}
