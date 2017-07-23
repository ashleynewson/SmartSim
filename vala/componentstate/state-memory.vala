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
 *   Filename: componentstate/state-memory.vala
 *
 *   Copyright Ashley Newson 2013
 */


public class MemoryComponentState : ComponentState {
    private Connection[] addressWires;
    private Connection[] dataWires;
    private Connection selectWire;
    private Connection readEnableWire;
    private Connection writeEnableWire;
    private Connection clockWire;

    private enum MemoryType {
        RAM_CS_RE_WE,
        ROM_CS
    }

    private MemoryType memoryType;

    private uint width;
    private uint64 memorySize;
    private uint64 memorySizeBytes;
    private uint64 addresses;
    private char* memory;

    private bool previousClockSignal;

    private string readFilename;
    private string writeFilename;

    public MemoryComponentState(Connection[] addressWires, Connection[] dataWires, Connection selectWire, Connection readEnableWire, Connection writeEnableWire, Connection clockWire, bool readWrite, string readFilename, string writeFilename, ComponentInst[] ancestry, ComponentInst componentInst) throws ComponentStateError {
        this.addressWires = addressWires;
        foreach (Connection addressWire in addressWires) {
            addressWire.set_affects(this);
        }
        this.dataWires = dataWires;
        foreach (Connection dataWire in dataWires) {
            dataWire.set_affects(this);
        }
        this.selectWire = selectWire;
        selectWire.set_affects(this);
        this.readEnableWire = readEnableWire;
        readEnableWire.set_affects(this);
        this.writeEnableWire = writeEnableWire;
        writeEnableWire.set_affects(this);
        this.clockWire = clockWire;
        clockWire.set_affects(this);
        this.readFilename = readFilename;
        this.writeFilename = writeFilename;

        if (readWrite) {
            memoryType = MemoryType.RAM_CS_RE_WE;
        } else {
            memoryType = MemoryType.ROM_CS;
        }

        if (addressWires.length >= 64) {
            throw new ComponentStateError.COMPILE("Memory chips with 64 or more address wires are not supported.");
        }

        if (addressWires.length >= sizeof(uint) * 8) {
            throw new ComponentStateError.COMPILE("Memory chips with " + ((ulong)sizeof(uint) * 8).to_string() + " or more address wires are not supported on this host system.");
        }

        if ((float)addressWires.length + (float)(Math.logf((float)dataWires.length)/Math.logf(8.0f)) >= 61.0) {
            throw new ComponentStateError.COMPILE("Memory chips which store 2^64 or more bits are not supported.");
        }

        addresses = ((uint64)1 << addressWires.length);
        width = dataWires.length;
        memorySize = addresses * (uint64)width;
        memorySizeBytes = (memorySize + (uint64)7) / (uint64)8;

        int allocationResult = allocate_memory();

        switch (allocationResult) {
        case 1:
            throw new ComponentStateError.COMPILE("The host system does not have enough free memory to emulate this memory chip of size " + memorySizeBytes.to_string() + " bytes.");
        case 2:
            throw new ComponentStateError.COMPILE("The host system does not support memory chips of size greater than " + size_t.MAX.to_string() + " bytes. Required " + memorySizeBytes.to_string() + " bytes.");
        }

        read_file();

        this.ancestry = ancestry;
        this.componentInst = componentInst;
    }

    /**
     * Required to free up the allocated memory.
     */
    ~MemoryComponentState() {
        write_file();

        free(memory);
    }

    private void read_file() {
        if (readFilename == "") {
            return;
        }

        FileStream readFile = FileStream.open(readFilename, "r");

        if (readFile == null) {
            stderr.printf("Could not load initial memory from file \"%s\".\n", readFilename);
            return;
        }

        for (int i = 0; i < memorySizeBytes; i++) {
            int byte = readFile.getc();
            if (byte != -1) {
                memory[i] = (char)byte;
            } else {
                break;
            }
        }
    }

    private void write_file() {
        if (writeFilename == "") {
            return;
        }

        FileStream writeFile = FileStream.open(writeFilename, "w");

        if (writeFile == null) {
            stderr.printf("Could not save final memory to file \"%s\".\n", writeFilename);
            return;
        }

        for (int i = 0; i < memorySizeBytes; i++) {
            writeFile.putc(memory[i]);
        }
    }

    /**
     * Allocates memory. Returns non 0 on failure.
     */
    private int allocate_memory() {
        if (memorySizeBytes > (uint64)size_t.MAX) {
            stderr.printf("The memory block cannot be allocated (%s in %s).\n", memorySizeBytes.to_string(), size_t.MAX.to_string());
            return 2;
        }

        memory = try_malloc0((size_t)(memorySizeBytes));

        if (memory == null) {
            stderr.printf("There is not enough free host memory to create this memory block (%s).\n", memorySizeBytes.to_string());
            return 1;
        } else {
            return 0;
        }
    }

    /**
     * Returns the bit value of the specified bit of the word at the
     * given address.
     */
    private bool get_memory(uint address, uint bit) {
        uint memoryLocation = address * width + (width - bit - 1);
        uint byteNumber = memoryLocation / 8;
        uint bitNumber = 7 - memoryLocation % 8;

        char byte = memory[byteNumber];

        if ( ((byte >> bitNumber) & 1) == 1) { // If the bitNumberth bit is 1
            return true;
        } else {
            return false;
        }
    }

    /**
     * Sets the bit value of the specified bit of the word at the given
     * address to //bitValue//.
     */
    private void set_memory(uint address, uint bit, bool bitValue) {
        uint memoryLocation = address * width + (width - bit - 1);
        uint byteNumber = memoryLocation / 8;
        uint bitNumber = 7 - memoryLocation % 8;

        if (bitValue) {
            memory[byteNumber] |=  (char)(1 << bitNumber); // Make bitNumberth bit 1
        } else {
            memory[byteNumber] &= ~(char)(1 << bitNumber); // Make bitNumberth bit 0 (~ means bitwise not)
        }
    }

    public override void update() {
        uint address = 0;

        if (memory == null) {
            return;
        }

        if (selectWire.signalState) {
            for (int i = 0; i < addressWires.length; i++) {
                if (addressWires[i].signalState) {
                    address += (1 << i);
                }
            }

            if (writeEnableWire.signalState) {
                // Write memory
                if (clockWire.signalState && !previousClockSignal) {
                    for (uint i = 0; i < width; i++) {
                        set_memory(address, i, dataWires[i].signalState);
                    }
                }
            }
            if (readEnableWire.signalState || memoryType == MemoryType.ROM_CS) {
                // Read memory
                for (uint i = 0; i < width; i++) {
                    dataWires[i].signalState = get_memory(address, i);
                }
            }
        }
        if (!selectWire.signalState ||
            (!readEnableWire.signalState && memoryType == MemoryType.RAM_CS_RE_WE)) {
            for (uint i = 0; i < width; i++) {
                dataWires[i].disable_signal();
            }
        }

        previousClockSignal = clockWire.signalState;
    }
}
