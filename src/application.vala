namespace Kv {


[Compact]
public struct Period {
	uint16 year;
	uint8 month;
}


public class Application : Gtk.Application
{
	private Sqlite.Database db;


	public Application() {
		Object (application_id: "org.lxndr.kvartplata",
			flags: ApplicationFlags.FLAGS_NONE);
	}


	private void initialize_database () throws Error {
		/* open the database */
		int ret = Sqlite.Database.open_v2 ("./kvartplata.db", out db);
		if (ret != Sqlite.OK) {
			stdout.printf ("Error opening the database: (%d) %s\n",
				db.errcode (), db.errmsg ());
		}
 
		/* prepare the database */
		string errmsg;
		var data = resources_lookup_data ("/data/init.sql", ResourceLookupFlags.NONE).get_data ();
		var query = (string) data;
		ret = db.exec (query, null, out errmsg);
		if (ret != Sqlite.OK) {
			stdout.printf ("Error preparing the database: %s\n",
				errmsg);
		}
	}


	public override void startup () {
		base.startup ();

		try {
			initialize_database ();
		} catch (Error e) {
			stdout.printf ("Error preparing the database: %s\n", e.message);
		}
	}


	public override void activate () {
		var win = new MainWindow (this);
		win.show ();
	}


	public static int main (string[] args) {
		Application app = new Application ();
		return app.run (args);
	}


	private void exec_sql (string sql, Sqlite.Callback? callback = null) {
		string errmsg;
		stdout.printf ("%s\n", sql);
		if (db.exec (sql, callback, out errmsg) != Sqlite.OK)
			stdout.printf ("Sqlite error: %s\n", errmsg);
	}


	public Account add_account () {
		var account = new Account ();
		exec_sql ("INSERT INTO account VALUES (NULL, '000', '000')");
		account.id = db.last_insert_rowid ();
		stdout.printf ("New ID: %lld\n", account.id);
		return account;
	}


	public Gee.List<Account> get_account_list () {
		var list = new Gee.ArrayList<Account> ();

		exec_sql ("SELECT * FROM account", (n_columns, values, column_names) => {
			var account = new Account ();
			account.number = values[1];
			account.apartment = values[2];
			list.add (account);
			return 0;
		});

		return list;
	}


	public void update_account (Account account) {
		exec_sql ("UPDATE account SET number='" + account.number + "', apartment='" + account.apartment + "'");
	}


	public Gee.List<Person> get_people_list () {
		var list = new Gee.ArrayList<Person> ();

		exec_sql ("SELECT * FROM people", (n_columns, values, column_names) => {
			var person = new Person ();
			person.name = values[1];
			person.birthday = values[2];
			list.add (person);
			return 0;
		});

		return list;
	}
}


}
