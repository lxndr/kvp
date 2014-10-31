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
		Value.register_transform_func (typeof (string), typeof (Date),
				(ValueTransform) Utils.transform_string_to_date);
		Value.register_transform_func (typeof (Date), typeof (string),
				(ValueTransform) Utils.transform_date_to_string);

		Value.register_transform_func (typeof (double), typeof (DB.PropertyAdapter),
				(ValueTransform) Utils.transform_double_to_property_adapter);
		Value.register_transform_func (typeof (DB.PropertyAdapter), typeof (double),
				(ValueTransform) Utils.transform_property_adapter_to_double);
		Value.register_transform_func (typeof (Money), typeof (DB.PropertyAdapter),
				(ValueTransform) Utils.transform_money_to_property_adapter);
		Value.register_transform_func (typeof (DB.PropertyAdapter), typeof (Money),
				(ValueTransform) Utils.transform_property_adapter_to_money);

		Value.register_transform_func (typeof (Date), typeof (DB.PropertyAdapter),
				(ValueTransform) Utils.transform_date_to_property_adapter);
		Value.register_transform_func (typeof (DB.PropertyAdapter), typeof (Date),
				(ValueTransform) Utils.transform_property_adapter_to_date);
	}


	public override void startup () {
		base.startup ();

		try {
			var screen = Gdk.Screen.get_default ();
			var provider = new Gtk.CssProvider ();
			provider.load_from_file (File.new_for_path ("./style.css"));
			Gtk.StyleContext.add_provider_for_screen (screen, provider, 600);
		} catch (Error e) {
			error ("Failed to load custom styles: %s", e.message);
		}

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
}


public int start (string[] args) {
	var exe_file = File.new_for_commandline_arg (args[0]);

#if DEBUG
	var root_dir = exe_file.get_parent ();
#else
	var root_dir = exe_file.get_parent ().get_parent ();
#endif
	var locale_path = root_dir.get_child ("share").get_child ("locale");

	Intl.bindtextdomain ("kvp", locale_path.get_path ());
	Intl.bind_textdomain_codeset ("kvp", "UTF-8");
	Intl.textdomain ("kvp");

	Application app = new Application ();
	return app.run (args);
}


}
