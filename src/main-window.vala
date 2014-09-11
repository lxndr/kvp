namespace Kv {


[GtkTemplate (ui = "/ui/main-window.ui")]
class MainWindow : Gtk.ApplicationWindow {
	private Period current_period;


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
		account_table.selection_changed.connect (account_changed);
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

		current_period.month = 1;
		current_period.year = 2014;

/* TEST */
	var rep = new Report001 ();
	rep.make (app.db);
	rep.write (File.new_for_path ("./out/report001.xlsx"));


stdout.printf ("TESTING\n");
	var z = new Archive.Zip ();
	z.open (File.new_for_path ("./out/report001.xlsx"));
	var f = z.extract ("xl/worksheets/sheet1.xml");
stdout.printf ("FF %s\n", f.get_path ());
	error ("DONE");


		account_table.update_view ();
	}


	/* current period */
	private void set_current_period (Period period) {
		current_period_button.label = "%s %d".printf (
				Utils.month_to_string(period.month),
				period.year);

		current_period = period;

		var account = account_table.get_selected_entity () as Account;
		tax_table.setup_view (current_period, account);
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


	private void account_changed () {
		var account = account_table.get_selected_entity () as Account;
		tax_table.setup_view (current_period, account);
	}
}


}
