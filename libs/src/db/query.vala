namespace DB {


[Compact]
public class Query {
	public StringBuilder sb;
	public bool have_where;
	public bool have_on;


	public Query.select (string? expr = null) {
		sb = new StringBuilder.sized (64);
		sb.append_printf ("SELECT %s", expr ?? "*");
	}


	public Query.delete (string table) {
		sb = new StringBuilder.sized (64);
		sb.append_printf ("DELETE FROM %s", table);
	}


	public string sql () {
		return sb.str;
	}


	public unowned Query from (string expr) {
		sb.append_printf (" FROM %s", expr);
		return this;
	}


	public unowned Query join (string expr) {
		sb.append_printf (" JOIN %s", expr);
		have_on = false;
		return this;
	}


	public unowned Query on (string expr) {
		if (have_on)
			sb.append_printf (" AND (%s)", expr);
		else
			sb.append_printf (" ON (%s)", expr);
		have_on = true;
		return this;
	}


	public unowned Query where (string expr) {
		if (have_where)
			sb.append_printf (" AND (%s)", expr);
		else
			sb.append_printf (" WHERE (%s)", expr);
		have_where = true;
		return this;
	}


	public unowned Query order_by (string column) {
		sb.append_printf (" ORDER BY %s", column);
		return this;
	}


	public unowned Query limit (int limit) {
		sb.append_printf (" LIMIT %d", limit);
		return this;
	}


	public static Query entity_list (Database db, Type type) {
		var table_name = db.find_entity_spec (type).table_name;
		var q = new Query.select ();
		q.from (table_name);
		return q;
	}
}


}
