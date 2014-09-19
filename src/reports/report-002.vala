namespace Kv {


public class Report002 : Report {
	const int64 service_ids[] = {
		5, 6, 1, 2, 7, 8, 4, 9
	};


	private OOXML.Spreadsheet book;


	construct {
		book = new OOXML.Spreadsheet ();
	}


	public override void make () throws Error {
		book.load (GLib.File.new_for_path ("./templates/account.xlsx"));

		var period = current_period.year * 12 + current_period.month - 1;
		var account_periods = db.get_account_periods (selected_account, period, period + 11);
		var last_account_period = account_periods[account_periods.size - 1];
		var people = last_account_period.get_people ();

		var account_number = last_account_period.account.number;
		var account_tenant = last_account_period.tenant_name ();

		make_page1 (book.sheet (0), last_account_period, account_number, account_tenant, people);
		make_page2 (book.sheet (1), account_number, account_tenant, account_periods);
	}


	private void make_page1 (OOXML.Sheet sheet, AccountMonth account_period,
			string account_number, string account_tenant, Gee.List<Person> people) {
		var n_people = people.size;

		sheet.put_string ("BZ1", account_number);
		sheet.put_string ("R3", account_tenant);
		sheet.put_string ("T12", account_period.n_rooms.to_string ());
		sheet.put_string ("AD12", account_period.area.to_string ());
		sheet.put_string ("AZ8", n_people.to_string ());
		sheet.put_string ("BF8", n_people.to_string ());
		sheet.put_string ("CA4", account_period.apartment);

		/* people */
		for (var i = 0; i < n_people; i++) {
			var person = people[i];
			sheet.get_row (14 + i).get_cell (27).put_string (person.name);
			sheet.get_row (14 + i).get_cell (49).put_string (person.birthday);
			sheet.get_row (14 + i).get_cell (57).put_string (person.relationship.name);
		}
	}


	private void make_page2 (OOXML.Sheet sheet, string account_number,
			string account_tenant, Gee.List<AccountMonth> account_periods) {
		/* base information */
		sheet.put_string ("C1", account_tenant);
		sheet.put_string ("L1", account_number);

		/* services & taxes */
		var list = new Gee.ArrayList<Gee.Map<int64?, Tax>> ();
		foreach (var account_period in account_periods)
			list.add (db.fetch_int64_entity_map<Tax> (Tax.table_name, "service",
					("account=%" + int64.FORMAT + " AND year=%d AND month=%d")
					.printf (account_period.account.id, account_period.period / 12, account_period.period % 12 + 1)));

		/*  */
		foreach (var taxes in list) {
			if (taxes.size == 0)
				continue;

			var month = taxes[0].month - 1;
			var row = sheet.get_row (5 + month);

			for (var j = 0; j < 7; j++) {
				var service_id = service_ids[j];

				var tax = taxes[service_id];
				if (tax != null) {
					row.get_cell (3).put_string (tax.total.format ());
//					row.get_cell (3).put_string (tax.payment.format ());
//					row.get_cell (3).put_string (tax.balance.format ());
				}
			}
		}
	}


	public override void write (File f) throws Error {
		book.save_as (f);
	}
}



}
