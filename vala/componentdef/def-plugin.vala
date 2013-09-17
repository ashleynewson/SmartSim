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
 *   Filename: componentdef/def-plugin.vala
 *   
 *   Copyright Ashley Newson 2013
 */


/**
 * PluginComponentDef load from file errors.
 */
public errordomain PluginComponentDefLoadError {
	NOT_PLUGIN,
	INIT_ERROR,
	LIBRARY_NOT_ACCESSIBLE,
	LIBRARY_NOT_COMPATIBLE,
	NAME_CONFLICT,
	INVALID
}

/**
 * Super class which is used by all plugin components.
 */
public abstract class PluginComponentDef : ComponentDef {
	public PluginComponentManager manager;
}
