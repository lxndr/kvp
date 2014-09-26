namespace DB {


public class SQLiteDatabase : Object, Database {
	public string path { get; construct set; }
	private Sqlite.Database db;


	construct {
		int ret = Sqlite.Database.open_v2 (path, out db);
		if (ret != Sqlite.OK)
			error ("Error opening the database at '%s': (%d) %s",
					path, db.errcode (), db.errmsg ());
	}


	public SQLiteDatabase (string _path) {
		Object (path: _path);
	}


	public void exec_sql (string sql, Sqlite.Callback? callback = null) {
		string errmsg;
// #if 1
		stdout.printf ("%s\n", sql);
// #endif
		if (db.exec (sql, callback, out errmsg) != Sqlite.OK)
			error ("Error executing SQL statement: %s\n", errmsg);
	}


	public int last_insert_rowid () {
		return (int) db.last_insert_rowid ();
	}
}


}
