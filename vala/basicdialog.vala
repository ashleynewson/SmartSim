namespace BasicDialog {
    public int ask_overwrite(Gtk.Window? window, string filename) {
        Gtk.MessageDialog messageDialog = new Gtk.MessageDialog(
            window,
            Gtk.DialogFlags.MODAL,
            Gtk.MessageType.WARNING,
            Gtk.ButtonsType.YES_NO,
            "The file \"%s\" already exists.\nDo you want to overwrite it?",
            filename
        );

        int result = messageDialog.run();

        messageDialog.destroy();

        return result;
    }

    public int ask_proceed(Gtk.Window? window, string text, string buttonOK, string buttonCancel) {
        Gtk.MessageDialog messageDialog = new Gtk.MessageDialog(
            window,
            Gtk.DialogFlags.MODAL,
            Gtk.MessageType.WARNING,
            Gtk.ButtonsType.NONE,
            "%s",
            text
        );
        messageDialog.add_button(buttonOK, Gtk.ResponseType.OK);
        messageDialog.add_button(buttonCancel, Gtk.ResponseType.CANCEL);

        int result = messageDialog.run();

        messageDialog.destroy();

        return result;
    }

    public int ask_generic(Gtk.Window? window, Gtk.MessageType messageType, string text, string[] options) {
        Gtk.MessageDialog messageDialog = new Gtk.MessageDialog(
            window,
            Gtk.DialogFlags.MODAL,
            messageType,
            Gtk.ButtonsType.NONE,
            "%s",
            text
        );

        for (int i = 0; i < options.length; i++) {
            string option = options[i];
            messageDialog.add_button(option, i);
        }

        int result = messageDialog.run();

        messageDialog.destroy();

        return result;
    }

    public void information(Gtk.Window? window, string text) {
        Gtk.MessageDialog messageDialog = new Gtk.MessageDialog(
            window,
            Gtk.DialogFlags.MODAL,
            Gtk.MessageType.INFO,
            Gtk.ButtonsType.CLOSE,
            "%s",
            text
        );

        messageDialog.run();
        messageDialog.destroy();
    }

    public void warning(Gtk.Window? window, string text) {
        Gtk.MessageDialog messageDialog = new Gtk.MessageDialog(
            window,
            Gtk.DialogFlags.MODAL,
            Gtk.MessageType.WARNING,
            Gtk.ButtonsType.CLOSE,
            "%s",
            text
        );

        messageDialog.run();
        messageDialog.destroy();
    }

    public void error(Gtk.Window? window, string text) {
        Gtk.MessageDialog messageDialog = new Gtk.MessageDialog(
            window,
            Gtk.DialogFlags.MODAL,
            Gtk.MessageType.ERROR,
            Gtk.ButtonsType.CLOSE,
            "%s",
            text
        );

        messageDialog.run();
        messageDialog.destroy();
    }
}
