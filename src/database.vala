namespace Kv {


public errordomain DatabaseError {
	OPENING_FAILED,
	EXEC_FAILED
}


public class Database {
	private Sqlite.Database db;

	public Database () throws Error {
		/* open the database */
		int ret = Sqlite.Database.open_v2 ("./kvartplata.db", out db);
		if (ret != Sqlite.OK)
			throw new DatabaseError.OPENING_FAILED (
					"Error opening the database: (%d) %s", db.errcode (), db.errmsg ());

		/* prepare the database */
		var data = resources_lookup_data ("/data/init.sql", ResourceLookupFlags.NONE).get_data ();
		exec_sql ((string) data);
	}


	private void exec_sql (string sql, Sqlite.Callback? callback = null) throws DatabaseError {
		string errmsg;
		stdout.printf ("%s\n", sql);
		if (db.exec (sql, callback, out errmsg) != Sqlite.OK)
			throw new DatabaseError.EXEC_FAILED ("Error executing SQL statement: %s\n", errmsg);
	}


	public Gee.List<Entity> get_account_list () throws DatabaseError {
		return get_entity_list ("SELECT * FROM account", typeof (Account));
	}


	public Gee.List<Entity> get_people_list (Period period, Account account) throws DatabaseError {
		return get_entity_list ("SELECT * FROM people", typeof (Person));
	}


	public Gee.List<Entity> get_tax_list (Period period, Account account) throws DatabaseError {
		return get_entity_list ("SELECT * FROM taxes", typeof (Tax));
	}


	private Gee.List<Entity> get_entity_list (string sql, Type type) throws DatabaseError {
		var list = new Gee.ArrayList<Entity> ();

		exec_sql (sql, (n_columns, values, column_names) => {
			var entity = Object.new (type) as Entity;
			var val = Value (typeof (string));
			for (var i = 0; i < n_columns; i++) {
				val.set_string (values[i]);
				entity.set_property (column_names[i], val);
			}
			list.add (entity);
			return 0;
		});

		return list;
	}
}


}
