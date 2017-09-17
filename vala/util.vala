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
 *   Filename: componentdef/def-custom.vala
 *
 *   Copyright Ashley Newson 2017
 */


/**
 * Set of miscellaneous utilities.
 */
namespace Util {
    public delegate bool TestFunction<T>(T item);
    /**
     * Finds items in //collection// which satisfy //test//.
     * @return matched items.
     */
    public Gee.Set<T> filter_set<T>(Gee.Set<T> collection, TestFunction<T> test) {
        Gee.Set<T> newSet = new Gee.HashSet<T>();
        foreach (T item in collection) {
            if (test(item)) {
                newSet.add(item);
            }
        }
        return newSet;
    }
    /**
     * Removes items from //collection// which satisfy //test//.
     * @return matched (removed) items.
     */
    public Gee.Set<T> filter_set_remove<T>(Gee.Set<T> collection, TestFunction<T> test) {
        Gee.Set<T> remove_set = filter_set(collection, test);
        collection.remove_all(remove_set);
        return remove_set;
    }
}
