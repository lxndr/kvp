namespace Kv {


public class MonthPopover : Gtk.Popover {
	protected Gtk.Grid grid;
	protected SList<unowned Gtk.RadioButton> months;
	protected Gtk.SpinButton year;
	protected Gtk.Button prev;
	protected Gtk.Button next;
	protected Month first_month;
	protected Month last_month;


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
		year.value_changed.connect (year_changed);
		grid.attach (year, 0, 3, 4, 1);

		/* previous month */
		prev = new Gtk.Button.with_label ("<");
		prev.tooltip_text = _("Previous month");
		prev.clicked.connect (prev_clicked);
		grid.attach (prev, 0, 4, 1, 1);

		/* current month */
		var today = new Gtk.Button.with_label (_("This month"));
		today.clicked.connect (today_clicked);
		grid.attach (today, 1, 4, 2, 1);

		/* next month */
		next = new Gtk.Button.with_label (">");
		next.tooltip_text = _("Next month");
		next.clicked.connect (next_clicked);
		grid.attach (next, 3, 4, 1, 1);

		grid.show_all ();
		add (grid);
	}


	public MonthPopover (Gtk.Widget _relative_to) {
		Object (relative_to: _relative_to);
	}


	public Month month {
		owned get {
			uint _month = 0;
			unowned SList<Gtk.RadioButton> list = months;
			while (list != null) {
				if (list.data.active == true)
					break;
				_month++;
				list = list.next;
			}

			var _year = (DateYear) Math.lround (year.value);
			return new Month.from_year_month (_year, (DateMonth) _month);
		}

		set {
			months.nth_data (value.month).active = true;
			year.value = (double) (value.year);
			refresh_looks ();
		}
	}


	private void year_changed () {
		var cur = month;

		if (cur.compare (first_month) < 0)
			month = (owned) first_month;
		else if (cur.compare (last_month) > 0)
			month = (owned) last_month;
		else
			refresh_looks ();
	}


	private void today_clicked () {
		var now = new DateTime.now_local ();
		month = new Month.now ();
	}


	private void prev_clicked () {
		month.prev ();
	}


	private void next_clicked () {
		month.next ();
	}


	protected virtual void refresh_looks () {
		var cur = month;
		var m = cur.get_first_month ();

		unowned SList<Gtk.RadioButton> list = months;
		while (list != null) {
			list.data.sensitive = month.in_range (first_month, last_month);
			month.next ();
			list = list.next;
		}

		prev.sensitive = first_month.compare (cur) < 0;
		next.sensitive = cur.compare (last_month) < 0;
	}


	public void set_range (owned Month first, owned Month last)
			requires (first.compare (last) <= 0) {
		first_month = first;
		last_month = last;
		year.set_range ((double) first.year, (double) last.year);
	}
}


}
