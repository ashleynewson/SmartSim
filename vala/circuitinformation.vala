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
 *   Filename: circuitinformation.vala
 *
 *   Copyright Ashley Newson 2013
 */


public class CircuitInformation {
    public struct ComponentCount {
        ComponentDef componentDef;
        int count;
    }

    private ComponentCount[] componentCounts;

    private Project project;

    public string summary {
        public get;
        private set;
    }

    public CircuitInformation(Project project) {
        summary = "";
        this.project = project;

        componentCounts = {};

        if (project.rootComponent != null) {
            CustomComponentDef[] componentChain = project.rootComponent.validate_dependencies({});

            if (componentChain != null) {
                string errorMessage = "Circuit failed cyclic dependency test. Failed ancestry:\n";
                foreach (CustomComponentDef customComponentDef in componentChain) {
                    errorMessage += "  " + customComponentDef.name + ".\n";
                }
                errorMessage += "\nFor statistics to be created, your circuit must not contain any cyclic dependencies.";

                Gtk.MessageDialog messageDialog = new Gtk.MessageDialog(
                    null,
                    Gtk.DialogFlags.MODAL,
                    Gtk.MessageType.ERROR,
                    Gtk.ButtonsType.OK,
                    "Could not create project statistics:\n%s",
                    errorMessage
                );

                messageDialog.run();
                messageDialog.destroy();

                return;
            }

            project.rootComponent.create_information(this);

            summary += "Total Component Counts:\n";

            foreach (ComponentCount componentCount in componentCounts) {
                summary += "  " + componentCount.componentDef.name + ": " + componentCount.count.to_string() + "\n";
            }
        } else {
            Gtk.MessageDialog messageDialog = new Gtk.MessageDialog(
                null,
                Gtk.DialogFlags.MODAL,
                Gtk.MessageType.ERROR,
                Gtk.ButtonsType.OK,
                "You cannot generate circuit statistics without a root component."
            );

            messageDialog.run();
            messageDialog.destroy();
        }
    }

    public void count_component(ComponentDef componentDef) {
        int i;

        for (i = 0; i < componentCounts.length; i++) {
            if (componentCounts[i].componentDef == componentDef) {
                componentCounts[i].count ++;
                break;
            }
        }

        if (i == componentCounts.length) {
            ComponentCount componentCount = ComponentCount();
            componentCount.componentDef = componentDef;
            componentCount.count = 1;
            componentCounts += componentCount;
        }
    }
}
