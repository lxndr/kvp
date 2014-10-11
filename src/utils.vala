namespace Kv {

namespace Utils {


private string string_remove_leading (string in_str, char unneeded_ch) {
	var len = in_str.length;
	var i = 0;

	for (i = 0; i < len; i++)
		if (in_str[i] != '0')
			break;

	return in_str[i:len];
}


public string string_remove_trailing (string in_str, char unneeded_ch) {
	int p;

	for (p = in_str.length - 1; p >= 0; p--) {
		var ch = in_str[p];
		if (ch != unneeded_ch)
			break;
	}

	return in_str[0:p];
}


public int pow_integer (int number, int pow) {
	var result = 1;
	for (var i = 0; i < pow; i++)
		result *= number;
	return result;
}



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


public string format_date (Date date) {
	char s[16];
	date.strftime (s, "%x");
	return (string) s;
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


public void transform_string_to_bool (Value src_value, ref Value dest_value) {
	unowned string s = src_value.get_string ();
	dest_value.set_boolean (int64.parse (s) > 0);
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


public void transform_string_to_date (Value src_value, ref Value dest_value) {
	var n = (uint) uint64.parse (src_value.get_string ());
	var date = Date ();
	date.set_julian (n);
	dest_value.set_boxed (&date);
}

public void transform_date_to_string (Value src_value, ref Value dest_value) {
	var date = (Date*) src_value.get_boxed ();
	dest_value.set_string (date.get_julian ().to_string ());
}


/*
 * Adapter <-> Date
 */
public void transform_date_to_property_adapter (Value src_value, ref Value dest_value) {
	DB.PropertyAdapter ad = { null };

	var date = (Date*) src_value.get_boxed ();
	if (date.valid () == true && date.get_julian () > 1) {
		char buf[32];
		date.strftime (buf, "%x");
		ad.val = (string) buf;
	}

	dest_value.set_boxed (&ad);
}

public void transform_property_adapter_to_date (Value src_value, ref Value dest_value) {
	var ad = (DB.PropertyAdapter*) src_value.get_boxed ();
	var date = Date ();
	date.set_parse (ad.val);
	dest_value.set_boxed (&date);
}


/*
 * Adapter <-> double
 */
public void transform_double_to_property_adapter (Value src_value, ref Value dest_value) {
	double d = src_value.get_double ();
	DB.PropertyAdapter ad = { format_double (d, 2) };
	dest_value.set_boxed (&ad);
}

public void transform_property_adapter_to_double (Value src_value, ref Value dest_value) {
	var ad = (DB.PropertyAdapter*) src_value.get_boxed ();
	dest_value.set_double (double.parse (ad.val));
}


/*
 * Adapter <-> Money
 */
public void transform_money_to_property_adapter (Value src_value, ref Value dest_value) {
	Money* m = (Money*) src_value.get_boxed ();
	DB.PropertyAdapter ad = { m->format () };
	dest_value.set_boxed (&ad);
}

public void transform_property_adapter_to_money (Value src_value, ref Value dest_value) {
	var ad = (DB.PropertyAdapter*) src_value.get_boxed ();
	var m = Money.from_formatted (ad.val);
	dest_value.set_boxed (&m);
}



private string shorten_name (string? name) {
	if (name == null)
		return "";

	var sb = new StringBuilder.sized (16);
	var index = name.index_of_char (' ');
	if (index == -1)
		return name;
	sb.append_len (name, index);
	index++;

	unichar ch;
	if (name.get_next_char (ref index, out ch) == false)
		return sb.str;
	sb.append_unichar (' ');
	sb.append_unichar (ch);
	sb.append_unichar ('.');

	index = name.index_of_char (' ', index);
	if (index == -1)
		return sb.str;
	index++;

	if (name.get_next_char (ref index, out ch) == false)
		return sb.str;
	sb.append_unichar (ch);
	sb.append_unichar ('.');
	return sb.str;
}



public string month_to_string (int month) {
	string[] months = {
		_("January"),
		_("February"),
		_("March"),
		_("April"),
		_("May"),
		_("June"),
		_("July"),
		_("August"),
		_("September"),
		_("October"),
		_("November"),
		_("December")
	};

	return months[month];
}


}

}
