/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: propertyitem/int.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class PropertyItemInt : PropertyItem {
	public int data;
	
	public static int get_data_throw (PropertySet propertySet, string name) throws PropertyItemError {
		PropertyItem propertyItem = propertySet.get_item (name);
		
		if (propertyItem != null) {
			if (propertyItem is PropertyItemInt) {
				return (propertyItem as PropertyItemInt).data;
			}
		}
		
		throw new PropertyItemError.ITEM_NOT_FOUND ("\"" + propertySet.name + "\" does not contain an int named \"" + name + "\"");
	}
	
	public static void set_data_throw (PropertySet propertySet, string name, int data) throws PropertyItemError {
		PropertyItem propertyItem = propertySet.get_item (name);
		
		if (propertyItem != null) {
			if (propertyItem is PropertyItemInt) {
				(propertyItem as PropertyItemInt).data = data;
				return;
			}
		}
		
		throw new PropertyItemError.ITEM_NOT_FOUND ("\"" + propertySet.name + "\" does not contain an int named \"" + name + "\"");
	}
	
	public static int get_data (PropertySet propertySet, string name) {
		try {
			return get_data_throw (propertySet, name);
		} catch {
			return 0;
		}
	}
	
	public static void set_data (PropertySet propertySet, string name, int data) {
		try {
			set_data_throw (propertySet, name, data);
		} catch {}
	}
	
	
	public PropertyItemInt (string name, string description = "", int data = 0) {
		base (name, description);
		this.data = data;
	}
	
	public override Gtk.Widget create_widget () {
		Gtk.SpinButton intSpinButton = new Gtk.SpinButton.with_range (int.MIN, int.MAX, 1);
		intSpinButton.set_value (data);
		
		return intSpinButton;
	}
	
	public override void read_widget (Gtk.Widget propertyWidget) {
		if (propertyWidget != null) {
			if (propertyWidget is Gtk.SpinButton) {
				data = (propertyWidget as Gtk.SpinButton).get_value_as_int ();
			}
		}
	}
}
