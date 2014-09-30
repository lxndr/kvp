namespace Kv {


[GtkTemplate (ui = "/ui/account-report-parameters.ui")]
private class AccountReportParameters : Gtk.Dialog {
	[GtkChild]
	private Gtk.Button from_button;
	[GtkChild]
	private Gtk.Button to_button;

	private YearMonth from_year_month;
	private YearMonth to_year_month;


	construct {
		from_year_month = new YearMonth (from_button);
		to_year_month = new YearMonth (to_button);
	}


	public AccountReportParameters (Gtk.Window _parent) {
		Object (transient_for: _parent);
	}


	[GtkCallback]
	private void from_button_clicked () {
		from_year_month.show ();
	}


	[GtkCallback]
	private void to_button_clicked () {
		to_year_month.show ();
	}


	public int start_month () {
		return from_year_month.period;
	}

	public int end_month () {
		return to_year_month.period;
	}
}



public class Report002 : Report {
	const int service_ids[] = {
		5, 6, 1, 2, 7, 8, 4, 9
	};


	private OOXML.Spreadsheet book;


	construct {
		book = new OOXML.Spreadsheet ();
	}


	public override bool prepare () {
		var dlg = new AccountReportParameters (toplevel_window);
		var ret = dlg.run ();
		if (ret == Gtk.ResponseType.ACCEPT) {
			
		}
		dlg.destroy ();

		return ret == Gtk.ResponseType.ACCEPT;
	}


	public override void make () throws Error {
		book.load (GLib.File.new_for_path ("./templates/account.xlsx"));

		var period = periodic.period;
		var account = periodic.account;
		var year = period / 12;
		var account_periods = db.get_account_periods (account, year * 12, year * 12 + 11);
		var last_account_period = account_periods[account_periods.size - 1];
		var people = last_account_period.get_people ();

		var account_number = last_account_period.account.number;
		var account_tenant = last_account_period.tenant_name ();

		make_page1 (book.sheet (0), last_account_period, account_number, account_tenant, people);
		make_page2 (book.sheet (1), account_number, account_tenant, account_periods);
	}


	private void make_page1 (OOXML.Sheet sheet, AccountPeriod account_period,
			string account_number, string account_tenant, Gee.List<Person> people) {
		var n_people = people.size;

		sheet.put_string ("BZ1", account_number);
		sheet.put_string ("R3", account_tenant);
		sheet.put_string ("K4", account_period.account.building.street);
		sheet.put_string ("AK4", account_period.account.building.number);
		sheet.put_string ("T12", account_period.n_rooms.to_string ());
		sheet.put_string ("AD12", Utils.format_double (account_period.area, 2));
		sheet.put_string ("AZ8", n_people.to_string ());
		sheet.put_string ("BF8", n_people.to_string ());
		sheet.put_string ("CA4", account_period.apartment);

		/* price list */
		var price_list = db.get_price_list (account_period.period);
		string s = "";
		foreach (var price in price_list)
			s += "%s: %s\n".printf (price.service.name, price.value.format ());
		sheet.put_string ("A7", s);

		/* people */
		for (var i = 0; i < n_people; i++) {
			var person = people[i];
			sheet.get_row (14 + i).get_cell (27).put_string (person.name);
			sheet.get_row (14 + i).get_cell (49).put_string (person.birthday);
			sheet.get_row (14 + i).get_cell (57).put_string (person.relationship.name);
		}
	}


	private void make_page2 (OOXML.Sheet sheet, string account_number,
			string account_tenant, Gee.List<AccountPeriod> account_periods) {
		/* base information */
		sheet.put_string ("C1", account_tenant);
		sheet.put_string ("L1", account_number);

		/* services & taxes */
		int64 totals[11];
		for (var j = 0; j < 11; j++)
			totals[j] = 0;

		foreach (var account_period in account_periods) {
			var taxes = db.fetch_int_entity_map<Tax> (Tax.table_name, "service",
					null, "account=%d AND period=%d"
					.printf (account_period.account.id, account_period.period));

			var month = account_period.period % 12;
			var row = sheet.get_row (5 + month);

			for (var j = 0; j < 8; j++) {
				var tax = taxes[service_ids[j]];
				if (tax != null) {
					totals[j] += tax.total.val;
					row.get_cell (3 + j).put_string (tax.total.format ());
				}
			}

			totals[8] += account_period.total.val;
			row.get_cell (12).put_string (account_period.total.format ());
			totals[9] += account_period.payment.val;
			row.get_cell (13).put_string (account_period.payment.format ());
			totals[10] = account_period.balance.val;
			row.get_cell (14).put_string (account_period.balance.format ());
		}

		var row = sheet.get_row (17);
		for (var j = 0; j < 8; j++)
			row.get_cell (3 + j).put_string (Money (totals[j]).format ());
		row.get_cell (12).put_string (Money (totals[8]).format ());
		row.get_cell (13).put_string (Money (totals[9]).format ());
		row.get_cell (14).put_string (Money (totals[10]).format ());
	}


	public override void write (File f) throws Error {
		book.save_as (f);
	}
}



}
