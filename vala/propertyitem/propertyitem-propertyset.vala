/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: propertyitem/propertyset.vala
 *   
 *   Copyright Ashley Newson 2012
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
