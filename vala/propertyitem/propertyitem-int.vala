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
 *   Filename: propertyitem/propertyitem-int.vala
 *   
 *   Copyright Ashley Newson 2013
 */


public class PropertyItemInt : PropertyItem {
	public int data;
	private int min;
	private int max;
	
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
	
	
	public PropertyItemInt (string name, string description = "", int data = 0, int min = int.MIN, int max = int.MAX) {
		base (name, description);
		this.data = data;
		this.min = min;
		this.max = max;
	}
	
	public PropertyItemInt.copy (PropertyItemInt source) {
		base (source.name, source.description);
		this.data = source.data;
		this.min = source.min;
		this.max = source.max;
	}
	
	public override Gtk.Widget create_widget () {
		Gtk.SpinButton intSpinButton = new Gtk.SpinButton.with_range (min, max, 1);
		intSpinButton.set_value (data);
		intSpinButton.set_snap_to_ticks (true);
		
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
