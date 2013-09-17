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
 *   Filename: wirestate.vala
 *   
 *   Copyright Ashley Newson 2013
 */


/**
 * A compiled wire.
 * 
 * A WireState is a compiled wire component as part of a compiled
 * circuit.
 * They act as signal storage. They are required to update each other
 * between high-low level inferfaces.
 * They are constructed with the aid of a corrisponding WireInst.
 */
public class WireState {
	public enum State {
		UNKNOWN = 0,
		Z = 1,
		TRUE = 2,
		FALSE = 3
	}
	
	public struct StateHistory {
		uint duration;
		uchar state;
	}
	
	public int renderQueueID;
	public int processQueueID;
	
	/**
	 * The CompiledCircuit which contains this wire.
	 */
	public weak CompiledCircuit compiledCircuit;
	/**
	 * Describes which level of, and where in, the hierarchy the
	 * WireState is, using a chain of parent custom component instances.
	 */
	public ComponentInst[] ancestry;
	/**
	 * Whether or not the WireState is in the current viewed hierarchy.
	 * When true, enables display.
	 */
	public bool display;
	
	private bool[] _signalState;

	/**
	 * The current set of timing crucial values to be read from.
	 */
	private int readBuffer = 0;
	/**
	 * The current set of timing crucial values to write to.
	 */
	private int writeBuffer = 1;
	
	/**
	 * Highlights a wire in yellow when rendered.
	 */
	public bool errorMark;
	
	/**
	 * The WireInst which this WireState was created from.
	 */
	public WireInst wireInst;
	/**
	 * Connections to wires in the higher or lower level, which must be
	 * consistnnt with this wire's values.
	 */
	private Connection[] interfaces;
	
	/**
	 * Components to add to the process update queue after a signal
	 * update.
	 */
	private ComponentState[] affectedComponents;
	
	/**
	 * Gets or sets the wire's signal value.
	 */
	public bool signalState {
		get {
			return _signalState[readBuffer];
		}
		set {
			_signalState[writeBuffer] = value;
		}
	}
	
	/**
	 * The number of signal sources of the wire.
	 */
	public int users;
	/**
	 * The //users// from the last iteration.
	 */
	public int previousUsers;
	
	private StateHistory[] stateHistory;
	
	
	
	/**
	 * Creates a new WireState from a WireInst with the given ancestry.
	 */
	public WireState (WireInst wireInst, ComponentInst[] ancestry) {
		this.wireInst = wireInst;
		this.ancestry = ancestry;
		display = false;
		
		_signalState.resize (2);
		
		bool presetSignal;
		users = 0;
		previousUsers = 0;
		
		switch (wireInst.presetSignal) {
			case WireInst.PresetSignal.TRUE:
				presetSignal = true;
				previousUsers = 1;
				break;
			case WireInst.PresetSignal.FALSE:
				presetSignal = false;
				previousUsers = 1;
				break;
			default:
				presetSignal = false;
				break;
		}
		
		_signalState[0] = presetSignal;
		_signalState[1] = presetSignal;
		
		readBuffer = 1;
		writeBuffer = 0;
		
		errorMark = false;
	}
	
	/**
	 * Swap //readBuffer// and //writeBuffer// values.
	 */
	public void swap_buffers () {
		switch (readBuffer) {
			case 0:
				readBuffer = 1;
				writeBuffer = 0;
				break;
			case 1:
				readBuffer = 0;
				writeBuffer = 1;
				break;
		}
		
		if (_signalState[readBuffer] != _signalState[writeBuffer] ||
			users != previousUsers) {
				if (display) {
					compiledCircuit.renderWireStates.add_element (renderQueueID);
				}
				foreach (ComponentState componentState in affectedComponents) {
					compiledCircuit.processComponentStates.add_element (componentState.processQueueID);
				}
		}
		
		_signalState[writeBuffer] = _signalState[readBuffer]; //In case there are no processed sources
		
		previousUsers = users;
//		users = 0;
		
//		if (stateHistory != null) {
//			record ();
//		}
	}
	
	public void record () {
		State state;
		
		if (previousUsers != 0) {
			if (signalState) {
				state = State.TRUE;
			} else {
				state = State.FALSE;
			}
			
		} else {
			state = State.Z;
		}
		
		int lastState = stateHistory.length - 1;
//		stdout.printf ("DEBUG %i, %i\n", state, stateHistory[stateHistory.length].state);
		if (state == stateHistory[lastState].state) {
			stateHistory[lastState].duration ++;
		} else {
			StateHistory newState = StateHistory ();
			newState.state = state;
			newState.duration = 1;
			stateHistory += newState;
		}
	}
	
	/**
	 * Updates all wires connected via high/low level interfaces,
	 * except for //updater//, which told this wire to do so.
	 */
	public void update_interfaces (WireState? updater) {
		foreach (Connection connection in interfaces) {
			if (connection.wireState != updater) {
				connection.wireState._signalState[writeBuffer] = (_signalState[writeBuffer] != connection.invert); //Read from the WRITE buffer.
				connection.wireState.users = users;
				connection.wireState.update_interfaces (this);
			}
		}
		compiledCircuit.processWireStates.add_element (processQueueID);
	}
	
	/**
	 * Adds an wire to the list of interfaces.
	 */
	public void add_interface (Connection connection) {
		if (!connection.isFake) {
			interfaces += connection;
		}
	}
	
	public void add_affected (ComponentState componentState) {
		affectedComponents += componentState;
	}
	
	public void start_recording (int unknownTime) {
		stateHistory = {};
		
		StateHistory unknownState = StateHistory ();
		unknownState.duration = (uint)unknownTime;
		unknownState.state = State.UNKNOWN;
		
		StateHistory initialState = StateHistory ();
		if (previousUsers != 0) {
			if (signalState) {
				initialState.state = State.TRUE;
			} else {
				initialState.state = State.FALSE;
			}
			
		} else {
			initialState.state = State.Z;
		}
		
		initialState.duration = 1;
		
		stateHistory += unknownState;
		stateHistory += initialState;
		
		compiledCircuit.add_watch (this);
	}
	
	public void stop_recording () {
		stateHistory = null;
		
		compiledCircuit.remove_watch (this);
	}
	
	/**
	 * Renders the WireState.
	 */
	public void render (Cairo.Context context) {
		if (errorMark == true) {
			wireInst.render_colour (context, 1f, 1f, 0f);
		} else if (previousUsers == 0) {
			wireInst.render_colour (context, 0f, 1f, 0f);
		} else {
			if (signalState == true) {
				wireInst.render_colour (context, 1f, 0f, 0f);
			} else {
				wireInst.render_colour (context, 0f, 0f, 1f);
			}
		}
	}
	
	public void render_history (Cairo.Context context, int xStart, int xEnd, float height, float stretch) {
		int x = 0;
		float y = 0;
		
		//Note that these are altered:
//		xStart = (int)((float)xStart * stretch);
//		xEnd = (int)((float)xEnd * stretch);
		
		context.set_source_rgb (0, 0, 0);
		
		for (int i = 0; i < stateHistory.length; i++) {
//			float xNew = x + ((float)stateHistory[i].duration * stretch);
			int xNew = x + (int)stateHistory[i].duration;
			
			switch (stateHistory[i].state) {
				case State.FALSE:
					y = height;
					break;
				case State.TRUE:
					y = -height;
					break;
				case State.Z:
					y = 0;
					break;
			}
			if (stateHistory[i].state == State.UNKNOWN) {
				x = xNew;
				continue;
			}
			
			if (xNew > xStart) {
				if (x <= xStart && xStart < xNew) {
					context.move_to ((float)xStart * stretch, y);
				} else {
					context.line_to ((float)x * stretch, y);
				}
			} else {
				x = xNew;
				continue;
			}
			
			if (x > xNew) {
				context.line_to ((float)xEnd * stretch, y);
				x = xNew;
				break;
			} else {
				context.line_to ((float)xNew * stretch, y);
			}
			
			x = xNew;
		}
		
		context.stroke ();
	}
}
