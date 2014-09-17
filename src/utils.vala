namespace Kv {

namespace Utils {


/*
 * Formats a double removing trailing zeroes.
 */
public string format_double (double n, int max_digits) {
	var s = "%.*f".printf (max_digits, n);

	int p = s.length - 1;
	for (; p >= 0; p--) {
		var ch = s[p];
		if (ch != '0') {
			if (ch == '.' || ch == ',')
				p--;
			break;
		}
	}

	return s[0:p+1];
}


public void transform_string_to_int (Value src_value, ref Value dest_value) {
	unowned string s = src_value.get_string ();
	dest_value.set_int (int.parse (s));
}


public void transform_string_to_int64 (Value src_value, ref Value dest_value) {
	unowned string s = src_value.get_string ();
	dest_value.set_int64 (int64.parse (s));
}


public void transform_string_to_double (Value src_value, ref Value dest_value) {
	unowned string s = src_value.get_string ();
	dest_value.set_double (double.parse (s));
}


public void transform_string_to_money (Value src_value, ref Value dest_value) {
	int64 n = int64.parse (src_value.get_string ());
	var m = Money (n);
	dest_value.set_boxed (&m);
}


public void transform_money_to_string (Value src_value, ref Value dest_value) {
	Money* m = (Money*) src_value.get_boxed ();
	dest_value.set_string (m->val.to_string ());
}


public void transform_double_to_property_adapter (Value src_value, ref Value dest_value) {
	double d = src_value.get_double ();
	dest_value.set_object (new DB.PropertyAdapter (format_double (d, 2)));
}


public void transform_property_adapter_to_double (Value src_value, ref Value dest_value) {
	var ad = src_value.get_object () as DB.PropertyAdapter;
	dest_value.set_double (double.parse (ad.val));
}


public void transform_money_to_property_adapter (Value src_value, ref Value dest_value) {
	Money* m = (Money*) src_value.get_boxed ();
	dest_value.set_object (new DB.PropertyAdapter (m->format ()));
}


public void transform_property_adapter_to_money (Value src_value, ref Value dest_value) {
	var ad = src_value.get_object () as DB.PropertyAdapter;
	var m = Money.from_formatted (ad.val);
	dest_value.set_boxed (&m);
}



public unowned string month_to_string (int month) {
	switch (month) {
	case  1: return "January";
	case  2: return "February";
	case  3: return "March";
	case  4: return "April";
	case  5: return "May";
	case  6: return "June";
	case  7: return "July";
	case  8: return "August";
	case  9: return "September";
	case 10: return "October";
	case 11: return "November";
	case 12: return "December";
	default: return "Unknown";
	}
}


}

}
