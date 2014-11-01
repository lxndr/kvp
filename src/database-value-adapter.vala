namespace Kv {


public class DatabaseValueAdapter : DB.ValueAdapter {
	public DatabaseValueAdapter () {
		base ();

		register_adapter (typeof (Period), null, string_to_period);
	}


	private bool string_to_period (string? s, ref Value v) {
		if (unlikely (s == null)) {
			v.set_pointer (null);
			return true;
		}

		uint64 result;
		if (!uint64.try_parse (s, out result))
			return false;

		var period = new Period.from_ym ((uint) result);
		v.set_instance (period);
		return true;
	}
}


}
