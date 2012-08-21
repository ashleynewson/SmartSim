/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
 *   
 *   Filename: propertyitem.vala
 *   
 *   Copyright Ashley Newson 2012
 */

public errordomain PropertyItemError {
	ITEM_NOT_FOUND
}



public abstract class PropertyItem {
	public string name;
	public string description;
	
	public PropertyItem (string name, string description = "") {
		this.name = name;
		this.description = description;
	}
	
	public virtual Gtk.Widget create_widget () {
		return new Gtk.Label ("This property cannot be edited manually.");
	}
	
	public virtual void read_widget (Gtk.Widget propertyWidget) {
		//Do nothing by default
	}
}
