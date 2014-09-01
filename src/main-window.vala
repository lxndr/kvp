namespace Kv {


[GtkTemplate (ui = "/ui/main-window.ui")]
class MainWindow : Gtk.ApplicationWindow {
	[GtkChild]
	private Gtk.ToolButton current_period;
	[GtkChild]
	private Gtk.ListStore lodging_store;
	[GtkChild]
	private Gtk.Menu lodging_menu;


	public MainWindow (Application app) {
		Object (application: app);
	}


	public void init_with_data () {
		var app = (application as Application);
	}


	private void set_current_period (Period period) {
		current_period.label = "%s %d".printf (
			Utils.month_to_string(period.month),
			period.year);
	}


	[GtkCallback]
	private void current_period_clicked () {
	}


	[GtkCallback]
	private bool lodging_button_pressed (Gdk.EventButton event) {
		if (event.button == 3)
			lodging_menu.popup (null, null, null, event.button, Gtk.get_current_event_time ());
		return false;
	}


	[GtkCallback]
	private void lodging_add_clicked () {
		Account accout = (application as Application).add_account ();

		Gtk.TreeIter iter;
		lodging_store.append (out iter);
		lodging_store.set (iter, 0, account.);
	}

	[GtkCallback]
	private void lodging_remove_clicked () {
	}
}


}
