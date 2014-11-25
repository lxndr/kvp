namespace Kv {


public class FixedPoint {
	public int64 integer;
	protected int8 precision;


	public FixedPoint.from_raw_integer (int64 _integer, int8 _precision) {
		integer = _integer;
		precision = _precision;
	}


	public FixedPoint.parse (string in_str) {
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
		if (p2.length < precision) {
			var sb = new StringBuilder (p2);
			while (sb.len < precision)
				sb.append_c ('0');
			p2 = sb.str;
		} else {
			p2 = p2[0:3];
		}

		p1 = Utils.string_remove_leading (p1 + p2, '0');
		integer = int64.parse (p1);
		if (negative)
			integer = -integer;
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


	public double to_real () {
		var x = Utils.pow_integer (10, precision);
		return (double) integer / (double) x;
	}


	public unowned FixedPoint assign (FixedPoint that) {
		integer = that.integer;
		precision = that.precision;
		return this;
	}


	public unowned FixedPoint add (FixedPoint that)
			requires (precision == that.precision) {
		integer += that.integer;
		return this;
	}


	public unowned FixedPoint sub (FixedPoint that)
			requires (precision == that.precision) {
		integer -= that.integer;
		return this;
	}


/*
	public unowned FixedPoint mul (FixedPoint that)
			requires (precision == that.precision) {
		integer *= that.integer;
		return this;
	}
*/


	public unowned FixedPoint mul_float (double that) {
		integer = Math.llround (that * (double) integer);
		return this;
	}
}


}
