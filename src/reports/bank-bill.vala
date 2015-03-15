namespace Kv.Reports {

public class BankBill : Spreadsheet {
	construct {
		template_name = "bank-bill.xlsx";
	}


	public override void make () throws Error {
		var sheet = book.sheet (0);
		var period = selected_account.period;

		template_sheet_text (sheet);

		sheet.put_string ("D9",  selected_account.main_tenants_names ());
		sheet.put_string ("D17", selected_account.main_tenants_names ());

		sheet.put_number ("D11",  selected_account.total.real);
		sheet.put_number ("G28",  selected_account.total.real);

		var q = new DB.Query.select ();
		q.from (Tax.table_name);
		q.where (@"account = $(selected_account.account.id) AND period = $(period.raw_value)");
		var taxes = db.fetch_entity_list<Tax> (q);

		int row_number = 20;
		foreach (var tax in taxes) {
			var row = sheet.get_row (row_number);
			var price = tax.price;

			row.get_cell (3).put_string (tax.service.name);
			row.get_cell (4).put_number (price.value1.real);
			row.get_cell (6).put_number (tax.amount);
			row.get_cell (7).put_number (tax.total.real);

			/* workaround */
			var unit = "";
			switch (price.method) {
			case "tenatns":
			case "tenants-shower":
				unit = "чел.";
				break;
			case "norm-el":
				unit = "кВт";
				break;
			case "area":
				unit = "м2";
				break;
			case "amount":
				/* TODO */
				break;
			}
			row.get_cell (5).put_string (unit);

			row_number++;
		}
	}
}

}
