namespace Kv {


public class DatabaseValueAdapter : DB.ValueAdapter {
	public DatabaseValueAdapter () {
		base ();
		register (typeof (Money), null, string_to_money, money_to_string);
		register (typeof (Month), null, string_to_month, month_to_string);
		register (typeof (Date), null, string_to_date, date_to_string);
	}


	/* Money */
	private bool string_to_money (string? s, ref Value v) {
		var m = new Money.parse_raw_integer (s);
		v.set_instance (m);
		return true;
	}


	private bool money_to_string (ref Value v, out string? s) {
		var money = (Money*) v.peek_pointer ();
		s = money->integer.to_string ();
		return true;
	}


	/* Month */
	private bool string_to_month (string? s, ref Value v) {
		if (unlikely (s == null))
			return true;

		int result = int.parse (s);
		var month = new Month.from_raw_value (result);
		v.set_instance (month);
		return true;
	}


	private bool month_to_string (ref Value v, out string? s) {
		var month = (Month) v.peek_pointer ();
		if (month == null)
			s = null;
		else
			s = month.raw_value.to_string ();
		return true;
	}


	/* Date */
	private bool string_to_date (string? s, ref Value v) {
		if (s == null)
			return true;

		int result = int.parse (s);
		var date = new Date.from_days (result);
		v.set_instance (date);
		return true;		
	}


	private bool date_to_string (ref Value v, out string? s) {
		var date = (Date) v.peek_pointer ();
		if (date == null)
			s = null;
		else
			s = date.get_days ().to_string ();
		return true;
	}
}


}
