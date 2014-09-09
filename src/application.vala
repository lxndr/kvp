namespace Kv {


[Compact]
public struct Period {
	int year;
	int month;
}


public class Application : Gtk.Application
{
	public Database db;


	public Application() {
		Object (application_id: "org.lxndr.kvartplata",
			flags: ApplicationFlags.FLAGS_NONE);

		Value.register_transform_func (typeof (string), typeof (int),
				(ValueTransform) Utils.transform_string_to_int);
		Value.register_transform_func (typeof (string), typeof (int64),
				(ValueTransform) Utils.transform_string_to_int64);
		Value.register_transform_func (typeof (string), typeof (double),
				(ValueTransform) Utils.transform_string_to_double);
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
		try {
			var xlsx = new Spreadsheet.XLSX ();
			xlsx.open (GLib.File.new_for_path ("./templates/report-001.xlsx"));

			var sheet = xlsx.sheet(0);

//			sheet.add_row_after (3);
			sheet.put_text (0, 4, "201-202");
			sheet.put_text (1, 4, "Name");
			sheet.put_text (2, 4, "15.09.1965");
//			sheet.put_number (3, 4, 2);
			sheet.put_text (4, 4, "44,7");

			xlsx.save_as (GLib.File.new_for_path ("./output/test1.xlsx"));
		} catch (Error e) {
			error (e.message);
		}

return 1;

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
