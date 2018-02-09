namespace Kv.Reports {

public class InvoiceAll : Spreadsheet {
	construct {
		template_name = "invoice.xlsx";
	}


	public override void make () throws Error {
		var sheet = book.sheet (0);
		// var period = selected_account.period;

		template_sheet_text (sheet);

		var total = selected_account.total;
		sheet.put_number ("F21",  total.real);
		sheet.put_number ("H21",  total.real);
		sheet.put_number ("H22",  total.real);
		sheet.put_number ("P21",  total.real);
		sheet.put_number ("P22",  total.real);
	}
}

}
