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
		make_page1 ();
		make_page2 ();
	}


	private void make_page1 () {
	}


	private void make_page2 () {
		var sheet = book.sheet (1);

		/* base information */
		var account = selected_account;

		sheet.put_string ("C1", account.tenant_name (current_period.year * 12 + current_period.month - 1));
		sheet.put_string ("L1", account.number);

		/* services & taxes */
		for (var service_iter = 0; service_iter < service_ids.length; service_iter++) {
			var column_number = 3 + service_iter;
			var taxes = db.find_taxes_by_service_id (current_period, account, service_ids[service_iter]);

			for (var month = 1; month <= 12; month++) {
				if (taxes.has_key (month) == false)
					continue;

				var row_number = month + 4;
				var tax = taxes[month];
				sheet.get_row (row_number).get_cell (column_number).put_string (tax.total.format ());
			}
		}

		/* account months */
		var totals = db.find_account_month_by_year (account, current_period.year);
		for (var month = 1; month <= 12; month++) {
			if (totals.has_key (month) == false)
				continue;

			var row_number = month + 4;
			var item = totals[month];
			sheet.get_row (row_number).get_cell (12).put_string (item.total.format ());
			sheet.get_row (row_number).get_cell (13).put_string (item.payment.format ());
			sheet.get_row (row_number).get_cell (14).put_string (item.balance.format ());
		}
	}


	public override void write (File f) throws Error {
		book.save_as (f);
	}
}



}
