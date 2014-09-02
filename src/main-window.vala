namespace Kv {


[GtkTemplate (ui = "/ui/main-window.ui")]
class MainWindow : Gtk.ApplicationWindow {
	[GtkChild]
	private Gtk.ToolButton current_period_button;
	[GtkChild]
	private Gtk.Box current_period_widget;
	[GtkChild]
	private Gtk.ComboBoxText current_period_month;
	[GtkChild]
	private Gtk.SpinButton current_period_year;
	private Gtk.Popover current_period_popover;

	[GtkChild]
	private Gtk.Paned paned1;
	[GtkChild]
	private Gtk.Paned paned2;


	private AccountTable account_table;
	private PeopleTable people_table;
	private TaxTable tax_table;


	public MainWindow (Application app) {
		Object (application: app);

		account_table = new AccountTable (app.db);
		paned2.add1 (account_table.get_root_widget ());
		people_table = new PeopleTable (app.db);
		paned2.add2 (people_table.get_root_widget ());
		tax_table = new TaxTable (app.db);
		paned1.add2 (tax_table.get_root_widget ());

		/*  */
		current_period_popover = new Gtk.Popover (current_period_button);
		current_period_popover.add (current_period_widget);
		current_period_popover.closed.connect (current_period_popover_closed);
		current_period_year.set_value (2014.0);

		account_table.update_view ();
	}


	/* current period */
	private void set_current_period (Period period) {
		current_period_button.label = "%s %d".printf (
				Utils.month_to_string(period.month),
				period.year);
	}


	[GtkCallback]
	private void current_period_button_clicked () {
		current_period_popover.show ();
	}


	private void current_period_popover_closed () {
		var period = Period () {
			month = (uint8) int.parse (current_period_month.active_id),
			year = (int16) current_period_year.value
		};

		set_current_period (period);
	}


/*
	private void update_account_list () {
		Gtk.TreeIter iter;
		account_store.clear ();

		var list = (application as Application).get_account_list ();
		foreach (var account in list) {
			account_store.append (out iter);
			account_store.set (iter, 0, account, 1, account.number, 2, account.apartment);
		}
	}*/
}


}
