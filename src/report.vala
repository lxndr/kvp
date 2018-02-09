namespace Kv {


public abstract class Report : Object {
	public MainWindow toplevel_window { get; construct set; }
	public Building? building { get; construct set; }
	public AccountPeriod selected_account { get; construct set; }

	public Database db {
		get {
			return (Database) selected_account.db;
		}
	}

	public Application application {
		get {
			return (Application) ((Gtk.ApplicationWindow) toplevel_window).application;
		}
	}


	public abstract bool prepare () throws Error;
	public abstract void make () throws Error;
	public abstract void show () throws Error;


	protected string? template_text (string? tmpl) {
		if (tmpl == null)
			return null;

		var building = selected_account.account.building;
		var account = selected_account.account;

		try {
			var re = new Regex ("{(.+?)}");
			return re.replace_eval (tmpl, -1, 0, 0, (match_info, result) => {
				switch (match_info.fetch (1)) {
				/* building */
				case "BUILDING_LOCATION":
					result.append (building.location);
					break;
				case "BUILDING_STREET":
					result.append (building.street);
					break;
				case "BUILDING_NUMBER":
					result.append (building.number);
					break;
				case "BUILDING_COMMENT":
					result.append (building.comment);
					break;
				/* period */
				case "PERIOD_YEAR":
					result.append (selected_account.period.year.to_string ());
					break;
				case "PERIOD_MONTH":
					result.append (selected_account.period.month_name ());
					break;
				/* account */
				case "ACCOUNT_NUMBER":
					result.append (account.number);
					break;
				case "ACCOUNT_APARTMENT":
					result.append (selected_account.apartment);
					break;
				case "ACCOUNT_NROOMS":
					result.append (selected_account.n_rooms.to_string ());
					break;
				case "ACCOUNT_NPEOPLE":
					result.append (selected_account.n_people.to_string ());
					break;
				case "ACCOUNT_AREA":
					result.append (Utils.format_double (selected_account.area, 2));
					break;
				case "ACCOUNT_COMMENT":
					result.append (account.comment);
					break;
				case "ACCOUNT_MAIN_TENANTS":
					result.append (selected_account.main_tenants_names());
					break;
				/* organization */
				case "ORGANIZATION_NAME":
					result.append (toplevel_window.org_info.name);
					break;
				case "ORGANIZATION_SHORT_NAME":
					result.append (toplevel_window.org_info.short_name);
					break;
				default:
					result.append_printf ("{%s}", match_info.fetch (1));
					break;
				}

				return false;
			});
		} catch (Error e) {
			error ("Failed to create a regular expression: %s", e.message);
		}
	}
}


}
