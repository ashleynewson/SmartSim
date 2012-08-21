namespace BasicDialog {
	public int ask_overwrite (Gtk.Window? window, string filename) {
		Gtk.MessageDialog messageDialog = new Gtk.MessageDialog (
			window,
			Gtk.DialogFlags.MODAL,
			Gtk.MessageType.WARNING,
			Gtk.ButtonsType.YES_NO,
			"The file \"%s\" already exists.\nDo you want to overwrite it?",
			filename);
		
		int result = messageDialog.run ();
		
		messageDialog.destroy ();
		
		return result;
	}
	
	public void information (Gtk.Window? window, string text) {
		Gtk.MessageDialog messageDialog = new Gtk.MessageDialog (
			window,
			Gtk.DialogFlags.MODAL,
			Gtk.MessageType.INFO,
			Gtk.ButtonsType.CLOSE,
			"%s",
			text);
		
		messageDialog.run ();
		messageDialog.destroy ();
	}
	
	public void warning (Gtk.Window? window, string text) {
		Gtk.MessageDialog messageDialog = new Gtk.MessageDialog (
			window,
			Gtk.DialogFlags.MODAL,
			Gtk.MessageType.WARNING,
			Gtk.ButtonsType.CLOSE,
			"%s",
			text);
		
		messageDialog.run ();
		messageDialog.destroy ();
	}
	
	public void error (Gtk.Window? window, string text) {
		Gtk.MessageDialog messageDialog = new Gtk.MessageDialog (
			window,
			Gtk.DialogFlags.MODAL,
			Gtk.MessageType.ERROR,
			Gtk.ButtonsType.CLOSE,
			"%s",
			text);
		
		messageDialog.run ();
		messageDialog.destroy ();
	}
}
