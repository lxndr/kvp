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
			.printf (
				Utils.month_to_string (selected_account.period.raw_value % 12).down (),
				selected_account.period.raw_value / 12));

		/* address */
		sheet.put_string ("A3", "Address");

		/* tax prices */
		var q = new DB.Query.select ("service, value1");
		q.from (Price.table_name);
		q.where (@"building = $(selected_account.account.building.id)");
		q.where (@"first_day IS NULL OR first_day <= $(selected_account.period.last_day.get_days ())");
		q.where (@"last_day IS NULL OR last_day >= $(selected_account.period.first_day.get_days ())");
		var prices = db.fetch_value_map<int, Money> (q);
		foreach (var id in service_ids)
			if (prices[id] == null)
				prices[id] = new Money ();

		sheet.put_number ("D4", prices[5].real);
		sheet.put_number ("D5", prices[6].real);
		sheet.put_number ("D6", prices[4].real);
		sheet.put_number ("D7", prices[1].real);
		sheet.put_number ("J4", prices[2].real);
		sheet.put_number ("J5", prices[3].real);
		sheet.put_number ("J6", prices[7].real);
		sheet.put_number ("J7", prices[9].real);

		/*  */
		var accounts = db.get_account_list (selected_account.account.building);
		OOXML.Row row = sheet.get_row(1);
		int row_number = 11;

		Money totals[18];
		for (var i = 0; i < 18; i++)
			totals[i] = new Money ();

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

			q = new DB.Query.select ("service, total");
			q.from (Tax.table_name);
			q.where (@"account = $(ac.id) AND period = $(selected_account.period.raw_value)");
			var taxes = db.fetch_value_map<int, Money> (q);

			OOXML.Cell cell;

			for (var i = 0; i < 8; i++) {
				var id = service_ids[i];
				var val = taxes[id];
				if (id == 4 && taxes.has_key (10)) /* FIXME: this is a workaround */
					val.add (taxes[10]);

				cell = row.get_cell (7 + i);
				if (val != null && val.is_positive ()) {
					totals[6 + i].add (val);
					cell.put_number (val.real);
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
