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
 *   Filename: plugincomponents/plugin-state-gpiopin.vala
 *   
 *   Copyright Ashley Newson 2013
 */


public class GpioPinPluginComponentState : ComponentState {
	private struct RegisteredPin {
		int number;
		weak GpioPinPluginComponentState state;
	}
	private static RegisteredPin[] usedPins;
	
	private static bool register_pin (int number, GpioPinPluginComponentState state) {
		foreach (RegisteredPin pin in usedPins) {
			if (pin.number == number) {
				pin.state.componentInst.errorMark = true;
				state.componentInst.errorMark = true;
				return false;
			}
		}
		
		RegisteredPin newPin = RegisteredPin ();
		newPin.state = state;
		newPin.number = number;
		
		usedPins += newPin;
		pluginManager.print_info ("Added GPIO Pin %i. Currently, %i are in use.", number, usedPins.length);
		
		return true;
	}
	
	public static void unregister_pins () {
		usedPins = {};
	}
	
	
	public override bool alwaysUpdate {
		get {return isInput;}
	}
	
	private Connection accessWire;
	private int gpioNumber;
	private bool isInput;
	private bool activeLow;
	private bool value;
	private string gpioDirectory;
	private bool exported;
	private FileStream valueFile;
	
	
	public GpioPinPluginComponentState (Connection accessWire, int gpioNumber, string direction, bool activeLow, ComponentInst[] ancestry, ComponentInst componentInst) throws ComponentStateError {
		if (GpioPinPluginComponentState.register_pin(gpioNumber, this) == false) {
			throw new ComponentStateError.COMPILE ("The circuit has conflicting GPIO Pin Components with the same pin number.");
		}
		
		this.accessWire = accessWire;
		this.gpioNumber = gpioNumber;
		if (direction == "in") {
			isInput = true;
		} else {
			isInput = false;
			if (direction == "high") {
				value = true;
			} else if (direction == "low") {
				value = false;
			}
			accessWire.set_affects (this);
		}
		this.activeLow = activeLow;
		
		FileStream exportFile = FileStream.open ("/sys/class/gpio/export", "w");
		if (exportFile == null) {
			throw new ComponentStateError.COMPILE ("Unable to access \"/sys/class/gpio/export\". Ensure SmartSim has permission to access GPIO.");
		}
		exportFile.printf ("%i", gpioNumber);
		exportFile = null;
		exported = true;
		
		gpioDirectory = "/sys/class/gpio/gpio" + gpioNumber.to_string() + "/";
		
		FileStream activeLowFile = FileStream.open (gpioDirectory + "active_low", "w");
		if (activeLowFile == null) {
			unexport ();
			throw new ComponentStateError.COMPILE ("Unable to access \"" + gpioDirectory + "active_low\". Ensure SmartSim has permission to access GPIO.");
		}
		activeLowFile.printf ("%s", activeLow ? "1" : "0");
		activeLowFile = null;
		
		FileStream directionFile = FileStream.open (gpioDirectory + "direction", "w");
		if (directionFile == null) {
			unexport ();
			throw new ComponentStateError.COMPILE ("Unable to access \"" + gpioDirectory + "direction\". Ensure SmartSim has permission to access GPIO.");
		}
		directionFile.printf ("%s", direction);
		directionFile = null;
		
		valueFile = FileStream.open (gpioDirectory + "value", isInput ? "r" : "w");
		if (valueFile == null) {
			unexport ();
			throw new ComponentStateError.COMPILE ("Unable to access \"" + gpioDirectory + "value\". Ensure SmartSim has permission to access GPIO.");
		}
		
		this.ancestry = ancestry;
		this.componentInst = componentInst;
	}
	
	~GpioPinPluginComponentState () {
		unexport ();
		/* Assumes that one dies, all die */
		GpioPinPluginComponentState.unregister_pins ();
		pluginManager.print_info ("Plugin GPIO Pin Deconstucted.\n");
	}
	
	private void unexport () {
		if (exported == false) {
			return;
		}
		
		FileStream unexportFile = FileStream.open ("/sys/class/gpio/unexport", "w");
		if (unexportFile == null) {
			pluginManager.print_error ("THIS IS VERY BAD: Unable to access \"/sys/class/gpio/unexport\". Ensure SmartSim has permission to access GPIO.");
		}
		unexportFile.printf ("%i", gpioNumber);
		unexportFile = null;
		exported = false;
	}
	
	private bool read_gpio () {
		bool value = (valueFile.getc() == '1') ? true : false;
		valueFile.rewind ();
		return value;
	}
	
	private void write_gpio (bool value) {
		valueFile.putc ((value == true) ? '1' : '0');
		valueFile.flush ();
	}
	
	public override void update () {
		if (isInput == true) {
			value = read_gpio ();
			
			accessWire.signalState = value;
		} else {
			value = accessWire.signalState;
			
			write_gpio (value);
		}
	}
}
