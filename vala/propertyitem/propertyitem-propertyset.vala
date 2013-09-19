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
 *   Filename: propertyitem/propertyitem-propertyset.vala
 *   
 *   Copyright Ashley Newson 2013
 */


/**
 * Stores a range of different data types.
 * 
 * Can be used as both a storage medium for data, and as a method of
 * obtaining a variety of data from the user using a PropertiesQuery.
 */
public class PropertySet : PropertyItem {
	public PropertyItem[] propertyItems;
	
	/**
	 * Creates a new PropertySet with a name and description.
	 */
	public PropertySet (string name, string description = "") {
		base (name, description);
		
		propertyItems = {};
	}
	
	public PropertySet.copy (PropertySet source) {
		base (source.name, source.description);
		PropertyItem[] newPropertyItems = {};
		foreach (PropertyItem propertyItem in source.propertyItems) {
			newPropertyItems += propertyItem;
		}
		this.propertyItems = newPropertyItems;
	}
	
	/**
	 * Returns the ID of the property with name //name//. Returns -1 if
	 * there is no property with that name.
	 */
	public int index_of_item (string name) {
		for (int i = 0; i < propertyItems.length; i ++) {
			if (name == propertyItems[i].name) {
				return i;
			}
		}
		
		return -1;
	}
	
	public PropertyItem? get_item (string name) {
		for (int i = 0; i < propertyItems.length; i ++) {
			if (name == propertyItems[i].name) {
				return propertyItems[i];
			}
		}
		
		return null;
	}
	
	public int add_item (PropertyItem propertyItem) {
		if (index_of_item(propertyItem.name) != -1) {
			return 1;
		}
		
		PropertyItem[] newPropertyItems = propertyItems;
		newPropertyItems += propertyItem;
		propertyItems = newPropertyItems;
		
		return 0;
	}
}
