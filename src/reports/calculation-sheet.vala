namespace Kv.Reports {


public class CalculationSheet : Spreadsheet {
	const int max_services = 8;


	construct {
		template_name = "calculation-sheet.xlsx";
	}


	public override void make () throws Error {
		var sheet = book.sheet (0);
		var period = selected_account.period;

		/* save sheet styles */
		var cstyles = copy_styles_horz (sheet.get_cell ("A12"), 18);
		var estyles = copy_styles_horz (sheet.get_cell ("A13"), 18);

		template_sheet_text (sheet);

		/* tax prices */
		var q = new DB.Query.select ();
		q.from (Price.table_name);
		q.where (@"building = $(selected_account.account.building.id)");
		q.where (@"first_day IS NULL OR first_day <= $(period.last_day.get_days ())");
		q.where (@"last_day IS NULL OR last_day >= $(period.first_day.get_days ())");
		var prices = db.fetch_entity_list<Price> (q);
		/* TODO: warning that number of services is more than the template can handle */

		for (var i = 0; i < max_services; i++) {
			var slot = i + 1;
			var name_cell = sheet.find_text ("{SERVICE_%02d_NAME}".printf (slot));
			var val_cell = sheet.find_text ("{SERVICE_%02d_PRICE}".printf (slot));
			if (i < prices.size) {
				var price = prices[i];
				name_cell.put_string (price.service.name);
				val_cell.put_number (price.value1.real);
			} else {
				name_cell.val = null;
				val_cell.val = null;
			}
		}

		/* FIXME: doing one thing twice, basically */
		for (var i = 0; i < max_services; i++) {
			var slot = i + 1;
			var name_cell = sheet.find_text ("{SERVICE_%02d_NAME}".printf (slot));
			if (i < prices.size) {
				var price = prices[i];
				name_cell.put_string (price.service.name);
			} else {
				name_cell.val = null;
			}
		}

		/*  */
		int total_rooms = 0;
		double total_area = 0.0;
		int total_people = 0;
		Money totals[12];
		for (var i = 0; i < 12; i++)
			totals[i] = new Money ();

		var accounts = db.get_account_period_list (selected_account.account.building, period, true);
		OOXML.Row row = sheet.get_row(13);
		OOXML.Cell cell;
		int row_number = 11;

		foreach (var account in accounts) {
			row = sheet.get_row (row_number);

			/* account number */
			cell = row.get_cell (1);
			cell.put_string (account.account.number);

			/* tenant name */
			cell = row.get_cell (2);
			cell.put_string (account.main_tenants_names ());

			/* apartments */
			cell = row.get_cell (3);
			cell.put_string (account.apartment);

			/* number of rooms */
			cell = row.get_cell (4);
			cell.put_number ((double) account.n_rooms);

			/* area */
			cell = row.get_cell (5);
			cell.put_number (account.area);

			/* number of people */
			int n_people = account.number_of_people ();
			cell = row.get_cell (6);
			cell.put_number ((double) n_people);

			if (true) {
				/* FIXME */
				total_rooms += account.n_rooms;
				total_area += account.area;
				total_people += n_people;
			}

			/* tax totals */
			q = new DB.Query.select ("service, total");
			q.from (Tax.table_name);
			q.where (@"account = $(account.account.id) AND period = $(period.raw_value)");
			var taxes = db.fetch_value_map<int, Money> (q);

			for (var i = 0; i < max_services; i++) {
				if (i >= prices.size)
					break;

				var service_id = prices[i].service.id;
				var val = taxes[service_id];
#if 0
				if (service_id == 4 && taxes.has_key (10)) /* FIXME: this is a workaround */
					val.add (taxes[10]);
#endif

				cell = row.get_cell (7 + i);
				if (val != null && val.is_positive ()) {
					totals[i].add (val);
					cell.put_number (val.real);
				}
			}

			/* totals */
			if (!account.total.is_zero ()) {
				totals[8].add (account.total);
				cell = row.get_cell (15);
				cell.put_number (account.total.real);
			}

			if (!account.payment.is_zero ()) {
				totals[9].add (account.payment);
				cell = row.get_cell (16);
				cell.put_number (account.payment.real);
			}

			var prev_balance = account.previuos_balance ();
			totals[10].add (prev_balance);
			cell = row.get_cell (17);
			cell.put_number (prev_balance.real);

			totals[11].add (account.balance);
			cell = row.get_cell (18);
			cell.put_number (account.balance.real);

			paste_styles_horz (cstyles, row.get_cell (1));

			row_number++;
		}

		/* totals */
		row = sheet.get_row (row_number);
		row.get_cell (4).put_number ((double) total_rooms);
		row.get_cell (5).put_number (total_area);
		row.get_cell (6).put_number ((double) total_people);

		for (var i = 0; i < max_services; i++) {
			if (i >= prices.size)
				break;
			cell = row.get_cell (7 + i);
			cell.put_number (totals[i].real);
		}

		row.get_cell (15).put_number (totals[ 8].real);
		row.get_cell (16).put_number (totals[ 9].real);
		row.get_cell (17).put_number (totals[10].real);
		row.get_cell (18).put_number (totals[11].real);

		/* and ending style */
		paste_styles_horz (estyles, row.get_cell (1));
	}
}



}
