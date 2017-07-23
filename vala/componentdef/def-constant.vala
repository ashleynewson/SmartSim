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
 *   Filename: componentdef/def-constant.vala
 *
 *   Copyright Ashley Newson 2013
 */


public class ConstantComponentDef : ComponentDef {
    private const string infoFilename = Config.resourcesDir + "components/info/constant.xml";

    public ConstantComponentDef() throws ComponentDefLoadError.LOAD {
        try {
            load_from_file(infoFilename);
        } catch {
            stdout.printf("Failed to load built in component \"%s\"\n", infoFilename);
            throw new ComponentDefLoadError.LOAD("Failed to load \"" + infoFilename + "\"\n");
        }
    }

    public override void add_properties(PropertySet queryProperty, PropertySet configurationProperty) {
        string constantString;

        try {
            constantString = PropertyItemSelection.get_data_throw(configurationProperty, "Value");
        } catch {
            constantString = "0";
        }

        PropertyItemSelection selection = new PropertyItemSelection("Value", "The constant value to output");
        selection.add_option("0", "0 (False)");
        selection.add_option("1", "1 (True)");
        selection.set_option(constantString);
        queryProperty.add_item(selection);
    }

    public override void get_properties(PropertySet queryProperty, out PropertySet configurationProperty) {
        string constantString;

        try {
            constantString = PropertyItemSelection.get_data_throw(queryProperty, "Value");
        } catch {
            constantString = "0";
        }

        configurationProperty = new PropertySet(name + " configuration");

        PropertyItemSelection selection = new PropertyItemSelection("Value", "");
        selection.add_option("0", "0 (False)");
        selection.add_option("1", "1 (True)");
        selection.set_option(constantString);
        configurationProperty.add_item(selection);
    }

    public override void load_properties(Xml.Node* xmlnode, out PropertySet configurationProperty) {
        string constantString = "0";

        configurationProperty = new PropertySet(name + " configuration");

        for (Xml.Attr* xmlattr = xmlnode->properties; xmlattr != null; xmlattr = xmlattr->next) {
            switch (xmlattr->name) {
            case "value":
                constantString = xmlattr->children->content;
                break;
            }
        }

        PropertyItemSelection selection = new PropertyItemSelection("Value", "");
        selection.add_option("0", "0 (False)");
        selection.add_option("1", "1 (True)");
        switch (constantString) {
        case "0":
        case "0 (False)":
            selection.set_option("0");
        break;
        case "1":
        case "1 (True)":
            selection.set_option("1");
        break;
        }
        configurationProperty.add_item(selection);
    }

    public override void save_properties(Xml.TextWriter xmlWriter, PropertySet configurationProperty) {
        string constantString;

        try {
            constantString = PropertyItemSelection.get_data_throw(configurationProperty, "Value");
        } catch {
            constantString = "0";
        }

        xmlWriter.write_attribute("value", constantString);
    }

    public override void compile_component(CompiledCircuit compiledCircuit, ComponentInst? componentInst, Connection[] connections, ComponentInst[] ancestry) {
        Connection outputWire = new Connection.fake();

        string constantString;
        bool constantValue = false;

        foreach (Connection connection in connections) {
            if (connection.wireInst == componentInst.pinInsts[0].wireInsts[0]) {
                outputWire = connection;
            }
        }

        try {
            constantString = PropertyItemSelection.get_data_throw(componentInst.configuration, "Value");
        } catch {
            constantString = "0";
        }

        if (constantString == "1") {
            constantValue = true;
        }

        ComponentState componentState = new ConstantComponentState(outputWire, constantValue, ancestry, componentInst);

        compiledCircuit.add_component(componentState);
    }

    public override void extra_render(Cairo.Context context, Direction direction, bool flipped, ComponentInst? componentInst) {
        string constantString;
        string text;

        if (componentInst == null) {
            return;
        }

        context.set_source_rgb(0, 0, 0);

        try {
            constantString = PropertyItemSelection.get_data_throw(componentInst.configuration, "Value");
        } catch {
            constantString = "0";
        }

        if (constantString == "1") {
            text = "1";
        } else {
            text = "0";
        }

        Cairo.TextExtents textExtents;

        context.set_font_size(16);
        context.text_extents(text, out textExtents);
        context.move_to(-textExtents.width/2, +textExtents.height/2);
        context.show_text(text);
    }
}
