namespace Kv {


public class Application : Gtk.Application
{
	public Gee.Map<string, Type> reports;
	public Database db;


	public Application() {
		Object (application_id: "org.lxndr.kvp",
			flags: ApplicationFlags.FLAGS_NONE);

		Value.register_transform_func (typeof (string), typeof (int),
				(ValueTransform) Utils.transform_string_to_int);
		Value.register_transform_func (typeof (string), typeof (int64),
				(ValueTransform) Utils.transform_string_to_int64);
		Value.register_transform_func (typeof (string), typeof (double),
				(ValueTransform) Utils.transform_string_to_double);
		Value.register_transform_func (typeof (string), typeof (bool),
				(ValueTransform) Utils.transform_string_to_bool);

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
		reports.set (_("List of the tenants"), typeof (Report001));
		reports.set (_("Account"), typeof (Report002));
		reports.set (_("People and taxes"), typeof (Report003));

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
#if KVP_DEBUG
		var root_dir = Path.get_dirname (args[0]);
#else
		var root_dir = Path.get_dirname (Path.get_dirname (args[0]));
#endif
		var locale_path = Path.build_filename (root_dir, "share/locale");

		Intl.bindtextdomain ("kvp", locale_path);
		Intl.bind_textdomain_codeset ("kvp", "UTF-8");
		Intl.textdomain ("kvp");

		Application app = new Application ();
		return app.run (args);
	}
}


}
