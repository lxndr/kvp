namespace DB {


public class SQLiteDatabase : Database {
	public File file { get; construct set; }
	private Sqlite.Database db;


	construct {
		int ret = Sqlite.Database.open_v2 (file.get_path (), out db);
		if (ret != Sqlite.OK)
			error ("Error opening the database at '%s': (%d) %s",
					file.get_path (), db.errcode (), db.errmsg ());
	}


	public SQLiteDatabase (File _file) {
		Object (file: _file);
	}


	public override void exec_sql (string sql, Sqlite.Callback? callback = null) {
		string errmsg;
		debug (sql);
		if (db.exec (sql, callback, out errmsg) != Sqlite.OK)
			error ("Error executing SQL statement: %s\n", errmsg);
	}


	public override int last_insert_rowid () {
		return (int) db.last_insert_rowid ();
	}
}


}
