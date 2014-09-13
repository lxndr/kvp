namespace Kv {


[Compact]
public struct Period {
	public int year;
	public int month;
}


public class Application : Gtk.Application
{
	public Gee.Map<string, Type> reports;
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

		/* reports */
		reports = new Gee.HashMap<string, Type> ();
		reports.set ("List of the tenants", typeof (Report001));

		/* database */
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
}


}
