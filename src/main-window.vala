namespace Kv {


[GtkTemplate (ui = "/org/lxndr/kvp/ui/main-window.ui")]
public class MainWindow : Gtk.ApplicationWindow {
	public Database db { get; construct set; }
	private Building? current_building;
	private Month current_period;
	private Gee.Map<Type, Gtk.Window?> singleton_windows;

	/* currently selected period */
	[GtkChild] private Gtk.ToolButton current_period_button;
	private CentralMonthPopover current_period_popover;

	/* report menu */
	[GtkChild] private Gtk.Menu report_menu;

	/* reference menu */
	[GtkChild] private Gtk.Menu reference_menu;

	/* tables */
	[GtkChild] private Gtk.ScrolledWindow account_scroller;
	[GtkChild] private Gtk.ScrolledWindow tenant_scroller;
	[GtkChild] private Gtk.ScrolledWindow tax_scroller;

	private AccountTable account_table;
	private TenantTable tenant_table;
	private TaxTable tax_table;


	public MainWindow (Application _app, Database _db) {
		Object (application: _app,
				db: _db);

		current_period = new Month ();
		singleton_windows = new Gee.HashMap<Type, Gtk.Window?> ();

		/* UI: period */
		current_period_popover = new CentralMonthPopover (current_period_button);
		current_period_popover.closed.connect (current_period_popover_closed);

		/* UI: reports */
		foreach (var r in _app.reports.entries) {
			if (r.value == Type.INVALID) {
				report_menu.append (new Gtk.SeparatorMenuItem ());
			} else {
				var mi = new Gtk.MenuItem.with_label (r.key);
				mi.set_data<Type> ("report-type", r.value);
				mi.activate.connect (report_menu_clicked);
				mi.visible = true;
				report_menu.append (mi);
			}
		}

		/* UI: account list */
		account_table = new AccountTable (db);
		account_table.visible = true;
		account_table.selection_changed.connect (on_account_selection_changed);
		account_scroller.add (account_table);

		/* UI: tenant list */
		tenant_table = new TenantTable (db);
		tenant_table.visible = true;
//		tenant_table.entity_inserted.connect (on_tenant_list_changed);
//		tenant_table.entity_deleted.connect (on_tenant_list_changed);
		tenant_scroller.add (tenant_table);

		/* UI: tax list */
		tax_table = new TaxTable (db);
		tax_table.visible = true;
		tax_table.total_changed.connect (on_tax_total_changed);
		tax_scroller.add (tax_table);

		/*  */
		Gdk.threads_add_idle (() => {
			init_current_period ();
			return false;
		});
	}


	/*
	 * Utils
	 */
	private void default_popup_menu_position (Gtk.Widget widget, out int x, out int y, out bool push_in) {
		Gtk.Allocation alloc;
		widget.get_toplevel ().get_window ().get_origin (out x, out y);
		widget.get_allocation (out alloc);
		x += alloc.x;
		y += alloc.y;
		y += alloc.height;
		push_in = false;
	}


	/*
	 * Buildings
	 */
	[GtkCallback]
	private void buildings_clicked (Gtk.ToolButton button) {
		var menu = new Gtk.Menu ();

		var mi = new Gtk.RadioMenuItem.with_label (null, _("All buildings"));
		mi.set_data<Building?> ("building", null);
		mi.active = (current_building == null);
		mi.toggled.connect (building_clicked);
		menu.append (mi);

		var mi_sep = new Gtk.SeparatorMenuItem ();
		mi_sep.visible = true;
		menu.append (mi_sep);

		var buildings = db.fetch_entity_list<Building> (Building.table_name);
		foreach (var building in buildings) {
			mi = new Gtk.RadioMenuItem.with_label_from_widget ((Gtk.RadioMenuItem) mi,
					"%s, %s".printf (building.street, building.number));
			mi.set_data<Building?> ("building", building);
			mi.active = (current_building != null && current_building.id == building.id);
			mi.toggled.connect (building_clicked);
			menu.append (mi);
		}

		mi_sep = new Gtk.SeparatorMenuItem ();
		menu.append (mi_sep);

		var mi_edit = new Gtk.MenuItem.with_label (_("Edit..."));
		mi_edit.activate.connect (ref_buildings_clicked);
		menu.append (mi_edit);

		menu.show_all ();
		menu.attach_to_widget (button, null);
		menu.popup (null, null, (menu, out x, out y, out push_in) => {
			default_popup_menu_position (button, out x, out y, out push_in);
		}, 0, Gtk.get_current_event_time ());
	}


	private void building_clicked (Gtk.CheckMenuItem mi) {
		if (mi.active == true) {
			current_building = mi.get_data<Building> ("building");
			set_period (current_building, current_period);
		}
	}


	/*
	 * Current period
	 */
	private void init_current_period () {
		var period = new Month.now ();

		/* load current year from the settings */
		var setting = db.get_setting ("current_period");
		if (setting != null) {
			var val = (uint) uint64.parse (setting);
			if (val > 0)
				period.raw_value = val;
		}

		set_period (current_building, period);
	}


	[GtkCallback]
	private void current_period_button_clicked () {
		var app = application as Application;

		/* set up popover widges */
		

/*		current_period_popover.set_range (
				db.fetch_int (AccountPeriod.table_name, "MIN(period)"),
				db.fetch_int (AccountPeriod.table_name, "MAX(period)") + 1);*/
//		current_month_popover.locked_period = int.parse (db.get_setting ("locked_period"));
		current_period_popover.month = current_period;
		current_period_popover.show ();
	}


	private void current_period_popover_closed () {
		set_period (current_building, current_period_popover.month);
	}


	/*
	 * Reports
	 */
	[GtkCallback]
	private void reports_clicked (Gtk.ToolButton button) {
		report_menu.popup (null, null, (menu, out x, out y, out push_in) => {
			default_popup_menu_position (button, out x, out y, out push_in);
		}, 0, Gtk.get_current_event_time ());
	}


	private void report_menu_clicked (Gtk.MenuItem mi) {
		var type = mi.get_data<Type> ("report-type");
		if (type == Type.INVALID)
			return;

		
		var report = Object.new (type,
				"toplevel_window", this,
				"db", db,
				"building", current_building,
				"selected_account", account_table.get_selected ()) as Report;

		if (report.prepare () == false)
			return;

		try {
			report.make ();
		} catch (Error e) {
			error ("Error making a report: %s", e.message);
		}

		GLib.File tmp_file;

		try {
			tmp_file = File.new_for_path ("./out/report.xlsx");
			report.write (tmp_file);
		} catch (Error e) {
			error ("Error writing the report: %s", e.message);
		}

		try {
#if WINDOWS
			var ai = AppInfo.get_default_for_type (".xlsx", false);
			var l = new List<File> ();
			l.append (tmp_file);
			ai.launch (l, null);
#else
			AppInfo.launch_default_for_uri (tmp_file.get_uri (), null);
#endif
		} catch (Error e) {
			error ("Error opening the report: %s", e.message);
		}
	}


	/*
	 * 
	 */
	[GtkCallback]
	private void references_clicked (Gtk.ToolButton button) {
		reference_menu.popup (null, null, (menu, out x, out y, out push_in) => {
			default_popup_menu_position (button, out x, out y, out push_in);
		}, 0, Gtk.get_current_event_time ());
	}


	private void show_singleton_window (Type type) {
		var window = singleton_windows[type];
		if (window == null) {
			window = Object.new (type, "type", Gtk.WindowType.TOPLEVEL, "transient_for", this) as Gtk.Window;
			window.destroy.connect (() => {
				singleton_windows[type] = null;
			});
			singleton_windows[type] = window;
		}
		window.present ();
	}


	[GtkCallback]
	private void ref_services_clicked () {
		show_singleton_window (typeof (ServiceWindow));
	}


	[GtkCallback]
	private void ref_buildings_clicked () {
		show_singleton_window (typeof (BuildingWindow));
	}


	[GtkCallback]
	private void ref_people_clicked () {
		show_singleton_window (typeof (PeopleWindow));

/*
		if (people_window == null) {
			people_window = new PeopleWindow (this, (application as Application).db);
			people_window.add_to_tenants.connect (tenant_table.add_tenant);
			people_window.destroy.connect (() => {
				people_window = null;
			});
		}

		people_window.present ();*/
	}


	/*
	 * Events and actions
	 */
	private void set_period (Building? new_building, Month period) {
		if (new_building == current_building && period.equals (current_period))
			return;

		Gee.List<Building> buildings;
		if (new_building == null) {
			buildings = db.get_building_list ();
		} else {
			buildings = new Gee.ArrayList<Building> ();
			buildings.add (new_building);
		}

		foreach (var building in buildings) {
			if (!period.in_range (building.first_period, building.last_period))
				continue;

			if (building.first_period.equals (period))
				continue;

			if (!db.is_period_empty (building, period))
				continue;

			if (db.is_period_empty (building, period.get_prev ())) {
				var msg = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL,
						Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE,
						_("No previous calculations for period '%s' of building '%s'."),
						period.format (), building.number);
				msg.add_buttons (_("OK"), Gtk.ResponseType.OK);
				msg.run ();
				msg.destroy ();
				continue;
			}

			var msg = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL,
					Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE,
					_("Period '%s' for building '%s' has no data. Do you want to duplicate the last period to the new?"),
					period.format (), building.number);
			msg.add_buttons (_("Yes"), Gtk.ResponseType.YES,
							 _("No"), Gtk.ResponseType.NO,
							 _("Cancel"), Gtk.ResponseType.CANCEL);
			var resp = msg.run ();
			msg.destroy ();

			if (resp == Gtk.ResponseType.YES)
				db.prepare_period (building, period);
			else if (resp == Gtk.ResponseType.CANCEL || resp == Gtk.ResponseType.CLOSE)
				return;
		}

		current_period_button.label = period.format ();
		bool changed = !current_period.equals (period);
		current_period = period;
		if (changed) {
			db.set_setting ("current_period", period.raw_value.to_string ());
			account_table.setup (current_building, (int) current_period.raw_value);
		}
	}


	private void on_account_selection_changed () {
		unowned AccountPeriod periodic = account_table.get_selected ();
		tenant_table.setup (periodic);
		tax_table.setup (periodic);
	}


	private void on_tenant_list_changed () {
		
	}


	private void on_tax_total_changed (Tax tax) {
		
	}
}


}
