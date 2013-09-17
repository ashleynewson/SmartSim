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
 *   Filename: connection.vala
 *   
 *   Copyright Ashley Newson 2013
 */


/**
 * Used to handle a connection to a wire in a compiled circuit.
 * 
 * Connections automatically handle inversions, update
 * interfaces, user counts.
 * They can also act as a stub when there is no real wire to connect -
 * known as a fake connection.
 */
public class Connection {
	/**
	 * The WireState which the connection handles.
	 */
	public weak WireState wireState;
	/**
	 * If true, signals through the connection will be inverted.
	 */
	public bool invert;
	/**
	 * If the connection does not actually go anywhere, this is true.
	 */
	public bool isFake = false;
	
	public bool active = false;
	
	/**
	 * Returns the WireInst of WireState. Return null if there is no
	 * wireState (fake).
	 */
	public WireInst? wireInst {
		get {
			if (wireState == null) {
				return null;
			} else {
				return wireState.wireInst;
			}
		}
	}
	
	/**
	 * Get or set the current binary signal of the WireState, handling
	 * inversion and user count.
	 */
	public bool signalState {
		get {
			if (wireState == null) {
				return false;
			} else {
				return (wireState.signalState != invert); //Signal-from-wire XOR invert
			}
		}
		set {
			if (wireState != null) {
				wireState.signalState = (value != invert); //Signal-to-wire XOR invert
				if (!active) {
					wireState.users++;
					active = true;
				}
				wireState.update_interfaces (null);
			}
		}
	}
	
	/**
	 * Check the number of inputs into the WireState.
	 */
	public int users {
		get {
			if (wireState == null) {
				return 0;
			} else {
				return wireState.previousUsers;
			}
		}
	}
	
	/**
	 * Create a real connection to //wireState//.
	 */
	public Connection (WireState wireState, bool invert) {
		this.wireState = wireState;
		this.invert = invert;
	}
	
	/**
	 * Creates a fake connection which goes nowhere.
	 */
	public Connection.fake () {
		this.wireState = null;
		this.isFake = true;
	}
	
	public void disable_signal () {
		if (active) {
			wireState.users--;
			active = false;
		}
		wireState.update_interfaces (null);
	}
	
	public void set_affects (ComponentState componentState) {
		if (!isFake) {
			wireState.add_affected (componentState);
		}
	}
}
