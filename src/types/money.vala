namespace Kv {


public class Money : FixedPoint {
	public Money.from_raw_integer (int64 _raw_integer) {
		base.from_raw_integer (_raw_integer, 3);
	}


	public Money.parse (string in_str) {
	}


	public string format () {
		var x = Utils.pow_integer (10, precision);
		var sb = new StringBuilder ();

		if (integer < 0)
			sb.append_c ('-');

		var v = integer.abs ();
		var p0 = (v / x);
		var p1 = (v % x).abs ();
		sb.append_printf ("%" + int64.FORMAT + ",%03" + int64.FORMAT, p0, p1);
		return sb.str;
	}
}


}
