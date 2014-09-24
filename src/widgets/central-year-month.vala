namespace Kv {


public class CentralYearMonth : YearMonth {
	public int locked_period { get; set; }


	public CentralYearMonth (Gtk.Widget _relative_to) {
		Object (relative_to: _relative_to);
	}


	protected override void refresh_looks () {
		base.refresh_looks ();

		int month = (int) Math.lround (year.value) * 12;
		unowned SList<Gtk.RadioButton> list = months;
		while (list != null) {
			unowned Gtk.Widget w = list.data;
			unowned Gtk.StyleContext sc = w.get_style_context ();
			sc.remove_class ("new-month");
			sc.remove_class ("locked-month");

			if (month == end_period)
				sc.add_class ("new-month");
			if (w.sensitive == true && month <= locked_period)
				sc.add_class ("locked-month");

			month++;
			list = list.next;
		}
	}
}


}
