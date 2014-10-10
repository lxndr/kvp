namespace Kv {


[Compact]
private enum PriceColumn {
	PRICE_VALUE,
	PRICE_TITLE,
	METHOD_VALUE,
	METHOD_TITLE,
	METHOD_VISIBILITY,
	COUNT
}



[GtkTemplate (ui = "/org/lxndr/kvp/ui/service-window.ui")]
class ServiceWindow : Gtk.Window {
	public Database db { get; construct set; }
	private int current_building = 1;
	private Gee.Map<int, int> service_column_map;

	[GtkChild]
	private Gtk.ScrolledWindow service_scrolled;
	private ServiceTable service_table;

	[GtkChild]
	private Gtk.ComboBoxText building_combo;

	[GtkChild]
	private Gtk.TreeView price_list;

	[GtkChild]
	private Gtk.ListStore method_list_store;


	private const string method_names[] = {
		"N", "1", "Ar", "P", "Am", "F5"
	};


	construct {
		service_column_map = new Gee.HashMap<int, int> ();

		service_table = new ServiceTable (db);
		service_table.read_only = true;
		service_table.refresh_view ();
		service_scrolled.add (service_table);
		service_scrolled.show_all ();

		update_service_list ();
		update_building_list ();
	}


	public ServiceWindow (Gtk.Window parent, Database _db) {
		Object (type: Gtk.WindowType.TOPLEVEL,
				transient_for: parent,
				default_width: 900,
				default_height: 500,
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

		if (list.size > 0)
			building_combo.active_id = list[0].id.to_string ();
	}


	[GtkCallback]
	private void building_changed () {
		if (building_combo.active_id == null)
			current_building = 0;
		else
			current_building = int.parse (building_combo.active_id);

		update_price_list ();
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
		types += typeof (int);
		types += typeof (string);

		foreach (var service in service_list) {
			types += typeof (int);
			types += typeof (string);
			types += typeof (int);
			types += typeof (string);
			types += typeof (bool);
		}

		price_list.model = new Gtk.ListStore.newv (types);

		/* month column */
		var text_cell = new Gtk.CellRendererText ();
		text_cell.set ("background", "grey95");
		column = new Gtk.TreeViewColumn.with_attributes (_("Year, month"), text_cell, "text", 1);
		price_list.append_column (column);

		/* service list */
		var base_column = 2;
		foreach (var service in service_list) {
			column = new Gtk.TreeViewColumn ();
			column.set ("title", service.name,
						"resizable", true);

			text_cell = new Gtk.CellRendererText ();
			text_cell.set ("editable", true,
							"xalign", 1.0,
							"xpad", 3);
			text_cell.set_data<int> ("service", service.id);
			text_cell.edited.connect (price_edited);
			column.pack_start (text_cell, true);
			column.add_attribute (text_cell, "text", base_column + PriceColumn.PRICE_TITLE);

			var combo_cell = new Gtk.CellRendererCombo ();
			combo_cell.set ("editable", true,
							"has_entry", false,
							"model", method_list_store,
							"text-column", 0,
							"weight", 700,
							"width", 25,
							"xpad", 3);
			combo_cell.set_data<int> ("service", service.id);
			combo_cell.changed.connect (method_changed);
			column.pack_start (combo_cell, false);
			column.add_attribute (combo_cell, "text", base_column + PriceColumn.METHOD_TITLE);
			column.add_attribute (combo_cell, "visible", base_column + PriceColumn.METHOD_VISIBILITY);

			price_list.append_column (column);
			service_column_map[service.id] = base_column;
			base_column += PriceColumn.COUNT;
		}
	}


	private void update_price_list () {
		unowned Gtk.ListStore model = price_list.model as Gtk.ListStore;
		model.clear ();

		if (current_building == 0)
			return;

		var start_period = 24168;
		var now = new DateTime.now_local ();
		var end_period = now.get_year () * 12 + now.get_month () + 4;

		for (var period = start_period; period <= end_period; period++) {
			var year = period / 12;
			var month = period % 12;
			string period_title = "%d, %s".printf (year, Utils.month_to_string (month));

			Gtk.TreeIter iter;
			model.append (out iter);
			model.set (iter, 0, period, 1, period_title);

			var list = db.fetch_entity_list<Price> (Price.table_name,
					"building=%d AND period=%d".printf (current_building, period));
			foreach (var p in list) {
				if (p == null)
					continue;

				var base_column = service_column_map[p.service.id];
				model.set (iter,
						base_column + PriceColumn.PRICE_VALUE, p.value.val,
						base_column + PriceColumn.PRICE_TITLE, p.value.format (),
						base_column + PriceColumn.METHOD_VALUE, p.method,
						base_column + PriceColumn.METHOD_TITLE, method_names[p.method],
						base_column + PriceColumn.METHOD_VISIBILITY, true);
			}
		}
	}


	private void price_edited (Gtk.CellRendererText cell, string tree_path, string new_text) {
		int service = cell.get_data<int> ("service");
		int base_column = service_column_map[service];

		var money = Money.from_formatted (new_text);

		Gtk.TreeIter tree_iter;
		unowned Gtk.ListStore model = (Gtk.ListStore) price_list.model;
		model.get_iter_from_string (out tree_iter, tree_path);
		model.set (tree_iter, base_column + PriceColumn.PRICE_VALUE, money.val);

		value_changed (model, tree_iter, service);
	}


	private void method_changed (Gtk.CellRendererCombo cell, string tree_path, Gtk.TreeIter combo_tree_iter) {
		int service = cell.get_data<int> ("service");
		int base_column = service_column_map[service];

		int method;
		method_list_store.get (combo_tree_iter, 1, out method);

		Gtk.TreeIter tree_iter;
		unowned Gtk.ListStore model = (Gtk.ListStore) price_list.model;
		model.get_iter_from_string (out tree_iter, tree_path);
		model.set (tree_iter, base_column + PriceColumn.METHOD_VALUE, method);

		value_changed (model, tree_iter, service);
	}


	private void value_changed (Gtk.ListStore model, Gtk.TreeIter tree_iter, int service) {
		int period, price, method;
		int base_column = service_column_map[service];

		model.get (tree_iter, 0, out period,
				base_column + PriceColumn.PRICE_VALUE, out price,
				base_column + PriceColumn.METHOD_VALUE, out method);

		if (price == 0) {
			model.set (tree_iter,
					base_column + PriceColumn.PRICE_VALUE, 0,
					base_column + PriceColumn.PRICE_TITLE, null,
					base_column + PriceColumn.METHOD_VALUE, 0,
					base_column + PriceColumn.METHOD_VISIBILITY, false);

			db.delete_entity (Price.table_name,
					"building=%d AND period=%d AND service=%d"
					.printf (current_building, period, service));
		} else {
			var m = Money (price);
			model.set (tree_iter,
					base_column + PriceColumn.PRICE_TITLE, m.format (),
					base_column + PriceColumn.METHOD_TITLE, method_names[method],
					base_column + PriceColumn.METHOD_VISIBILITY, true);

			db.exec_sql (("REPLACE INTO %s VALUES (%d, %d, %d, %" + int64.FORMAT + ", %d)")
					.printf (Price.table_name, current_building, period, service, price, method), null);
		}
	}
}


}
