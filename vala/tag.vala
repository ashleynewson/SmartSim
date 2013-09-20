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
 *   Filename: tag.vala
 *   
 *   Copyright Ashley Newson 2013
 */


/**
 * Used to define an interface with a higher-level of the hierarchy.
 */
public class Tag {
	/**
	 * Text to display inside the tag.
	 */
	public string text;
	/**
	 * x position of the tag's tip.
	 */
	public int xTag;
	/**
	 * y position of the tag's tip.
	 */
	public int yTag;
	/**
	 * x position of where the tag joins with the wire.
	 */
	public int xWire;
	/**
	 * y position of where the tag joins with the wire.
	 */
	public int yWire;
	/**
	 * The pin the tag maps to.
	 */
	public int pinid;
	/**
	 * Whether the tag is an input, output, or is bidirectional.
	 */
	public Flow flow;
	/**
	 * The direction the tag points.
	 */
	public Direction direction;
	
	public int rightBound;
	public int downBound;
	public int leftBound;
	public int upBound;
	
	/**
	 * Creates a new Tag, which joins at (//xWire//, //yWire//), and goes
	 * to (//xTag//, //yTag//).
	 */
	public Tag (int xWire, int yWire, int xTag, int yTag) {
		int xDiff = xTag - xWire;
		int yDiff = yTag - yWire;
		int xDiffAbs = (xDiff > 0) ? xDiff : -xDiff;
		int yDiffAbs = (yDiff > 0) ? yDiff : -yDiff;
		
		this.xTag = xTag;
		this.yTag = yTag;
		this.xWire = xWire;
		this.yWire = yWire;
		
		if (xDiffAbs > yDiffAbs) {
			if (xDiff > 0) {
				direction = Direction.RIGHT;
			} else {
				direction = Direction.LEFT;
			}
		} else {
			if (yDiff > 0) {
				direction = Direction.DOWN;
			} else {
				direction = Direction.UP;
			}
		}
		
		calculate_bounds ();
	}
	
	public void calculate_bounds () {
		int tagWidth;
		
		Cairo.TextExtents textExtents;
		Cairo.ImageSurface imageSurface = new Cairo.ImageSurface (Cairo.Format.ARGB32, 0, 0);
		Cairo.Context context = new Cairo.Context (imageSurface);
		
		context.set_font_size (12);
		context.text_extents (text, out textExtents);
		
		tagWidth = (int)textExtents.width + 2;
		if (tagWidth < 50) {
			tagWidth = 50;
		}
		if (flow == Flow.BIDIRECTIONAL) {
			tagWidth += 20;
		} else {
			tagWidth += 10;
		}
		
		switch (direction) {
			case Direction.RIGHT:
				rightBound = xTag + tagWidth;
				downBound = yTag + 10;
				leftBound = xWire;
				upBound = yTag - 10;
				break;
			case Direction.DOWN:
				rightBound = xTag + 10;
				downBound = yTag + tagWidth;
				leftBound = xTag - 10;
				upBound = yWire;
				break;
			case Direction.LEFT:
				rightBound = xWire;
				downBound = yTag + 10;
				leftBound = xTag - tagWidth;
				upBound = yTag - 10;
				break;
			case Direction.UP:
				rightBound = xTag + 10;
				downBound = yWire;
				leftBound = xTag - 10;
				upBound = yTag - tagWidth;
				break;
		}
	}
	
	/**
	 * Renders the tag.
	 */
	public void render (Cairo.Context context) {
		context.move_to (xWire, yWire);
		context.line_to (xTag, yTag);
		context.stroke ();
		
		Cairo.Matrix oldmatrix;
		
		context.get_matrix (out oldmatrix);
		
		context.translate (xTag, yTag);
		
		double angle = 0;
		
		switch (direction) {
			case Direction.RIGHT:
				angle = 0;
				break;
			case Direction.DOWN:
				angle = Math.PI * 0.5;
				break;
			case Direction.LEFT:
				angle = Math.PI;
				break;
			case Direction.UP:
				angle = Math.PI * 1.5;
				break;
		}
		context.rotate (angle);
		
		Cairo.TextExtents textExtents;
		context.set_font_size (12);
		context.text_extents (text, out textExtents);
		
		double tagWidth = textExtents.width + 2;
		if (tagWidth < 50) {
			tagWidth = 50;
		}
		switch (flow) {
			case Flow.IN:
				context.move_to (tagWidth + 10, -10);
				context.line_to (tagWidth + 10,  10);
				context.line_to (10,  10);
				context.line_to (0, 0);
				context.line_to (10, -10);
				// context.line_to (tagWidth + 10, -10);
				context.close_path ();
				context.stroke ();
				if (direction == Direction.LEFT) {
					context.rotate (Math.PI);
					context.move_to (-8 - tagWidth, textExtents.height / 2);
				} else {
					context.move_to (10, textExtents.height / 2);
				}
				context.show_text (text);
				break;
			case Flow.OUT:
				context.move_to (0, -10);
				context.line_to (0,  10);
				context.line_to (tagWidth,  10);
				context.line_to (tagWidth + 10, 0);
				context.line_to (tagWidth, -10);
				// context.line_to (0, -10);
				context.close_path ();
				context.stroke ();
				if (direction == Direction.LEFT) {
					context.rotate (Math.PI);
					context.move_to (-tagWidth, textExtents.height / 2);
				} else {
					context.move_to (2, textExtents.height / 2);
				}
				context.show_text (text);
				break;
			case Flow.BIDIRECTIONAL:
				context.move_to (0, 0);
				context.line_to (10,  10);
				context.line_to (tagWidth + 10,  10);
				context.line_to (tagWidth + 20, 0);
				context.line_to (tagWidth + 10, -10);
				context.line_to (10, -10);
				// context.line_to (0, 0);
				context.close_path ();
				context.stroke ();
				if (direction == Direction.LEFT) {
					context.rotate (Math.PI);
					context.move_to (-8 -tagWidth, textExtents.height / 2);
				} else {
					context.move_to (10, textExtents.height / 2);
				}
				context.show_text (text);
				break;
		}
		
		context.set_matrix (oldmatrix);
	}
}

