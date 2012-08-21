/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: propertyitem/double.vala
 *   
 *   Copyright Ashley Newson 2012
 */


public class PropertyItemDouble : PropertyItem {
	public double data;
	
	public static double get_data_throw (PropertySet propertySet, string name) throws PropertyItemError {
		PropertyItem propertyItem = propertySet.get_item (name);
		
		if (propertyItem != null) {
			if (propertyItem is PropertyItemDouble) {
				return (propertyItem as PropertyItemDouble).data;
			}
		}
		
		throw new PropertyItemError.ITEM_NOT_FOUND ("\"" + propertySet.name + "\" does not contain a double named \"" + name + "\"");
	}
	
	public static void set_data_throw (PropertySet propertySet, string name, double data) throws PropertyItemError {
		PropertyItem propertyItem = propertySet.get_item (name);
		
		if (propertyItem != null) {
			if (propertyItem is PropertyItemDouble) {
				(propertyItem as PropertyItemDouble).data = data;
				return;
			}
		}
		
		throw new PropertyItemError.ITEM_NOT_FOUND ("\"" + propertySet.name + "\" does not contain a double named \"" + name + "\"");
	}
	
	public static double get_data (PropertySet propertySet, string name) {
		try {
			return get_data_throw (propertySet, name);
		} catch {
			return 0;
		}
	}
	
	public static void set_data (PropertySet propertySet, string name, double data) {
		try {
			set_data_throw (propertySet, name, data);
		} catch {}
	}
	
	
	public PropertyItemDouble (string name, string description = "", double data = 0) {
		base (name, description);
		this.data = data;
	}
	
	public override Gtk.Widget create_widget () {
		Gtk.SpinButton doubleSpinButton = new Gtk.SpinButton.with_range (double.MIN, double.MAX, 1);
		doubleSpinButton.set_value (data);
		
		return doubleSpinButton;
	}
	
	public override void read_widget (Gtk.Widget propertyWidget) {
		if (propertyWidget != null) {
			if (propertyWidget is Gtk.SpinButton) {
				data = (propertyWidget as Gtk.SpinButton).get_value ();
			}
		}
	}
}
