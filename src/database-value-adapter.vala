namespace Kv {


public class DatabaseValueAdapter : DB.ValueAdapter {
	public DatabaseValueAdapter () {
		base ();

		register_adapter (typeof (Month), null, string_to_month);
	}


	private bool string_to_month (string? s, ref Value v) {
		if (unlikely (s == null)) {
			v.set_pointer (null);
			return true;
		}

		uint64 result;
		if (!uint64.try_parse (s, out result))
			return false;

		var month = new Month.from_raw_value ((uint) result);
		v.set_instance (month);
		return true;
	}
}


}
