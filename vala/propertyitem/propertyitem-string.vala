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
 *   Filename: propertyitem/propertyitem-string.vala
 *   
 *   Copyright Ashley Newson 2013
 */


public class PropertyItemString : PropertyItem {
	public string data;
	
	
	public static string get_data_throw (PropertySet propertySet, string name) throws PropertyItemError {
		PropertyItem propertyItem = propertySet.get_item (name);
		
		if (propertyItem != null) {
			if (propertyItem is PropertyItemString) {
				return (propertyItem as PropertyItemString).data;
			}
		}
		
		throw new PropertyItemError.ITEM_NOT_FOUND ("\"" + propertySet.name + "\" does not contain a string named \"" + name + "\"");
	}
	
	public static void set_data_throw (PropertySet propertySet, string name, string data) throws PropertyItemError {
		PropertyItem propertyItem = propertySet.get_item (name);
		
		if (propertyItem != null) {
			if (propertyItem is PropertyItemString) {
				(propertyItem as PropertyItemString).data = data;
				return;
			}
		}
		
		throw new PropertyItemError.ITEM_NOT_FOUND ("\"" + propertySet.name + "\" does not contain a string named \"" + name + "\"");
	}
	
	public static string get_data (PropertySet propertySet, string name) {
		try {
			return get_data_throw (propertySet, name);
		} catch {
			return "";
		}
	}
	
	public static void set_data (PropertySet propertySet, string name, string data) {
		try {
			set_data_throw (propertySet, name, data);
		} catch {}
	}
	
	
	public PropertyItemString (string name, string description = "", string data = "") {
		base (name, description);
		this.data = data;
	}
	
	public override Gtk.Widget create_widget () {
		Gtk.Entry stringEntry = new Gtk.Entry ();
		stringEntry.text = data;
		stringEntry.editable = true;
		
		return stringEntry;
	}
	
	public override void read_widget (Gtk.Widget propertyWidget) {
		if (propertyWidget != null) {
			if (propertyWidget is Gtk.Entry) {
				data = (propertyWidget as Gtk.Entry).text;
			}
		}
	}
}
