namespace Kv {

namespace Utils {


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
