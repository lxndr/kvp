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


	public Account add_account () {
		db.exec("INSERT INTO lodging VALUES(NULL, )");
	}
}


}
