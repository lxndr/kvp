namespace Kv {


public class Report003 : Report {
	const int service_ids[] = {
		5, 6, 1, 7, 8, 4, 9
	};


	private OOXML.Spreadsheet book;


	construct {
		book = new OOXML.Spreadsheet ();
	}


	private string make_name (string? name) {
		if (name == null)
			return "";

		var p = name.index_of_char (' ');
		if (p == -1)
			return name;
		else
			return name[0:p+3];
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

		/* tax prices */
		var prices = db.fetch_int_int64_map (Price.table_name, "service", "value",
				"period=%d".printf (period));

		foreach (var id in service_ids)
			if (prices[id] == null) prices[id] = 0;

		sheet.put_string ("D3", Money (prices[5]).format ());
		sheet.put_string ("D4", Money (prices[6]).format ());
		sheet.put_string ("D5", Money (prices[1]).format ());
		sheet.put_string ("D6", Money (prices[7]).format ());
		sheet.put_string ("J3", Money (prices[8]).format ());
		sheet.put_string ("J4", Money (prices[4]).format ());
		sheet.put_string ("J5", Money (prices[9]).format ());


		var accounts = db.get_account_list ();
		OOXML.Row row = sheet.get_row(1);
		int row_number = 10;

		int64 totals[17];
		for (var i = 0; i < 17; i++)
			totals[i] = 0;

		foreach (var ac in accounts) {
			var account_period = ac.fetch_period (period);

			row = sheet.get_row (row_number);
			row.get_cell (1).put_string (ac.number).style = cstyles[0];
			row.get_cell (2).put_string (make_name (ac.tenant_name (period))).style = cstyles[1];
			row.get_cell (3).put_string (account_period.apartment).style = cstyles[2];
			row.get_cell (4).put_string (account_period.n_rooms.to_string ()).style = cstyles[3];
			row.get_cell (5).put_string (Utils.format_double (account_period.area, 2)).style = cstyles[4];

			int64 n_people = ac.number_of_people (period);
			row.get_cell (6).put_string (n_people.to_string ()).style = cstyles[5];

			var taxes = db.fetch_int_int64_map (Tax.table_name, "service", "total",
					("account=%" + int64.FORMAT + " AND year=%d AND month=%d")
					.printf (ac.id, period / 12, period % 12 + 1));

			OOXML.Cell cell;

			for (var i = 0; i < 7; i++) {
				var id = service_ids[i];
				var val = taxes[id];

				cell = row.get_cell (7 + i);
				if (val != null && val > 0) {
					totals[6 + i] += val;
					cell.put_string (Money (val).format ());
				}
				cell.style = cstyles[6 + i];
			}

			int64 val;
			val = account_period.total.val;
			totals[13] += val;
			cell = row.get_cell (14);
			cell.put_string (Money (val).format ());
			cell.style = cstyles[13];

			val = account_period.payment.val;
			totals[14] += val;
			cell = row.get_cell (15);
			cell.put_string (Money (val).format ());
			cell.style = cstyles[14];

			val = account_period.previuos_balance ().val;
			totals[15] += val;
			cell = row.get_cell (16);
			cell.put_string (Money (val).format ());
			cell.style = cstyles[15];

			val = account_period.balance.val;
			totals[16] += val;
			cell = row.get_cell (17);
			cell.put_string (Money (val).format ());
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
				cell.put_string (Money (totals[i]).format ());
		}
	}


	public override void write (File f) throws Error {
		book.save_as (f);
	}
}



}
