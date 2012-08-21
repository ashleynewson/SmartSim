public class ImageExporter {
	public enum ImageFormat {
		PNG_RGB,
		PNG_ARGB,
		PDF,
		SVG,
		SVG_CLEAR
	}
	
	public delegate void Renderer (string filename, ImageFormat imageFormat, double resolution);
	
	public static void export_png (Renderer renderer) {
		string filename = "";
		ImageFormat imageFormat = ImageFormat.PNG_RGB;;
		double resolution;
		
		PropertySet propertySet = new PropertySet ("PNG Export", "PNG image export options.");
		PropertyItemSelection formatProperty = new PropertyItemSelection ("Format", "PNG colour format to use.");
			formatProperty.add_option ("RGB (White Background)");
			formatProperty.add_option ("ARGB (Transparent Background)");
			formatProperty.set_option ("RGB (White Background)");
		propertySet.add_item (formatProperty);
		PropertyItemDouble resolutionProperty = new PropertyItemDouble ("Resolution", "Pixel density multiplier.", 1);
		propertySet.add_item (resolutionProperty);
		
		PropertiesQuery propertiesQuery = new PropertiesQuery ("Export PNG Options", null, propertySet);
		
		if (propertiesQuery.run() == Gtk.ResponseType.APPLY) {
			Gtk.FileFilter pngFileFilter = new Gtk.FileFilter();
			pngFileFilter.set_name("Portable Network Graphic (.png)");
			pngFileFilter.add_pattern("*.png");
			
			Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog (
				"Export to PNG",
				null,
				Gtk.FileChooserAction.SAVE,
				Gtk.Stock.CANCEL,
				Gtk.ResponseType.CANCEL,
				Gtk.Stock.SAVE,
				Gtk.ResponseType.ACCEPT);
			
			fileChooser.add_filter (pngFileFilter);
			fileChooser.do_overwrite_confirmation = true;
			
			bool stillChoosing = true;
			while (stillChoosing) {
				if (fileChooser.run () == Gtk.ResponseType.ACCEPT) {
					filename = fileChooser.get_filename ();
					if ("." in filename) {
						stdout.printf ("File extension already given\n");
					} else {
						if (fileChooser.filter == pngFileFilter) {
							filename += ".png";
						}
					}
					if (GLib.FileUtils.test(filename, GLib.FileTest.EXISTS)) {
						if (BasicDialog.ask_overwrite(fileChooser, filename) == Gtk.ResponseType.YES) {
							stillChoosing = false;
						}
					} else {
						stillChoosing = false;
					}
				} else {
					fileChooser.destroy ();
					return;
				}
			}
			fileChooser.destroy ();
		}
		
		if (filename != "") {
			switch (PropertyItemSelection.get_data(propertySet, "Format")) {
				case "RGB (White Background)":
					imageFormat = ImageFormat.PNG_RGB;
					break;
				case "ARGB (Transparent Background)":
					imageFormat = ImageFormat.PNG_ARGB;
					break;
			}
			
			resolution = PropertyItemDouble.get_data (propertySet, "Resolution");
			
			renderer (filename, imageFormat, resolution);
		}
		
	}
	
	public static void export_pdf (Renderer renderer) {
		string filename = "";
		
		Gtk.FileFilter pdfFileFilter = new Gtk.FileFilter();
		pdfFileFilter.set_name("Portable Document Format (.pdf)");
		pdfFileFilter.add_pattern("*.pdf");
		
		Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog (
			"Export to PDF",
			null,
			Gtk.FileChooserAction.SAVE,
			Gtk.Stock.CANCEL,
			Gtk.ResponseType.CANCEL,
			Gtk.Stock.SAVE,
			Gtk.ResponseType.ACCEPT);
		
		fileChooser.add_filter (pdfFileFilter);
		fileChooser.do_overwrite_confirmation = true;
		
		bool stillChoosing = true;
		while (stillChoosing) {
			if (fileChooser.run () == Gtk.ResponseType.ACCEPT) {
				filename = fileChooser.get_filename ();
				if ("." in filename) {
					stdout.printf ("File extension already given\n");
				} else {
					if (fileChooser.filter == pdfFileFilter) {
						filename += ".pdf";
					}
				}
				if (GLib.FileUtils.test(filename, GLib.FileTest.EXISTS)) {
					if (BasicDialog.ask_overwrite(fileChooser, filename) == Gtk.ResponseType.YES) {
						stillChoosing = false;
					}
				} else {
					stillChoosing = false;
				}
			} else {
				fileChooser.destroy ();
				return;
			}
		}
		fileChooser.destroy ();
		
		if (filename != "") {
			renderer (filename, ImageFormat.PDF, 1);
		}
	}
	
	public static void export_svg (Renderer renderer) {
		string filename = "";
		ImageFormat imageFormat = ImageFormat.SVG;
		
		PropertySet propertySet = new PropertySet ("SVG Export", "SVG image export options.");
		PropertyItemSelection formatProperty = new PropertyItemSelection ("Background", "The background for the SVG to use.");
			formatProperty.add_option ("White Background");
			formatProperty.add_option ("Transparent Background");
			formatProperty.set_option ("White Background");
		propertySet.add_item (formatProperty);
		
		PropertiesQuery propertiesQuery = new PropertiesQuery ("Export SVG Options", null, propertySet);
		
		if (propertiesQuery.run() == Gtk.ResponseType.APPLY) {
			Gtk.FileFilter svgFileFilter = new Gtk.FileFilter();
			svgFileFilter.set_name("Scalable Vector Graphic (.svg)");
			svgFileFilter.add_pattern("*.svg");
			
			Gtk.FileChooserDialog fileChooser = new Gtk.FileChooserDialog (
				"Export to SVG",
				null,
				Gtk.FileChooserAction.SAVE,
				Gtk.Stock.CANCEL,
				Gtk.ResponseType.CANCEL,
				Gtk.Stock.SAVE,
				Gtk.ResponseType.ACCEPT);
			
			fileChooser.add_filter (svgFileFilter);
			fileChooser.do_overwrite_confirmation = true;
			
			bool stillChoosing = true;
			while (stillChoosing) {
				if (fileChooser.run () == Gtk.ResponseType.ACCEPT) {
					filename = fileChooser.get_filename ();
					if ("." in filename) {
						stdout.printf ("File extension already given\n");
					} else {
						if (fileChooser.filter == svgFileFilter) {
							filename += ".svg";
						}
					}
					if (GLib.FileUtils.test(filename, GLib.FileTest.EXISTS)) {
						if (BasicDialog.ask_overwrite(fileChooser, filename) == Gtk.ResponseType.YES) {
							stillChoosing = false;
						}
					} else {
						stillChoosing = false;
					}
				} else {
					fileChooser.destroy ();
					return;
				}
			}
			fileChooser.destroy ();
		}
		
		if (filename != "") {
			switch (PropertyItemSelection.get_data(propertySet, "Background")) {
				case "White Background":
					imageFormat = ImageFormat.SVG;
					break;
				case "Transparent Background":
					imageFormat = ImageFormat.SVG_CLEAR;
					break;
			}
			
			renderer (filename, imageFormat, 1);
		}
	}
}
