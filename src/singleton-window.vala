namespace Kv {


public interface SingletonWindow : Gtk.Window {
	public unowned Database get_database () {
		return ((MainWindow) transient_for).db;
	}
}


}
