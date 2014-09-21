namespace Kv {


public class YearMonth : Gtk.Popover {
	private Gtk.Grid grid;
	private SList<Gtk.RadioButton> months;
	private Gtk.SpinButton year;


	public int period { get; set; }


	construct {
		grid = new Gtk.Grid ();
		grid.border_width = 4;
		grid.column_spacing = 4;
		grid.row_spacing = 4;

		/* months */
		const string month_list[] = {
			"jan", "feb", "mar", "apr",
			"may", "jun", "jul", "aug",
			"sep", "oct", "nov", "dec"
		};

		months = new SList<Gtk.RadioButton> ();
		for (var i = 0; i < 12; i++) {
			var r = new Gtk.RadioButton.with_label (/*months*/ null, month_list[i]);
			r.set_mode (false);
			grid.attach (r, i / 3, i % 3, 1, 1);
			months.append (r);
		}

		/* year */
		year = new Gtk.SpinButton.with_range (1900.0, 10000.0, 1.0);
		grid.attach (year, 0, 3, 4, 1);

		/* previous month */
		var prev = new Gtk.Button.with_label ("<");
		grid.attach (prev, 0, 4, 1, 1);

		/* current month */
		var today = new Gtk.Button.with_label ("Current");
		grid.attach (today, 1, 4, 2, 1);

		/* next month */
		var next = new Gtk.Button.with_label (">");
		grid.attach (next, 3, 4, 1, 1);

		grid.show_all ();
		add (grid);
	}


	public YearMonth (Gtk.Widget _relative_to) {
		Object (relative_to: _relative_to);
	}
}


}
