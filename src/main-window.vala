namespace Kv {


[GtkTemplate (ui = "/ui/main-window.ui")]
class MainWindow : Gtk.ApplicationWindow {
	/* period */
	[GtkChild]
	private Gtk.ToolButton current_period_button;
	[GtkChild]
	private Gtk.Box current_period_widget;
	[GtkChild]
	private Gtk.ComboBoxText current_period_month;
	[GtkChild]
	private Gtk.SpinButton current_period_year;
	private Gtk.Popover current_period_popover;

	/* reports */
	[GtkChild]
	private Gtk.Menu report_menu;

	/*  */
	[GtkChild]
	private Gtk.Paned paned1;
	[GtkChild]
	private Gtk.Paned paned2;

	/* tables */
	private AccountTable account_table;
	private PeopleTable people_table;
	private TaxTable tax_table;

	/*  */
	private Period current_period;


	public MainWindow (Application app) {
		Object (application: app);

		/* UI: period */
		current_period_popover = new Gtk.Popover (current_period_button);
		current_period_popover.add (current_period_widget);
		current_period_popover.closed.connect (current_period_popover_closed);

		/* UI: reports */
		foreach (var r in app.reports.entries) {
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
		account_table = new AccountTable (app.db);
		account_table.selection_changed.connect (account_changed);
		paned2.add1 (account_table.get_root_widget ());

		/* UI: people list */
		people_table = new PeopleTable (app.db);
		paned2.add2 (people_table.get_root_widget ());

		/* UI: tax list */
		tax_table = new TaxTable (app.db);
		paned1.add2 (tax_table.get_root_widget ());

		/*  */
		account_table.update_view ();
		init_current_period ();
	}


	/*
	 * Current period
	 */
	private void init_current_period () {
		var db = (application as Application).db;

		/* real world period is the default */
		var now = new DateTime.now_local ();
		var period = Period () {
			year = now.get_year (),
			month = now.get_month ()
		};

		/* load current year from the settings */
		var setting = db.get_setting ("current_year");
		if (setting != null) {
			var year = int64.parse (setting);
			if (year > 0)
				period.year = (int) year;
		}

		/* load current month from the settings */
		setting = db.get_setting ("current_month");
		if (setting != null) {
			var month = int64.parse (setting);
			if (month >= 1 && month <= 12)
				period.month = (int) month;
		}

		set_current_period (period);
	}


	private void set_current_period (Period period) {
		var db = (application as Application).db;
		var label = "%s %d".printf (Utils.month_to_string(period.month), period.year);

		/* check if this is an empty period and we need to duplicate all the data */
		if (db.is_empty_period (period) == true) {
			var msg = new Gtk.MessageDialog (this, Gtk.DialogFlags.MODAL,
					Gtk.MessageType.QUESTION, Gtk.ButtonsType.NONE,
					"Period '%s' has empty data. Do you want to duplicate the last period to the new?", label);
			msg.add_buttons ("Yes", Gtk.ResponseType.YES,
							 "No", Gtk.ResponseType.NO,
							 "Cancel", Gtk.ResponseType.CANCEL);
			var resp = msg.run ();
			msg.destroy ();

			switch (resp) {
			case Gtk.ResponseType.YES:
				/* find last period and copy everything needed */
				break;
			case Gtk.ResponseType.NO:
				/* continue this function and do not copy anything */
				break;
			case Gtk.ResponseType.CANCEL:
			case Gtk.ResponseType.CLOSE:
			default:
				/* do not do anything */
				return;
			}
		}

		/* the button label */
		current_period_button.label = label;
		current_period = period;

		/* store current period */
		db.set_setting ("current_year", period.year.to_string ());
		db.set_setting ("current_month", period.month.to_string ());

		/* update table views */
		account_changed ();
	}


	[GtkCallback]
	private void current_period_button_clicked () {
		/* set up popover widges */
		current_period_month.active_id = current_period.month.to_string ();
		current_period_year.value = (double) current_period.year;

		current_period_popover.show ();
	}


	private void current_period_popover_closed () {
		var period = Period () {
			month = (int) int.parse (current_period_month.active_id),
			year = (int) current_period_year.value
		};

		set_current_period (period);
	}


	/*
	 * Reports
	 */
	private void report_menu_clicked (Gtk.MenuItem mi) {
		var type = mi.get_data<Type> ("report-type");
		if (type == Type.INVALID)
			return;

		
		var db = (application as Application).db;
		var report = Object.new (type,
				"db", db,
				"current_period", current_period,
				"selected_account", account_table.get_selected_account ()
				) as Report;

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
			AppInfo.launch_default_for_uri (tmp_file.get_uri (), null);
		} catch (Error e) {
			error ("Error opening the report: %s", e.message);
		}
	}


	/*
	 * 
	 */
	private void account_changed () {
		var account = account_table.get_selected_entity () as Account;

		people_table.setup_view (current_period, account);
		tax_table.setup_view (current_period, account);
	}
}


}
