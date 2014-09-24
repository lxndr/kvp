namespace Kv {


public class YearMonth : Gtk.Popover {
	private Gtk.Grid grid;
	private SList<unowned Gtk.RadioButton> months;
	private Gtk.SpinButton year;


	public int period {
		get { return _get_period (); }
		set { _set_period (value); }
	}

	public int start_period { get; set; default = 0; }
	public int end_period { get; set; default = 0; }


	construct {
		grid = new Gtk.Grid ();
		grid.border_width = 4;
		grid.column_spacing = 4;
		grid.row_spacing = 4;
		grid.column_homogeneous = true;

		/* months */
		const string month_list[] = {
			N_("jan"), N_("feb"), N_("mar"), N_("apr"),
			N_("may"), N_("jun"), N_("jul"), N_("aug"),
			N_("sep"), N_("oct"), N_("nov"), N_("dec")
		};

		Gtk.RadioButton rb;
		for (var i = 0; i < 12; i++) {
			rb = new Gtk.RadioButton.with_label_from_widget (rb, dgettext (null, month_list[i]));
			rb.set_mode (false);
			grid.attach (rb, i % 4, i / 4, 1, 1);
			months.append (rb);
		}

		months = rb.get_group ().copy ();
		months.reverse ();

		/* year */
		year = new Gtk.SpinButton.with_range (1900.0, 10000.0, 1.0);
		grid.attach (year, 0, 3, 4, 1);

		/* previous month */
		var prev = new Gtk.Button.with_label ("<");
		prev.tooltip_text = _("Previous month");
		prev.clicked.connect (prev_clicked);
		grid.attach (prev, 0, 4, 1, 1);

		/* current month */
		var today = new Gtk.Button.with_label (_("This month"));
		today.clicked.connect (today_clicked);
		grid.attach (today, 1, 4, 2, 1);

		/* next month */
		var next = new Gtk.Button.with_label (">");
		next.tooltip_text = _("Next month");
		next.clicked.connect (next_clicked);
		grid.attach (next, 3, 4, 1, 1);

		grid.show_all ();
		add (grid);
	}


	public YearMonth (Gtk.Widget _relative_to) {
		Object (relative_to: _relative_to);
	}


	private void _set_period (int period) {
		months.nth_data (period % 12).active = true;
		year.value = (double) (period / 12);
		update_style ();
	}


	private int _get_period () {
		int _month = 0;
		unowned SList<Gtk.RadioButton> list = months;
		while (list != null) {
			if (list.data.active == true)
				break;
			_month++;
			list = list.next;
		}

		int _year = (int) Math.lround (year.value);
		return _year * 12 + _month;
	}


	private void today_clicked () {
		var now = new DateTime.now_local ();
		period = now.get_year () * 12 + now.get_month () - 1;
	}


	private void prev_clicked () {
		period--;
	}


	private void next_clicked () {
		period++;
	}


	private void update_style () {
		int month = (int) Math.lround (year.value) * 12;

		unowned SList<Gtk.RadioButton> list = months;
		while (list != null) {
			bool in_range = (start_period <= month && month <= end_period);
			list.data.sensitive = in_range;
			month++;
			list = list.next;
		}
	}
}


}
