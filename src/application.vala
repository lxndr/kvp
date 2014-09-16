namespace Kv {


[Compact]
public struct Period {
	public int year;
	public int month;


	public Period prev () {
		Period p = this;
		if (p.month == 1) {
			p.year--;
			p.month = 12;
		} else {
			p.month--;
		}

		return p;
	}


	public Period next () {
		Period p = this;
		if (p.month == 12) {
			p.year++;
			p.month = 1;
		} else {
			p.month++;
		}

		return p;
	}
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

		Value.register_transform_func (typeof (string), typeof (Money),
				(ValueTransform) Utils.transform_string_to_money);
		Value.register_transform_func (typeof (Money), typeof (string),
				(ValueTransform) Utils.transform_money_to_string);

		Value.register_transform_func (typeof (double), typeof (DB.PropertyAdapter),
				(ValueTransform) Utils.transform_double_to_property_adapter);
		Value.register_transform_func (typeof (DB.PropertyAdapter), typeof (double),
				(ValueTransform) Utils.transform_property_adapter_to_double);
		Value.register_transform_func (typeof (Money), typeof (DB.PropertyAdapter),
				(ValueTransform) Utils.transform_money_to_property_adapter);
		Value.register_transform_func (typeof (DB.PropertyAdapter), typeof (Money),
				(ValueTransform) Utils.transform_property_adapter_to_money);
	}


	public override void startup () {
		base.startup ();

		/* reports */
		reports = new Gee.HashMap<string, Type> ();
		reports.set ("List of the tenants", typeof (Report001));
		reports.set ("Account", typeof (Report002));

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
