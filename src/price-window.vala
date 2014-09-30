namespace Kv {


public class PriceWindow : Gtk.Window {
	public Database db { get; construct set; }
	private PriceTable view_table;


	construct {
		title = _("Reference - Prices");

		view_table = new PriceTable (db);
		view_table.refresh_view ();

		var scrolled = new Gtk.ScrolledWindow (null, null);
		scrolled.add (view_table);
		scrolled.show_all ();

		add (scrolled);
	}


	public PriceWindow (Gtk.Window parent, Database _db) {
		Object (type: Gtk.WindowType.TOPLEVEL,
				transient_for: parent,
				default_width: 500,
				default_height: 300,
				window_position: Gtk.WindowPosition.CENTER_ON_PARENT,
				db: _db);
	}
}


}
