namespace Kv {


public class BuildingWindow : Gtk.Window {
	public Database db { get; construct set; }
	private BuildingTable view_table;


	construct {
		title = _("Reference - Buildings");

		view_table = new BuildingTable (db);
		view_table.update_view ();
		add (view_table.get_root_widget ());
	}


	public BuildingWindow (Gtk.Window parent, Database _db) {
		Object (type: Gtk.WindowType.TOPLEVEL,
				transient_for: parent,
				default_width: 500,
				default_height: 300,
				window_position: Gtk.WindowPosition.CENTER_ON_PARENT,
				db: _db);
	}
}


}
