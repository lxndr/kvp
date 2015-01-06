namespace DB {

public interface Engine : Object {
	public abstract void exec_sql (string sql, Sqlite.Callback? callback = null);
	public abstract int64 last_insert_rowid ();
	public abstract string? escape_string (string? s);
}

}
