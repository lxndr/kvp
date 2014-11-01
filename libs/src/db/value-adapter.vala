namespace DB {


public delegate bool ValueAdapterFunc (string? s, ref Value v);


private struct Adapter {
	Type type;
	string? table;
	string? column;
	unowned ValueAdapterFunc func;
}


public class ValueAdapter {
	private Gee.List<Adapter?> adapters;


	public ValueAdapter () {
		adapters = new Gee.ArrayList<Adapter?> ();
	}


	public void register_adapter (Type type, string? column, ValueAdapterFunc func)
			requires (type != Type.INVALID || column != null) {
		adapters.add ({type, null, column, func});
	}


	private ValueAdapterFunc? find_adapter_func (Type type, string? table, string? column) {
		foreach (var adapter in adapters)
			if ((adapter.type == Type.INVALID || adapter.type == type) &&
					(adapter.table == null || adapter.table == table) &&
					(adapter.column == null || adapter.column == column))
				return adapter.func;
		return null;
	}


	public bool convert_from (string? table, string? column, string s, ref Value v) {
		var func = find_adapter_func (v.type (), table, column);
		if (unlikely (func == null))
			return false;
		return func (s, ref v);
	}
}


}
