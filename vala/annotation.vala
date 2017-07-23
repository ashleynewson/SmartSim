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
 *   Filename: annotation.vala
 *
 *   Copyright Ashley Newson 2013
 */


/**
 * Annotation load from file errors.
 */
public errordomain AnnotationLoadError {
    /**
     * The text within the annotation is empty.
     */
    EMPTY
}



/**
 * Design object which displays text.
 *
 * Used to label a part of a circuit with user defined text. It has no
 * effect on the behaviour of the logic circuit. It's a comment.
 */
public class Annotation {
    public int xPosition;
    public int yPosition;
    public string _text;
    public double _fontSize;

    public string text {
        set {
            _text = value;
            calculate_size();
        }
        get {
            return _text;
        }
    }
    public double fontSize {
        set {
            _fontSize = value;
            calculate_size();
        }
        get {
            return _fontSize;
        }
    }

    public int width;
    public int height;

    public bool selected = false;

    /**
     * Construct an annotation at (//x//, //y//) with text //text// of
     * font size //fontSize//.
     */
    public Annotation(int x, int y, string text = "", double fontSize = 12) {
        xPosition = x;
        yPosition = y;

        this.text = text;
        this.fontSize = fontSize;
    }

    /**
     * Load an annotation from a file using libxml.
     * Throws AnnotationLoadError.EMPTY when the text is empty.
     */
    public Annotation.load(Xml.Node* xmlnode) throws AnnotationLoadError.EMPTY {
        xPosition = 0;
        yPosition = 0;
        text = "";
        fontSize = 12;

        for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
            switch (xmlattr->name) {
            case "x":
                xPosition = int.parse(xmlattr->children->content);
                break;
            case "y":
                yPosition = int.parse(xmlattr->children->content);
                break;
            case "text":
                text = xmlattr->children->content;
                break;
            case "fontsize":
                fontSize = double.parse(xmlattr->children->content);
                break;
            }
        }

        if (text == "") {
            throw new AnnotationLoadError.EMPTY("The annotation has no text.");
        }
    }

    /**
     * Returns 1 if the annotation is on the point (//x//, //y//).
     */
    public int find(int x, int y) {
        if (x >= xPosition && x <= xPosition + width &&
            y >= yPosition && y <= yPosition + height) {
            return 1;
        }

        return 0;
    }

    /**
     * Translates the annotation //x// right, //y// down.
     * If //ignoreSelect// is true, it will move without being selected.
     */
    public void move(int x, int y, bool ignoreSelect) {
        if (ignoreSelect || selected) {
            xPosition += x;
            yPosition += y;
        }
    }

    /**
     * Selects if the annotation is on the point (//x//, //y//), else it
     * deselects.
     * If //toggle// is true, it toggles if on (//x//, //y//) instead.
     */
    public void try_select(int x, int y, bool toggle) {
        bool affect;

        if (x >= xPosition && x <= xPosition + width &&
            y >= yPosition && y <= yPosition + height) {
            affect = true;
        } else {
            affect = false;
        }

        if (toggle) {
            if (affect) {
                selected = selected ? false : true;
            }
        } else {
            if (affect) {
                selected = true;
            } else {
                selected = false;
            }
        }
    }

    /**
     * Saves all information about the annotation to an xml document
     * using libxml.
     */
    public void save(Xml.TextWriter xmlWriter) {
        xmlWriter.start_element("annotation");

        xmlWriter.write_attribute("x", xPosition.to_string());
        xmlWriter.write_attribute("y", yPosition.to_string());
        xmlWriter.write_attribute("text", text);
        xmlWriter.write_attribute("fontsize", fontSize.to_string());

        xmlWriter.end_element();
    }

    public void calculate_size() {
        Cairo.TextExtents textExtents;
        Cairo.ImageSurface imageSurface = new Cairo.ImageSurface(Cairo.Format.ARGB32, 0, 0);
        Cairo.Context context = new Cairo.Context(imageSurface);

        context.set_font_size(fontSize);
        context.text_extents(text, out textExtents);
        width  = (int)textExtents.width + 4;
        height = (int)textExtents.height + 4;
    }

    /**
     * Renders the annotation onto the Cairo context passed.
     * If //showHints// is true, selection is shown as blue, and their
     * will be a small dot to mark the annotation's position.
     */
    public void render(Cairo.Context context, bool showHints = false) {
        Cairo.TextExtents textExtents;
        Cairo.Matrix oldMatrix;

        oldMatrix = context.get_matrix();

        context.translate(xPosition, yPosition);

        if (selected && showHints) {
            context.set_source_rgb(0, 0, 1);
        } else {
            context.set_source_rgb(0, 0, 0);
        }

        if (showHints) {
            Cairo.LineCap oldLineCap = context.get_line_cap();

            context.set_line_cap(Cairo.LineCap.ROUND);
            context.move_to(0, 0);
            context.line_to(0, 0);
            context.stroke();
            context.set_line_cap(oldLineCap);
        }

        context.set_font_size(fontSize);
        context.text_extents(text, out textExtents);
        context.translate(2, textExtents.height + 2);
        context.show_text(text);
        context.stroke();

        context.set_matrix(oldMatrix);
    }
}
