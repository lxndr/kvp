namespace Kv {


public class Report003 : Report {
	const int service_ids[] = {
		5, 6, 1, 2, 7, 8, 4, 9
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


	private Gee.Map<int, Money?> fetch_totals (int64 acc) {
		var list = new Gee.HashMap<int, Money?> ();
		foreach (var id in service_ids)
			list[id] = Money (0);

		var query = ("SELECT service,total FROM taxes WHERE account=%" +
				int64.FORMAT + " AND year=%d AND month=%d")
				.printf (acc, current_period.year, current_period.month);
		db.exec_sql (query, (n_columns, values, column_names) => {
			var id = (int) int64.parse (values[0]);
			list.set (id, Money (int64.parse (values[1])));
			return 0;
		});
		return list;
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
				"period=%d".printf (current_period.year * 12 + current_period.month - 1));

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

		foreach (var ac in accounts) {
			var account_period = ac.fetch_period (current_period.year, current_period.month);

			row = sheet.get_row (row_number);
			row.get_cell (1).put_string (ac.number).style = cstyles[0];
			row.get_cell (2).put_string (make_name (ac.tenant_name (
					current_period.year, current_period.month))).style = cstyles[1];
			row.get_cell (3).put_string (ac.apartment).style = cstyles[2];
			row.get_cell (4).put_string (ac.nrooms.to_string ()).style = cstyles[3];
			row.get_cell (5).put_string (Utils.format_double (ac.area, 2)).style = cstyles[4];

			int64 n_people = ac.number_of_people (current_period.year, current_period.month);
			row.get_cell (6).put_string (n_people.to_string ()).style = cstyles[5];

			var totals = fetch_totals (ac.id);
			row.get_cell (7).put_string (totals[5].format ()).style = cstyles[6];
			row.get_cell (8).put_string (totals[5].format ()).style = cstyles[7];
			row.get_cell (9).put_string (totals[5].format ()).style = cstyles[8];
			row.get_cell (10).put_string (totals[5].format ()).style = cstyles[9];
			row.get_cell (11).put_string (totals[5].format ()).style = cstyles[10];
			row.get_cell (12).put_string (totals[5].format ()).style = cstyles[11];
			row.get_cell (13).put_string (totals[5].format ()).style = cstyles[12];

			row.get_cell (14).put_string (account_period.total.format ()).style = cstyles[13];
			row.get_cell (15).put_string (account_period.payment.format ()).style = cstyles[14];
			row.get_cell (16).put_string (account_period.previuos_balance ().format ()).style = cstyles[15];
			row.get_cell (17).put_string (account_period.balance.format ()).style = cstyles[16];

			row_number++;
		}

		row.get_cell(1).style = estyles[0];
		row.get_cell(2).style = estyles[1];
		row.get_cell(3).style = estyles[2];
		row.get_cell(4).style = estyles[3];
		row.get_cell(5).style = estyles[4];
		row.get_cell(6).style = estyles[5];
		row.get_cell(7).style = estyles[6];
		row.get_cell(8).style = estyles[7];
		row.get_cell(9).style = estyles[8];
		row.get_cell(10).style = estyles[9];
		row.get_cell(11).style = estyles[10];
		row.get_cell(12).style = estyles[11];
		row.get_cell(13).style = estyles[12];
		row.get_cell(14).style = estyles[13];
		row.get_cell(15).style = estyles[14];
		row.get_cell(16).style = estyles[15];
		row.get_cell(17).style = estyles[16];
	}


	public override void write (File f) throws Error {
		book.save_as (f);
	}
}



}
