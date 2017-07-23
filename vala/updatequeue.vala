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
 *   Filename: list.vala
 *
 *   Copyright Ashley Newson 2013
 */


public class UpdateQueue<ElementType> {
    public ElementType[] elements;
    private int readUpdateTime;
    private int writeUpdateTime;
    private int[] readTimes;
    private int[] writeTimes;
    private int[] readNexts;
    private int[] writeNexts;
    private int readFirst;
    private int writeFirst;
    private int defaultFirst;

    private int currentElement;

    public UpdateQueue(ElementType[] elements, ElementType[]? permanentElements) {
        int numberOfElements = elements.length;

        this.elements = elements;

        readTimes = new int[numberOfElements];
        writeTimes = new int[numberOfElements];
        for (int i = 0; i < numberOfElements; i++) {
            readTimes[i] = -1;
            writeTimes[i] = -1;
        }

        readNexts = new int[numberOfElements];
        writeNexts = new int[numberOfElements];

        defaultFirst = -1;

        if (permanentElements != null) {
            for (int i = 0; i < numberOfElements; i++) {
                foreach (ElementType permanentElement in permanentElements) {
                    if (elements[i] == permanentElement) {
                        add_permanent_element(i);
                        break;
                    }
                }
            }
        }

        readFirst = defaultFirst;
        writeFirst = defaultFirst;

        currentElement = defaultFirst;

        readUpdateTime = 0;
        writeUpdateTime = 0;
    }

    public void swap(int newTime) {
        readUpdateTime = writeUpdateTime;
        writeUpdateTime = newTime;

        int[] temporaryArray;

        temporaryArray = readTimes;
        readTimes = writeTimes;
        writeTimes = temporaryArray;

        temporaryArray = readNexts;
        readNexts = writeNexts;
        writeNexts = temporaryArray;

        readFirst = writeFirst;
        writeFirst = defaultFirst;

        currentElement = readFirst;
    }

    public void full_update() {
        for (int i = 0; i < elements.length; i++) {
            add_element(i);
        }
    }

    public void add_element(int elementNumber) {
        if (writeTimes[elementNumber] < writeUpdateTime) {
            writeTimes[elementNumber] = writeUpdateTime;
            writeNexts[elementNumber] = writeFirst;
            writeFirst = elementNumber;
        }
    }

    public void add_permanent_element(int elementNumber) {
        writeTimes[elementNumber] = int.MAX;
        readTimes[elementNumber]  = int.MAX;
        writeNexts[elementNumber] = defaultFirst;
        readNexts[elementNumber]  = defaultFirst;
        defaultFirst = elementNumber;
    }

    public ElementType? get_next_element() {
        if (currentElement == -1) {
            return null;
        }

        ElementType element = elements[currentElement];
        currentElement = readNexts[currentElement];

        return element;
    }
}
