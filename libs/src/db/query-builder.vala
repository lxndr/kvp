namespace DB {


[Compact]
public class QueryBuilder {
	public StringBuilder sb;


	public QueryBuilder () {
		sb = new StringBuilder ();
	}


	public string get_query () {
		return sb.str;
	}


	public unowned QueryBuilder select (string? columns = null) {
		if (columns == null)
			sb.append ("SELECT *");
		else
			sb.printf ("SELECT %s", columns);
		return this;
	}


	public unowned QueryBuilder from (string table) {
		sb.append_printf (" FROM %s", table);
		return this;
	}


	public unowned QueryBuilder join (string table) {
		sb.append_printf (" JOIN %s", table);
		return this;
	}


	public unowned QueryBuilder on (string cond) {
		sb.append_printf (" ON %s", cond);
		return this;
	}


	public unowned QueryBuilder where (string cond) {
		sb.append_printf (" WHERE %s", cond);
		return this;
	}
}


}
