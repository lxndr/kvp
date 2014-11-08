namespace Kv {


/*
 * This is simply a wrapper for GLib.Date
 * to make it fully functional, nullable property,
 * and gather all date functionality in one class.
 */
public class Date {
	private GLib.Date date;


	public Date.from_ymd (DateYear _year, DateMonth _month, DateDay _day) {
		date.set_dmy (_day, _month, _year);
	}


	public Date.from_days (int _days) {
		date.set_julian (_days);
	}


	public Date.now () {
		int year;
		int month;
		int day;

		var now = new DateTime.now_local ();
		now.get_ymd (out year, out month, out day);
		date.set_dmy ((DateDay) day, month, (DateYear) year);
	}


	public int get_days () {
		return (int) date.get_julian ();
	}


	public unowned Date assign (Date that) {
		date = that.date;
		return this;
	}


	public int compare (Date that) {
		return get_days () - that.get_days ();
	}


	public int diff (Date that) {
		return compare (that).abs ();
	}


	public static void clamp_range (ref Date? first, ref Date? last, Date? min, Date? max) {
		/* no dates */
		if (first == null && last == null)
			return;

		if (min != null) {
			if (last != null && last.compare (min) < 0) {
				/* out of range */
				first = null;
				last = null;
			}

			if (first == null || first.compare (min) < 0)
				first = min;
		}

		if (max != null) {
			if (first != null && first.compare (max) > 0) {
				/* out of range */
				first = null;
				last = null;
			}

			if (last == null || last.compare (max) > 0)
				last = max;
		}
	}


	public string? format () {
		if (date.valid ()) {
			char buf[32];
			date.strftime (buf, "%x");
			return (string) buf;
		}

		return null;
	}
}


}
