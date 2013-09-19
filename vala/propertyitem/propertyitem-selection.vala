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
 *   Filename: propertyitem/propertyitem-selection.vala
 *   
 *   Copyright Ashley Newson 2013
 */

public errordomain PropertyItemStringError {
	OPTION_NOT_FOUND
}



public class PropertyItemSelection : PropertyItem {
	private struct Option {
		string value;
		string text;
	}
	private Option[] options;
	
	private int _selected;
	public int selected {
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
	
	public static void set_data_throw (PropertySet propertySet, string name, string value) throws PropertyItemError, PropertyItemStringError {
		PropertyItem propertyItem = propertySet.get_item (name);
		
		if (propertyItem != null) {
			if (propertyItem is PropertyItemSelection) {
				if ( (propertyItem as PropertyItemSelection).set_option(value) == 1 ) {
					throw new PropertyItemStringError.OPTION_NOT_FOUND ("\"" + propertySet.name + "\"'s selection named \"" + name + "\" does not contain option \"" + value + "\"");
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
	
	public static void set_data (PropertySet propertySet, string name, string value) {
		try {
			set_data_throw (propertySet, name, value);
		} catch {}
	}
	
	
	public PropertyItemSelection (string name, string description = "") {
		base (name, description);
		
		options = {};
		_selected = 0;
	}
	
	public PropertyItemSelection.copy (PropertyItemSelection source) {
		base (source.name, source.description);
		this.options = {};
		foreach (Option option in source.options) {
			this.options += option;
		}
		this._selected = source._selected;
	}
	
	public void add_option (string value, string? text = null) {
		// string[] newOptions = options;
		// newOptions += option;
		// options = newOptions;
		Option option = Option ();
		option.value = value;
		option.text = (text != null) ? text : value;
		options += option;
	}
	
	public string get_option () {
		if (options.length == 0) {
			return "";
		}
		
		return options[selected].value;
	}
	
	public string get_option_text () {
		if (options.length == 0) {
			return "";
		}
		
		return options[selected].text;
	}
	
	public int set_option (string value) {
		for (int i = 0; i < options.length; i++) {
			if (value == options[i].value) {
				selected = i;
				return 0;
			}
		}
		
		return 1;
	}
	
	public int set_option_text (string text) {
		for (int i = 0; i < options.length; i++) {
			if (text == options[i].text) {
				selected = i;
				return 0;
			}
		}
		
		return 1;
	}
	
	public override Gtk.Widget create_widget () {
		int numberOfOptions = options.length;
		Gtk.Box vBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 1);
		Gtk.RadioButton[] radioButtons = {};
		
		for (int i = 0; i < numberOfOptions; i++) {
			Gtk.RadioButton radioButton;
			
			if (i == 0) {
				radioButton = new Gtk.RadioButton.with_label (null, options[i].text);
			} else {
				radioButton = new Gtk.RadioButton.with_label_from_widget (radioButtons[0], options[i].text);
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
			if (propertyWidget is Gtk.Box) {
				Gtk.Box vBox = (propertyWidget as Gtk.Box);
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
