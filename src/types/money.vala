namespace Kv {


/*
 * Money. This is basically a fixed point value
 */

const int money_precision = 3;


[Compact]
public struct Money {
	public int64 val;


	public Money (int64 _val) {
		val = _val;
	}


	/* Removes all except a minus, a decimal point and digits. */
	private string clean (string in_str) {
		bool minus = false;
		bool point = false;
		var sb = new StringBuilder ();
		var len = in_str.length;

		for (var i = 0; i < len; i++) {
			var ch = in_str[i];

			if (likely (ch >= '0' && ch <= '9')) {
				sb.append_c (ch);
			} else if (ch == '-' && minus == false) {
				sb.append_c (ch);
				minus = true;
			} else if (point == false && (ch == '.' || ch == ',' || ch == '/')) {
				sb.append_c ('.');
				point = true;
			}
		}

		return sb.str;
	}


	public Money.from_formatted (string in_str) {
		var clean_str = clean (in_str);

		/* if the value is negative */
		bool negative = false;

		if (clean_str[0] == '-') {
			negative = true;
			clean_str = clean_str[1:clean_str.length];
		}

		/* split */
		string p1;
		string p2;

		var p = clean_str.index_of_char ('.');
		if (p == -1) {
			p1 = clean_str;
			p2 = "";
		} else {
			p1 = clean_str[0:p];
			p2 = clean_str[p+1:clean_str.length];
		}

		/* prepare */
		if (p2.length < money_precision) {
			var sb = new StringBuilder (p2);
			while (sb.len < money_precision)
				sb.append_c ('0');
			p2 = sb.str;
		} else {
			p2 = p2[0:3];
		}

		p1 = Utils.string_remove_leading (p1 + p2, '0');
		val = int64.parse (p1);
		if (negative)
			val = -val;
	}


	public string format () {
		var x = Utils.pow_integer (10, 3);
		var sb = new StringBuilder ();

		if (val < 0)
			sb.append_c ('-');

		var v = val.abs ();
		var p0 = (v / x);
		var p1 = (v % x).abs ();
		sb.append_printf ("%" + int64.FORMAT + ",%03" + int64.FORMAT, p0, p1);
		return sb.str;
	}


	public double to_real () {
		var x = Utils.pow_integer (10, 3);
		return (double) val / (double) x;
	}
}


}
