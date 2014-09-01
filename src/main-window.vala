namespace Kv {


[GtkTemplate (ui = "/ui/main-window.ui")]
class MainWindow : Gtk.ApplicationWindow
{
	public MainWindow (Application app) {
		Object (application: app);
	}
}


}
