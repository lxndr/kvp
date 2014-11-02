namespace Kv {


public class CentralMonthPopover : MonthPopover {
	public Month lock_month { get; set; }


	public CentralMonthPopover (Gtk.Widget _relative_to) {
		Object (relative_to: _relative_to);
	}


	protected override void refresh_looks () {
		base.refresh_looks ();

		var it = new Month.from_year_month ((DateYear) Math.lround (year.value), DateMonth.JANUARY);
		unowned SList<Gtk.RadioButton> list = months;
		while (list != null) {
			unowned Gtk.Widget w = list.data;
			unowned Gtk.StyleContext sc = w.get_style_context ();
			sc.remove_class ("new-month");
			sc.remove_class ("lock-month");

			if (it.compare (first_month) == 0)
				sc.add_class ("new-month");
			if (w.sensitive == true && it.compare (lock_month) <=0)
				sc.add_class ("lock-month");

			it.next ();
			list = list.next;
		}
	}
}


}
