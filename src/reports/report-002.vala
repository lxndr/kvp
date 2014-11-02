namespace Kv {


[GtkTemplate (ui = "/org/lxndr/kvp/ui/account-report-parameters.ui")]
private class AccountReportParameters : Gtk.Dialog {
	[GtkChild]
	private Gtk.Button from_button;
	[GtkChild]
	private Gtk.Button to_button;

	private MonthPopover from_year_month;
	private MonthPopover to_year_month;


	construct {
		var now = new Month.now ();

		from_button.always_show_image = true;
		from_button.image = new Gtk.Image.from_icon_name ("x-office-calendar", Gtk.IconSize.BUTTON);

		from_year_month = new MonthPopover (from_button);
		from_year_month.month = now.get_first_month ();
		from_year_month_closed ();
		from_year_month.closed.connect (from_year_month_closed);

		to_button.always_show_image = true;
		to_button.image = new Gtk.Image.from_icon_name ("x-office-calendar", Gtk.IconSize.BUTTON);

		to_year_month = new MonthPopover (to_button);
		to_year_month.month = now.get_last_month ();
		to_year_month_closed ();
		to_year_month.closed.connect (to_year_month_closed);
	}


	public AccountReportParameters (Gtk.Window _parent) {
		Object (transient_for: _parent);
	}


	[GtkCallback]
	private void from_button_clicked () {
		from_year_month.show ();
	}


	private void from_year_month_closed () {
		from_button.label = from_year_month.month.format ();
	}


	[GtkCallback]
	private void to_button_clicked () {
		to_year_month.show ();
	}


	private void to_year_month_closed () {
		to_button.label = to_year_month.month.format ();
	}


	public int start_month () {
		return (int) from_year_month.month;
	}

	public int end_month () {
		return (int) to_year_month.month;
	}
}



public class Report002 : Report {
	private const int service_ids[] = { 5, 6, 1, 2, 7, 8, 4, 9 };

	private OOXML.Spreadsheet book;
	private int start_period;
	private int end_period;

	private Gee.List<AccountPeriod> periodic_list;
	private AccountPeriod general_periodic;
	private Gee.List<Tenant> tenants;
	private Tenant main_tenant;


	construct {
		book = new OOXML.Spreadsheet ();
	}


	public override bool prepare () {
		var dlg = new AccountReportParameters (toplevel_window);
		var ret = dlg.run ();
		if (ret == Gtk.ResponseType.ACCEPT) {
			start_period = dlg.start_month ();
			end_period = dlg.end_month ();
		}
		dlg.destroy ();

		return ret == Gtk.ResponseType.ACCEPT;
	}


	private string process_pattern (string tmpl) throws Error {
		var re = new Regex ("{(.+?)}");
		return re.replace_eval (tmpl, -1, 0, 0, (match_info, result) => {
			switch (match_info.fetch (1)) {
			case "ACCOUNT_NUMBER":
				result.append (selected_account.account.number);
				break;
			case "ACCOUNT_TENANT":
				result.append (main_tenant.name);
				break;
			case "ACCOUNT_ROOM":
				result.append (selected_account.apartment);
				break;
			case "ACCOUNT_NPEOPLE":
				result.append (tenants.size.to_string ());
				break;
			case "ACCOUNT_NROOMS":
				result.append (selected_account.n_rooms.to_string ());
				break;
			case "ACCOUNT_AREA":
				result.append (Utils.format_double (selected_account.area, 2));
				break;
			case "BUILDING_LOCATION":
				result.append (selected_account.account.building.location);
				break;
			case "BUILDING_STREET":
				result.append (selected_account.account.building.street);
				break;
			case "BUILDING_NUMBER":
				result.append (selected_account.account.building.number);
				break;
			default:
				result.append_printf ("{%s}", match_info.fetch (1));
				break;
			}

			return false;
		});
	}


	public override void make () throws Error {
		book.load (GLib.File.new_for_path ("./templates/account.xlsx"));

		periodic_list = db.get_account_periods (selected_account.account, start_period, end_period);
		if (periodic_list.size == 0)
			error ("There's no periods!");

		general_periodic = periodic_list.last ();
		tenants = general_periodic.get_tenant_list ();

		foreach (var tenant in tenants) {
			unowned Relationship? rel = tenant.relation;
			if (rel != null && rel.id == 1)
				main_tenant = tenant;
		}

		if (main_tenant == null)
			error ("This account does not have a main tenant");

		make_page1 (book.sheet (0));
		make_page2 (book.sheet (1));
		make_page3 (book.sheet (2));
	}


	private void make_page1 (OOXML.Sheet sheet) throws Error {
		var cell = sheet.get_cell("A3");
		unowned OOXML.SimpleTextValue val = cell.val as OOXML.SimpleTextValue;
		var str = val.text;
		str = process_pattern (str);
		val.text = str;
	}


	private void make_page2 (OOXML.Sheet sheet) {
		unowned Building building = selected_account.account.building;
		var n_tenants = tenants.size;

		sheet.put_string ("BZ1", selected_account.account.number);
		sheet.put_string ("R3", main_tenant.name);
		sheet.put_string ("K4", building.street);
		sheet.put_string ("AK4", building.number);
		sheet.put_string ("T12", general_periodic.n_rooms.to_string ());
		sheet.put_string ("AD12", Utils.format_double (general_periodic.area, 2));
		sheet.put_string ("AZ8", n_tenants.to_string ());
		sheet.put_string ("BF8", n_tenants.to_string ());
		sheet.put_string ("CA4", general_periodic.apartment);

		/* services and prices */
		var sb = new StringBuilder ();
		var price_list = db.get_price_list (building, general_periodic.period);
		foreach (var price in price_list)
			sb.append_printf ("%s: %s\n", price.service.name, price.value.format ());
		sheet.put_string ("A7", sb.str);

		/* tenants */
		for (var i = 0; i < n_tenants; i++) {
			var tenant = tenants[i];
			unowned Person person = tenant.person;
			sheet.get_row (14 + i).get_cell (27).put_string (person.name);
			sheet.get_row (14 + i).get_cell (49).put_string (Utils.format_date (person.birthday));
			if (tenant.relation != null)
				sheet.get_row (14 + i).get_cell (57).put_string (tenant.relation.name);
		}
	}


	private void make_page3 (OOXML.Sheet sheet) {
		/* base information */
		sheet.put_string ("C1", main_tenant.name);
		sheet.put_string ("L1", selected_account.account.number);

		/* services & taxes */
		int64 totals[11];
		for (var j = 0; j < 11; j++)
			totals[j] = 0;

		int row_number = 5;
		foreach (var periodic in periodic_list) {
			var taxes = db.fetch_int_entity_map<Tax> (Tax.table_name, "service", null,
					"account=%d AND period=%d".printf (periodic.account.id, periodic.period));

			var month = periodic.period % 12;
			var row = sheet.get_row (row_number);
			row.get_cell (2).put_string (Utils.month_to_string (month));

			for (var j = 0; j < 8; j++) {
				var tax = taxes[service_ids[j]];
				if (tax != null) {
					totals[j] += tax.total.val;
					row.get_cell (3 + j).put_number (tax.total.to_real ());
				}
			}

			totals[8] += periodic.total.val;
			row.get_cell (12).put_number (periodic.total.to_real ());
			totals[9] += periodic.payment.val;
			row.get_cell (13).put_number (periodic.payment.to_real ());
			totals[10] = periodic.balance.val;
			row.get_cell (14).put_number (periodic.balance.to_real ());

			row_number++;
		}

		var row = sheet.get_row (17);
		for (var j = 0; j < 8; j++)
			row.get_cell (3 + j).put_number (Money (totals[j]).to_real ());
		row.get_cell (12).put_number (Money (totals[8]).to_real ());
		row.get_cell (13).put_number (Money (totals[9]).to_real ());
		row.get_cell (14).put_number (Money (totals[10]).to_real ());
	}


	public override void write (File f) throws Error {
		book.save_as (f);
	}
}



}
