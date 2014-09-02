namespace Kv {


[Compact]
public struct Period {
	uint16 year;
	uint8 month;
}


public class Application : Gtk.Application
{
	public Database db;


	public Application() {
		Object (application_id: "org.lxndr.kvartplata",
			flags: ApplicationFlags.FLAGS_NONE);
	}


	public override void startup () {
		base.startup ();

		try {
			db = new Database ();
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

/*
	public Account add_account () {
		var account = new Account ();
		exec_sql ("INSERT INTO account VALUES (NULL, '000', '000')");
		account.id = db.last_insert_rowid ();
		stdout.printf ("New ID: %lld\n", account.id);
		return account;
	}
*/
}


}
