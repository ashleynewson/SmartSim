namespace UICommon {
    public errordomain LoadError {
        BAD_RESOURCE,
        MISSING_RESOURCE,
        MISSING_OBJECT
    }

    public Object get_object_critical(Gtk.Builder builder, string name) throws LoadError.MISSING_OBJECT {
        Object object = builder.get_object(name);
        if (object == null) {
            throw new LoadError.MISSING_OBJECT("Could not find an object with id=\"" + name + "\"");
        }
        return object;
    }

    public void fatal_load_error(LoadError error) {
        BasicDialog.error(null, "There was a fatal error whilst trying to load part of the SmartSim interface:\n\n" + error.message + "\n\nSmartSim will now close.");
        Process.exit(1);
    }
}
