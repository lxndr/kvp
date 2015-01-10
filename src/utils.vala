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


public string format_date (GLib.Date date) {
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


/*
 * Adapter <-> Date
 */
public void transform_date_to_property_adapter (Value src_value, ref Value dest_value) {
	DB.PropertyAdapter ad = { null };
	var date = (Date) src_value.peek_pointer ();
	if (date != null)
		ad.val = date.format ();
	dest_value.set_boxed (&ad);
}


public void transform_property_adapter_to_date (Value src_value, ref Value dest_value) {
	var ad = (DB.PropertyAdapter*) src_value.get_boxed ();

	var date = Date.parse (ad.val);
	if (date != null)
		dest_value.set_instance (date);
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
	var m = (Money*) src_value.peek_pointer ();
	if (m == null)
		m = new Money ();
	DB.PropertyAdapter ad = { m->format () };
	dest_value.set_boxed (&ad);
}

public void transform_property_adapter_to_money (Value src_value, ref Value dest_value) {
	var ad = (DB.PropertyAdapter*) src_value.get_boxed ();
	var m = new Money.parse (ad.val);
	dest_value.set_instance (m);
}


private string shorten_person_name (string? name, bool dots) {
	var sb = new StringBuilder ();

	var parts = name.split (" ");
	foreach (unowned string part in parts) {
		/* skip empty */
		if (part.length == 0)
			continue;

		/* last name */
		if (sb.len == 0 || part[0] == '(') {
			var tmp = part.replace ("_", " ");
			sb.append (tmp);
			sb.append_c (' ');
		} else {
			sb.append_unichar (part.get_char (0));
			if (dots)
				sb.append_unichar ('.');
		}
	}

	return sb.str;
}


public uint get_month_first_day (int month) {
	var date = GLib.Date ();
	date.set_dmy ((DateDay) 1, (month % 12) + 1, (DateYear) month / 12);
	return date.get_julian ();
}


public uint get_month_last_day (int month) {
	month++;
	var date = GLib.Date ();
	date.set_dmy ((DateDay) 1, (month % 12) + 1, (DateYear) month / 12);
	return date.get_julian () - 1;
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


public bool is_day_in_period (uint day, uint first_day, uint last_day) {
	return true;
}


/*
 * Julian days
 * 1 = none
 * first =1, last =1 - no range
 * first >1, last =1 - no last day
 * first =1, last >1 - no first day
 * first >1, last >1 - actually a range
 */
public void clamp_date_range (ref uint first_day, ref uint last_day, uint min, uint max)
		requires (first_day != 1 || last_day != 1 || first_day <= last_day)
		requires (max == 1 || min <= max)
		ensures (first_day <= last_day) {
	if (first_day == 1 && last_day == 1)
		return;

	if (min > 1) {
		if (last_day > 1 && last_day < min) {
			first_day = 1;
			last_day = 1;
		}

		if (first_day == 1 || first_day < min)
			first_day = min;
	}

	if (max > 1) {
		if (first_day > 1 && first_day > max) {
			first_day = 1;
			last_day = 1;
		}

		if (last_day == 1 || last_day > max)
			last_day = max;
	}
}


public void default_popup_menu_position (Gtk.Widget widget, out int x, out int y, out bool push_in) {
	Gtk.Allocation alloc;
	widget.get_toplevel ().get_window ().get_origin (out x, out y);
	widget.get_allocation (out alloc);
	x += alloc.x;
	y += alloc.y;
	y += alloc.height;
	push_in = false;
}


}

}
