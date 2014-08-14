/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *   
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *   
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *   
 *   Filename: componentstate/state-constant.vala
 *   
 *   Copyright Ashley Newson 2013
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
		
		Cairo.Matrix oldMatrix;
		
		oldMatrix = context.get_matrix ();
		
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
		
		context.set_matrix (oldMatrix);
	}
	
	public override void update () {
		outputWire.signalState = output;
//stderr.printf ("DEBUG!\n");
	}
}
