/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: propertyitem/selection.vala
 *   
 *   Copyright Ashley Newson 2012
 */

public errordomain PropertyItemStringError {
	OPTION_NOT_FOUND
}



public class PropertyItemSelection : PropertyItem {
	public string[] options;
	
	int _selected;
	int selected {
		public set {
			if (value >= 0 && value < options.length) {
				_selected = value;
			}
		}
		public get {
			return _selected;
		}
	}
	
	public static string get_data_throw (PropertySet propertySet, string name) throws PropertyItemError {
		PropertyItem propertyItem = propertySet.get_item (name);
		
		if (propertyItem != null) {
			if (propertyItem is PropertyItemSelection) {
				return (propertyItem as PropertyItemSelection).get_option ();
			}
		}
		
		throw new PropertyItemError.ITEM_NOT_FOUND ("\"" + propertySet.name + "\" does not contain a selection named \"" + name + "\"");
	}
	
	public static void set_data_throw (PropertySet propertySet, string name, string option) throws PropertyItemError, PropertyItemStringError {
		PropertyItem propertyItem = propertySet.get_item (name);
		
		if (propertyItem != null) {
			if (propertyItem is PropertyItemSelection) {
				if ( (propertyItem as PropertyItemSelection).set_option(option) == 1 ) {
					throw new PropertyItemStringError.OPTION_NOT_FOUND ("\"" + propertySet.name + "\"'s selection named \"" + name + "\" does not contain option \"" + option + "\"");
				}
				return;
			}
		}
		
		throw new PropertyItemError.ITEM_NOT_FOUND ("\"" + propertySet.name + "\" does not contain a selection named \"" + name + "\"");
	}
	
	public static string get_data (PropertySet propertySet, string name) {
		try {
			return get_data_throw (propertySet, name);
		} catch {
			return "";
		}
	}
	
	public static void set_data (PropertySet propertySet, string name, string option) {
		try {
			set_data_throw (propertySet, name, option);
		} catch {}
	}
	
	
	public PropertyItemSelection (string name, string description = "") {
		base (name, description);
		
		options = {};
		_selected = 0;
	}
	
	public void add_option (string option) {
		string[] newOptions = options;
		newOptions += option;
		options = newOptions;
	}
	
	public string get_option () {
		if (options.length == 0) {
			return "";
		}
		
		return options[selected];
	}
	
	public int set_option (string option) {
		for (int i = 0; i < options.length; i++) {
			if (option == options[i]) {
				selected = i;
				return 0;
			}
		}
		
		return 1;
	}
	
	public override Gtk.Widget create_widget () {
		int numberOfOptions = options.length;
		Gtk.VBox vBox = new Gtk.VBox (false, 1);
		Gtk.RadioButton[] radioButtons = {};
		
		for (int i = 0; i < numberOfOptions; i++) {
			Gtk.RadioButton radioButton;
			
			if (i == 0) {
				radioButton = new Gtk.RadioButton.with_label (null, options[i]);
			} else {
				radioButton = new Gtk.RadioButton.with_label_from_widget (radioButtons[0], options[i]);
			}
			
			radioButtons += radioButton;
			
			vBox.pack_start (radioButton, false, true, 1);
		}
		
		if (numberOfOptions > 0) {
			radioButtons[selected].active = true;
		}
		
		return vBox;
	}
	
	public override void read_widget (Gtk.Widget propertyWidget) {
		if (propertyWidget != null) {
			if (propertyWidget is Gtk.VBox) {
				Gtk.VBox vBox = (propertyWidget as Gtk.VBox);
				List<weak Gtk.Widget> radioButtons = vBox.get_children ();
				
				if (radioButtons.length() == options.length) {
					for (int i = 0; i < options.length; i++) {
						Gtk.Widget widget = radioButtons.nth_data(i);
						if (widget is Gtk.RadioButton) {
							if ((widget as Gtk.RadioButton).active == true) {
								selected = i;
								return;
							}
						}
					}
				}
			}
		}
	}
}
