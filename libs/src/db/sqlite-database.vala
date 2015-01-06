namespace DB {


public class SQLiteEngine : Object, Engine {
	public File file { get; construct set; }
	private Sqlite.Database db;


	construct {
		int ret = Sqlite.Database.open_v2 (file.get_path (), out db);
		if (ret != Sqlite.OK)
			error ("Error opening the database at '%s': (%d) %s",
					file.get_path (), db.errcode (), db.errmsg ());
	}


	public SQLiteEngine (File _file) {
		Object (file: _file);
	}


	public void exec_sql (string sql, Sqlite.Callback? callback = null) {
		debug (sql);
		string errmsg;
		if (db.exec (sql, callback, out errmsg) != Sqlite.OK)
			error ("Error executing SQL statement: %s\n", errmsg);
	}


	public int64 last_insert_rowid () {
		return db.last_insert_rowid ();
	}


	public string? escape_string (string? s) {
		if (s == null)
			return null;
		return s.replace ("'", "''");		
	}
}


}
