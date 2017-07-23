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
 *   Filename: propertyitem.vala
 *
 *   Copyright Ashley Newson 2013
 */

public errordomain PropertyItemError {
    ITEM_NOT_FOUND
}



public abstract class PropertyItem {
    public string name;
    public string description;

    public PropertyItem(string name, string description = "") {
        this.name = name;
        this.description = description;
    }

    public virtual Gtk.Widget create_widget() {
        return new Gtk.Label("This property cannot be edited manually.");
    }

    public virtual void read_widget(Gtk.Widget propertyWidget) {
        // Do nothing by default
    }
}
