namespace Kv {


public class Report003 : Report {
	const int service_ids[] = {
		5, 6, 1, 7, 8, 4, 9
	};


	private OOXML.Spreadsheet book;


	construct {
		book = new OOXML.Spreadsheet ();
	}


	public override void make () throws Error {
		book.load (GLib.File.new_for_path ("./templates/people-and-taxes.xlsx"));

		var sheet = book.sheet (0);

		/* save sheet styles */
		uint cstyles[17];
		for (var i = 0; i < 17; i++)
			cstyles[i] = sheet.get_row (11).get_cell (i + 1).style;
		uint estyles[17];
		for (var i = 0; i < 17; i++)
			estyles[i] = sheet.get_row (12).get_cell (i + 1).style;

		/* month */
		sheet.put_string ("A2", _("for %s %d year")
				.printf (Utils.month_to_string (selected_account.period % 12).down (), selected_account.period / 12));

		/* tax prices */
		var prices = db.fetch_int_int64_map (Price.table_name, "service", "value",
				"building=%d AND period=%d".printf (selected_account.account.building.id, selected_account.period));
		foreach (var id in service_ids)
			if (prices[id] == null) prices[id] = 0;

		sheet.put_number ("D3", Money (prices[5]).to_real ());
		sheet.put_number ("D4", Money (prices[6]).to_real ());
		sheet.put_number ("D5", Money (prices[1]).to_real ());
		sheet.put_number ("D6", Money (prices[7]).to_real ());
		sheet.put_number ("J3", Money (prices[8]).to_real ());
		sheet.put_number ("J4", Money (prices[4]).to_real ());
		sheet.put_number ("J5", Money (prices[9]).to_real ());

		/*  */
		var accounts = db.get_account_list (selected_account.account.building);
		OOXML.Row row = sheet.get_row(1);
		int row_number = 10;

		int64 totals[17];
		for (var i = 0; i < 17; i++)
			totals[i] = 0;

		foreach (var ac in accounts) {
			var account_period = ac.fetch_period (selected_account.period);
			if (account_period == null)
				continue;

			if (account_period.total.val == 0 && account_period.balance.val == 0)
				continue;

			row = sheet.get_row (row_number);
			row.get_cell (1).put_string (ac.number).style = cstyles[0];
			row.get_cell (2).put_string (Utils.shorten_name (ac.tenant_name (selected_account.period))).style = cstyles[1];
			row.get_cell (3).put_string (account_period.apartment).style = cstyles[2];
			row.get_cell (4).put_string (account_period.n_rooms.to_string ()).style = cstyles[3];
			row.get_cell (5).put_string (Utils.format_double (account_period.area, 2)).style = cstyles[4];

			int64 n_people = account_period.number_of_people ();
			row.get_cell (6).put_string (n_people.to_string ()).style = cstyles[5];

			var taxes = db.fetch_int_int64_map (Tax.table_name, "service", "total",
					"account=%d AND period=%d".printf (ac.id, selected_account.period));

			OOXML.Cell cell;

			for (var i = 0; i < 7; i++) {
				var id = service_ids[i];
				var val = taxes[id];

				cell = row.get_cell (7 + i);
				if (val != null && val > 0) {
					totals[6 + i] += val;
					cell.put_number (Money (val).to_real ());
				}
				cell.style = cstyles[6 + i];
			}

			int64 val;
			val = account_period.total.val;
			totals[13] += val;
			cell = row.get_cell (14);
			cell.put_number (Money (val).to_real ());
			cell.style = cstyles[13];

			val = account_period.payment.val;
			totals[14] += val;
			cell = row.get_cell (15);
			cell.put_number (Money (val).to_real ());
			cell.style = cstyles[14];

			val = account_period.previuos_balance ().val;
			totals[15] += val;
			cell = row.get_cell (16);
			cell.put_number (Money (val).to_real ());
			cell.style = cstyles[15];

			val = account_period.balance.val;
			totals[16] += val;
			cell = row.get_cell (17);
			cell.put_number (Money (val).to_real ());
			cell.style = cstyles[16];

			row_number++;
		}

		/* totals and ending style */
		for (var i = 0; i < 17; i++) {
			row = sheet.get_row (row_number);
			var cell = row.get_cell (i+1);
			cell.style = estyles[i];

			if (i == 3)
				cell.put_string (totals[i].to_string ());
			else if (i == 5)
				cell.put_string ("-");
			else if (i >= 6)
				cell.put_number (Money (totals[i]).to_real ());
		}
	}


	public override void write (File f) throws Error {
		book.save_as (f);
	}
}



}
