namespace Kv {


[GtkTemplate (ui = "/ui/service-window.ui")]
class ServiceWindow : Gtk.Window {
	public Database db { get; construct set; }
	private Building current_building;


	[GtkChild]
	private Gtk.ScrolledWindow service_scrolled;
	private ServiceTable service_table;

	[GtkChild]
	private Gtk.ComboBoxText building_combo;

	[GtkChild]
	private Gtk.TreeView price_list;


	construct {
		/* service */
		service_table = new ServiceTable (db);
		service_table.read_only = true;
		service_table.refresh_view ();
		service_scrolled.add (service_table);
		service_scrolled.show_all ();

		/* price */
		update_building_list ();
		update_service_list ();
	}


	public ServiceWindow (Gtk.Window parent, Database _db) {
		Object (type: Gtk.WindowType.TOPLEVEL,
				transient_for: parent,
				default_width: 500,
				default_height: 300,
				window_position: Gtk.WindowPosition.CENTER_ON_PARENT,
				db: _db);
	}


	public void update_building_list () {
		var list = db.get_building_list ();

		building_combo.remove_all ();
		foreach (var building in list) {
			string name = "%s, %s".printf (building.street, building.number);
			building_combo.append (building.id.to_string (), name);
		}
	}


	[GtkCallback]
	private void building_changed () {
		
	}


	private void update_service_list () {
		Gtk.TreeViewColumn column;
		var service_list = db.get_service_list ();

		/* remove columns */
		var columns = price_list.get_columns ();
		unowned List<unowned Gtk.TreeViewColumn> icolumn = columns;
		while (icolumn != null) {
			price_list.remove_column (icolumn.data);
			icolumn = icolumn.next;
		}

		/* store */
		Type[] types = {};
		types += typeof (Price);
		types += typeof (string);

		foreach (var service in service_list) {
			types += typeof (string);
			types += typeof (int);
		}

		/* month column */
		var text_cell = new Gtk.CellRendererText ();
		column = new Gtk.TreeViewColumn.with_attributes (_("Year, month"), text_cell, "text", 1);
		price_list.append_column (column);

		/* service list */
		foreach (var service in service_list) {
			column = new Gtk.TreeViewColumn ();
			column.set ("title", service.name,
						"resizable", true);

			text_cell = new Gtk.CellRendererText ();
			column.pack_start (text_cell, true);
//			column.add_attribute (text_cell, "text", );

			price_list.append_column (column);
		}
	}


	private void update_price_list () {
//		var 
	}
}


}
