namespace DB {


public delegate bool ValueAdapterFromFunc (string? s, ref Value v);
public delegate bool ValueAdapterToFunc (ref Value v, out string? s);


private struct Adapter {
	Type type;
	string? table;
	string? column;
	unowned ValueAdapterFromFunc from_func;
	unowned ValueAdapterToFunc to_func;
}


public class ValueAdapter {
	private Gee.List<Adapter?> adapters;


	public ValueAdapter () {
		adapters = new Gee.ArrayList<Adapter?> ();
	}


	public void register (Type type, string? column, ValueAdapterFromFunc? from_fn, ValueAdapterToFunc? to_fn)
			requires (type != Type.INVALID || column != null) {
		adapters.add ({type, null, column, from_fn, to_fn});
	}


	private Adapter? find_spec (Type type, string? table, string? column) {
		foreach (var adapter in adapters)
			if (adapter.from_func != null &&
					(adapter.type == Type.INVALID || adapter.type == type) &&
					(adapter.table == null || adapter.table == table) &&
					(adapter.column == null || adapter.column == column))
				return adapter;
		return null;
	}


	private ValueAdapterToFunc? find_to_func (Type type, string? table, string? column) {
		foreach (var adapter in adapters)
			if (adapter.to_func != null &&
					(adapter.type == Type.INVALID || adapter.type == type) &&
					(adapter.table == null || adapter.table == table) &&
					(adapter.column == null || adapter.column == column))
				return adapter.to_func;
		return null;
	}


	public bool convert_from (string? table, string? column, string? s, ref Value v) {
		var spec = find_spec (v.type (), table, column);
		if (unlikely (spec == null))
			return false;
		return spec.from_func (s, ref v);
	}


	public bool convert_to (string? table, string? column, ref Value v, out string? s) {
		var spec = find_spec (v.type (), table, column);
		if (unlikely (spec == null))
			return false;
		return spec.to_func (ref v, out s);
	}
}


}
