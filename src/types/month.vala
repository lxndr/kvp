namespace Kv {


public class Month {
	public uint raw_value { get; set; }

	public DateYear year {
		get { return (DateYear) (raw_value / 12); }
	}

	public DateMonth month {
		get { return (DateMonth) (raw_value % 12 + 1); }
	}


	public Date? first_day { get; private set; }
	public Date? last_day { get; private set; }


	public Month.from_raw_value (uint _value) {
		raw_value = _value;
	}


	public Month.from_year_month (DateYear _year, DateMonth _month) {
		raw_value = (uint) _year * 12 + (uint) _month - 1;
	}


	public Month.now () {
		var date = new DateTime.now_local ();
		raw_value = (uint) date.get_year () * 12 + (uint) date.get_month () - 1;
	}


	public Month copy () {
		return new Month.from_raw_value (raw_value);
	}


	public void prev () {
		raw_value -= 1;
	}


	public void next () {
		raw_value += 1;
	}


	public Month get_prev () {
		return new Month.from_raw_value (raw_value - 1);
	}


	public Month get_next () {
		return new Month.from_raw_value (raw_value + 1);
	}


	public Month get_first_month () {
		return new Month.from_year_month (this.year, DateMonth.JANUARY);
	}


	public Month get_last_month () {
		return new Month.from_year_month (this.year, DateMonth.DECEMBER);
	}


	public int compare (Month _month) {
		return (int) raw_value - (int) _month.raw_value;
	}


	public bool equals (Month _month) {
		return compare (_month) == 0;
	}


	public bool in_range (Month? first_month, Month? last_month) {
		return (first_month == null || this.compare (first_month) >= 0) &&
				(last_month == null || this.compare (last_month) <= 0);
	}


	public unowned string month_name () {
		const string[] names = {
			null,
			N_("January"),
			N_("February"),
			N_("March"),
			N_("April"),
			N_("May"),
			N_("June"),
			N_("July"),
			N_("August"),
			N_("September"),
			N_("October"),
			N_("November"),
			N_("December")
		};

		return dgettext (null, names[month]);
	}


	public unowned string month_short_name () {
		const string[] names = {
			null,
			N_("jan"),
			N_("feb"),
			N_("mar"),
			N_("apr"),
			N_("may"),
			N_("jun"),
			N_("jul"),
			N_("aug"),
			N_("sep"),
			N_("oct"),
			N_("nov"),
			N_("dec")
		};

		return dgettext (null, names[month]);
	}


	public string format () {
		return "%s %u".printf (month_name (), year);
	}
}


}
