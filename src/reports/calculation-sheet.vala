namespace Kv.Reports {


public class CalculationSheet : Report {
	const int service_ids[] = {
		5, 6, 4, 1, 2, 3, 7, 9, 10
	};


	private OOXML.Spreadsheet book;


	construct {
		book = new OOXML.Spreadsheet ();
	}


	public override void make () throws Error {
		book.load (GLib.File.new_for_path ("./templates/calculation-sheet.xlsx"));

		var sheet = book.sheet (0);

		/* save sheet styles */
		uint cstyles[18];
		for (var i = 0; i < 18; i++)
			cstyles[i] = sheet.get_row (12).get_cell (i + 1).style;
		uint estyles[18];
		for (var i = 0; i < 18; i++)
			estyles[i] = sheet.get_row (13).get_cell (i + 1).style;

		/* month */
		sheet.put_string ("A2", _("for %s %d year")
				.printf (Utils.month_to_string (selected_account.period.raw_value % 12).down (), selected_account.period.raw_value / 12));

		/* address */
		sheet.put_string ("A3", "Address");

		/* tax prices */
		var prices = db.fetch_int_int64_map (Price.table_name, "service", "value1",
				"building = %d AND (first_day IS NULL OR first_day <= %d) AND (last_day IS NULL OR last_day >= %d)"
				.printf (selected_account.account.building.id, selected_account.period.last_day.get_days (), selected_account.period.first_day.get_days ()));
		foreach (var id in service_ids)
			if (prices[id] == null) prices[id] = 0;

		sheet.put_number ("D4", new Money.from_raw_integer (prices[5]).real);
		sheet.put_number ("D5", new Money.from_raw_integer (prices[6]).real);
		sheet.put_number ("D6", new Money.from_raw_integer (prices[4]).real);
		sheet.put_number ("D7", new Money.from_raw_integer (prices[1]).real);
		sheet.put_number ("J4", new Money.from_raw_integer (prices[2]).real);
		sheet.put_number ("J5", new Money.from_raw_integer (prices[3]).real);
		sheet.put_number ("J6", new Money.from_raw_integer (prices[7]).real);
		sheet.put_number ("J7", new Money.from_raw_integer (prices[9]).real);

		/*  */
		var accounts = db.get_account_list (selected_account.account.building);
		OOXML.Row row = sheet.get_row(1);
		int row_number = 11;

		Money totals[18];

		foreach (var ac in accounts) {
			var periodic = ac.fetch_period (selected_account.period);
			if (periodic == null)
				continue;

			if (periodic.total.is_zero () && periodic.balance.is_zero ())
				continue;

			row = sheet.get_row (row_number);
			row.get_cell (1).put_string (ac.number).style = cstyles[0];
			row.get_cell (2).put_string (Utils.shorten_name (periodic.main_tenant_name ())).style = cstyles[1];
			row.get_cell (3).put_string (periodic.apartment).style = cstyles[2];
			row.get_cell (4).put_string (periodic.n_rooms.to_string ()).style = cstyles[3];
			row.get_cell (5).put_string (Utils.format_double (periodic.area, 2)).style = cstyles[4];

			int64 n_people = periodic.number_of_people ();
			row.get_cell (6).put_string (n_people.to_string ()).style = cstyles[5];

			var taxes = db.fetch_int_int64_map (Tax.table_name, "service", "total",
					"account = %d AND period = %d".printf (ac.id, selected_account.period.raw_value));

			OOXML.Cell cell;

			for (var i = 0; i < 8; i++) {
				var id = service_ids[i];
				var val = taxes[id];
				if (id == 4 && taxes.has_key (10)) /* FIXME: this is a workaround */
					val += taxes[10];

				cell = row.get_cell (7 + i);
				if (val != null && val > 0) {
					totals[6 + i].integer += val;
					cell.put_number (new Money.from_raw_integer (val).real);
				}
				cell.style = cstyles[6 + i];
			}

			totals[14].add (periodic.total);
			cell = row.get_cell (15);
			cell.put_number (periodic.total.real);
			cell.style = cstyles[14];

			totals[15].add (periodic.payment);
			cell = row.get_cell (16);
			cell.put_number (periodic.payment.real);
			cell.style = cstyles[15];

			var prev_balance = periodic.previuos_balance ();
			totals[16].add (prev_balance);
			cell = row.get_cell (17);
			cell.put_number (prev_balance.real);
			cell.style = cstyles[16];

			totals[17].add (periodic.balance);
			cell = row.get_cell (18);
			cell.put_number (periodic.balance.real);
			cell.style = cstyles[17];

			row_number++;
		}

		/* totals and ending style */
		for (var i = 0; i < 18; i++) {
			row = sheet.get_row (row_number);
			var cell = row.get_cell (i+1);
			cell.style = estyles[i];

			if (i == 3)
				cell.put_string (totals[i].integer.to_string ());
			else if (i == 5)
				cell.put_string ("-");
			else if (i >= 6)
				cell.put_number (totals[i].real);
		}
	}


	public override void write (File f) throws Error {
		book.save_as (f);
	}
}



}
