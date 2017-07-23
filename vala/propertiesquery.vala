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
 *   Filename: propertiesquery.vala
 *
 *   Copyright Ashley Newson 2013
 */


/**
 * User interface to edit a PropertySet.
 *
 * Creates a GTK Dialog which allows the editting of a PropertySet.
 */
public class PropertiesQuery {
    /**
     * The PropertySet being editted.
     */
    PropertySet propertySet;

    private Gtk.Dialog dialog;
    private Gtk.Label titleNameLabel;
    private Gtk.Label titleDescriptionLabel;
    private Gtk.Box[] propertyVBoxes;
    private Gtk.Label[] nameLabels;
    private Gtk.Label[] descriptionLabels;

    private Gtk.Widget[] propertyWidgets;
    private Gtk.Button applyButton;
    private Gtk.Button cancelButton;

    /**
     * Creates a new PropertyQuery with the title //title//, openned by
     * //parent//, to edit //propertySet//.
     */
    public PropertiesQuery(string? title, Gtk.Window? parent, PropertySet propertySet) {
        dialog = new Gtk.Dialog.with_buttons(title ?? ("Properties - " + propertySet.name), parent, Gtk.DialogFlags.MODAL);

        Gtk.Box content = dialog.get_content_area() as Gtk.Box;

        dialog.set_default_size(200, 150);
        dialog.set_border_width(1);

        titleNameLabel = new Gtk.Label(propertySet.name);
        titleDescriptionLabel = new Gtk.Label(propertySet.description);

        content.pack_start(titleNameLabel, false, true, 4);
        content.pack_start(titleDescriptionLabel, false, true, 1);

        for (int i = 0; i < propertySet.propertyItems.length; i ++) {
            content.pack_start(new Gtk.Separator(Gtk.Orientation.HORIZONTAL), false, false, 3);

            PropertyItem propertyItem = propertySet.propertyItems[i];
            string name = propertyItem.name;
            string description = propertyItem.description;

            Gtk.Box propertyVBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 1);
            propertyVBoxes += propertyVBox;

            Gtk.Label nameLabel = new Gtk.Label(name);
            nameLabels += nameLabel;

            Gtk.Label descriptionLabel = new Gtk.Label(description);
            descriptionLabel.wrap = true;
            descriptionLabels += descriptionLabel;

            propertyVBox.pack_start(nameLabel, false, true, 4);

            if (description != "") {
                propertyVBox.pack_start(descriptionLabel, false, true, 1);
            }

            Gtk.Widget propertyWidget = propertyItem.create_widget();

            propertyWidgets += propertyWidget;

            propertyVBox.pack_start(propertyWidget, false, true, 1);

            content.pack_start(propertyVBox, false, true, 1);
        }

        dialog.response.connect(response_handler);

        cancelButton = new Gtk.Button.with_label("Cancel");
        dialog.add_action_widget(cancelButton, Gtk.ResponseType.CANCEL);

        applyButton = new Gtk.Button.with_label("Apply");
        dialog.add_action_widget(applyButton, Gtk.ResponseType.APPLY);

        this.propertySet = propertySet;

        dialog.show_all();
    }

    /**
     * Handles any action which closes the dialog (apply or cancel).
     */
    public void response_handler(int response_id) {
        switch (response_id) {
        case Gtk.ResponseType.APPLY:
            apply_changes();
            break;
        case Gtk.ResponseType.CANCEL:
            break;
        }
    }

    /**
     * Makes the dialog modal, and waits for the dialog to close.
     */
    public int run() {
        int response_id;

        response_id = dialog.run();
        dialog.destroy();

        return response_id;
    }

    /**
     * Copies the values stored in GTK widgets into the PropertySet.
     */
    public bool apply_changes() {
        for (int i = 0; i < propertySet.propertyItems.length; i ++) {
            PropertyItem propertyItem = propertySet.propertyItems[i];
            Gtk.Widget propertyWidget = propertyWidgets[i];

            propertyItem.read_widget(propertyWidget);
        }

        return false;
    }
}
