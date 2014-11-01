namespace Kv {


public class BuildingWindow : Gtk.Window, SingletonWindow {
	private BuildingTable view_table;


	construct {
		title = _("Reference - Buildings");
		default_width = 500;
		default_height = 300;

		view_table = new BuildingTable (get_database ());
		view_table.refresh_view ();

		var scrolled = new Gtk.ScrolledWindow (null, null);
		scrolled.add (view_table);
		scrolled.show_all ();

		add (scrolled);
	}
}


}
