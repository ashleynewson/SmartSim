/* 
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *   
 *   Expansion Version
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
}
