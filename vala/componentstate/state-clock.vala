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
 *   Filename: componentstate/state-clock.vala
 *
 *   Copyright Ashley Newson 2013
 */


public class ClockComponentState : ComponentState {
    public override bool alwaysUpdate {
        get {return true;}
    }

    private bool output;
    private Connection outputWire;
    private int nextToggle;
    private int onFor;
    private int offFor;


    public ClockComponentState(Connection outputWire, int onFor, int offFor, ComponentInst[] ancestry, ComponentInst componentInst) {
        this.outputWire = outputWire;
        this.onFor = onFor;
        this.offFor = offFor;

        nextToggle = offFor;
        output = false;

        this.ancestry = ancestry;
        this.componentInst = componentInst;
    }

    public override void update() {
        if (nextToggle == 0) {
            if (output) {
                output = false;
                nextToggle = offFor;
            } else {
                output = true;
                nextToggle = onFor;
            }
        }

        nextToggle--;

        outputWire.signalState = output;
    }
}
