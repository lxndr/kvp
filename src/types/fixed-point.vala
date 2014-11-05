namespace Kv {


public class FixedPoint {
	private int64 integer;
	private int8 precision;


	public FixedPoint (int64 _integer, int8 _precision) {
		integer = _integer;
		precision = _precision;
	}


	public unowned FixedPoint assign (FixedPoint that) {
		integer = that.integer;
		precision = that.precision;
		return this;
	}


	public FixedPoint sum (FixedPoint that)
			requires (precision == that.precision) {
		return new FixedPoint (integer + that.integer, precision);
	}


	public unowned FixedPoint assign_sum (FixedPoint that)
			requires (precision == that.precision) {
		integer += that.integer;
		return this;
	}
}


}
