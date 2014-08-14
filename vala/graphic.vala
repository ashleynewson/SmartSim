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
 *   Filename: graphic.vala
 *   
 *   Copyright Ashley Newson 2013
 */


public errordomain GraphicLoadError {
	FILE
}

/**
 * Used to store and render an SVG image.
 */
public class Graphic {
	/**
	 * Graphic to use if a graphic fails to load.
	 */
	public static Graphic placeHolder;
	
	/**
	 * Librsvg handles the SVG.
	 */
	private Rsvg.Handle svgHandle;
	/**
	 * the filename without any extensions.
	 */
	public string filename;
	/**
	 * The actual SVG file's filename.
	 */
	public string svgFilename;
	/**
	 * The info file's filename.
	 */
	public string infoFilename;
	private int width;
	private int height;
	/**
	 * Where the centre of the image is considered to be (x).
	 */
	private int xCentre;
	/**
	 * Where the centre of the image is considered to be (y).
	 */
	private int yCentre;
	
	
	
	/**
	 * Loads a graphic from the files //filename//.info and
	 * //filename//.svg.
	 */
	public Graphic.from_file (string filename) throws GraphicLoadError {
		stdout.printf ("Loading graphic \"%s\"\n", filename);
		this.filename = filename;
		
		if (load_info(filename + ".info") != 0) {
			throw new GraphicLoadError.FILE ("Unable to open graphic file \"" + filename + ".info\".");
		}
		if (load_svg(filename + ".svg") != 0) {
			throw new GraphicLoadError.FILE ("Unable to open svg file \"" + filename + ".svg\".");
		}
	}
	
	/**
	 * Reads an info file, which describes how to use the svg image
	 * (describing its centre, width...).
	 */
	public int load_info (string filename) { //All XML Code will need maintaining.
		stdout.printf ("Loading graphic info \"%s\"\n", filename);
		this.infoFilename = filename;
		
		Xml.Doc* xmldoc;
		Xml.Node* xmlroot;
		Xml.Node* xmlnode;
		
		xmldoc = Xml.Parser.parse_file (filename);
		
		if (xmldoc == null) {
			stdout.printf ("Error loading info xml file \"%s\".\n", filename);
			stdout.printf ("File inaccessible.\n");
			return 1;
		}
		
		xmlroot = xmldoc->get_root_element ();
		
		if (xmlroot == null) {
			stdout.printf ("Error loading info xml file \"%s\".\n", filename);
			stdout.printf ("File is empty.\n");
			return 2;
		}
		
		if (xmlroot->name != "graphic_info") {
			stdout.printf ("Error loading info xml file \"%s\".\n", filename);
			stdout.printf ("Wanted \"graphic_info\" info, but got \"%s\"\n", xmlroot->name);
			return 3;
		}
		
		for (xmlnode = xmlroot->children; xmlnode != null; xmlnode = xmlnode->next) {
			if (xmlnode->type != Xml.ElementType.ELEMENT_NODE) {
				continue;
			}
			
			switch (xmlnode->name) {
				case "centre": case "center":
					{
						for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
							if (xmlattr->name == "x") {
								xCentre = int.parse(xmlattr->children->content);
							}
							if (xmlattr->name == "y") {
								yCentre = int.parse(xmlattr->children->content);
							}
						}
					}
					break;
				case "size":
					{
						for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
							if (xmlattr->name == "width") {
								height = int.parse(xmlattr->children->content);
							}
							if (xmlattr->name == "height") {
								width = int.parse(xmlattr->children->content);
							}
						}
					}
					break;
			}
		}
		
		delete xmldoc;
		
		return 0;
	}
	
	/**
	 * Loads the SVG using librsvg.
	 */
	public int load_svg (string filename) {
		stdout.printf ("Loading svg \"%s\"\n", filename);
		this.svgFilename = filename;
		
		try {
			svgHandle = new Rsvg.Handle.from_file (filename);
		} catch {
			stdout.printf ("Error loading graphic \"%s\"\n", filename);
			return 1;
		}
		
		if (svgHandle == null) {
			stdout.printf ("Error loading graphic \"%s\"\n", filename);
			return 2;
		}
//		stdout.printf ("Handle: %s\n", (svgHandle != null) ? "true" : "false");
		
		return 0;
	}
	
	/**
	 * Renders the SVG, performing any necessary transformations.
	 */
	public void render (Cairo.Context context) {
		Cairo.Matrix oldMatrix;
		
		oldMatrix = context.get_matrix ();
		
		context.translate (-xCentre, -yCentre);
		svgHandle.render_cairo (context);
		
		context.set_matrix (oldMatrix);
	}
}
