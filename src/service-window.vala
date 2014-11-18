namespace Kv {


[GtkTemplate (ui = "/org/lxndr/kvp/ui/service-window.ui")]
class ServiceWindow : Gtk.Window, SingletonWindow {
	[GtkChild] private Gtk.ScrolledWindow service_scrolled;
	private ServiceTable service_table;

	[GtkChild] private Gtk.ComboBox building_combo;
	[GtkChild] private Gtk.ScrolledWindow price_scrolled;
	private PriceTable price_table;


	construct {
		service_table = new ServiceTable (get_database ());
		service_table.read_only = true;
		service_table.refresh_view ();
		service_scrolled.add (service_table);
		service_scrolled.show_all ();

		var building_model = new Gtk.ListStore (2, typeof (string), typeof (Building));
		building_combo.model = building_model;

		price_table = new PriceTable (get_database ());
		price_scrolled.add (price_table);
		price_scrolled.show_all ();

		update_building_list ();
	}


	public ServiceWindow (Gtk.Window parent, Database _db) {
		Object (type: Gtk.WindowType.TOPLEVEL,
				transient_for: parent,
				default_width: 900,
				default_height: 500,
				window_position: Gtk.WindowPosition.CENTER_ON_PARENT);
	}


	public void update_building_list () {
		Gtk.TreeIter iter;
		var model = (Gtk.ListStore) building_combo.model;
		model.clear ();

		var list = get_database ().get_building_list ();
		foreach (var building in list) {
			string name = "%s, %s".printf (building.street, building.number);
			model.append (out iter);
			model.set (iter, 0, name, 1, building);
		}

		if (model.get_iter_first (out iter))
			building_combo.set_active_iter (iter);
	}


	[GtkCallback]
	private void building_changed () {
		Building building;
		Gtk.TreeIter iter;
		var model = (Gtk.ListStore) building_combo.model;
		building_combo.get_active_iter (out iter);
		model.get (iter, 1, out building);
		price_table.setup (building);
	}
}


}
