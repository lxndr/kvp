namespace Kv {


public class Report003 : Report {
	const int64 service_ids[] = {
		5, 6, 1, 2, 7, 8, 4, 9
	};


	private OOXML.Spreadsheet book;


	construct {
		book = new OOXML.Spreadsheet ();
	}



	private string make_name (string? name) {
		var p = name.index_of_char (' ');
		if (p == -1)
			return name;
		else
			return name[0:p+3];
	}


	public override void make () throws Error {
		book.load (GLib.File.new_for_path ("./templates/people-and-taxes.xlsx"));

		var sheet = book.sheet (0);

		var accounts = db.get_account_list ();
		int row_number = 10;

		foreach (var ac in accounts) {
			var account_period = ac.fetch_period (current_period.year, current_period.month);

			var row = sheet.get_row (row_number);
			row.get_cell (1).put_string (ac.number);
			row.get_cell (3).put_string (ac.apartment);
			row.get_cell (4).put_string (ac.nrooms.to_string ());
			row.get_cell (5).put_string (Utils.format_double (ac.area, 2));

			int64 n_people = ac.number_of_people (current_period.year, current_period.month);
			if (n_people > 0)
				row.get_cell (2).put_string (make_name (
						ac.tenant_name (current_period.year, current_period.month)));
			row.get_cell (6).put_string (n_people.to_string ());

/*			row.get_cell (7).put_string ("");
			row.get_cell (8).put_string ("");
			row.get_cell (9).put_string ("");
			row.get_cell (10).put_string ("");
			row.get_cell (11).put_string ("");
			row.get_cell (12).put_string ("");
			row.get_cell (13).put_string ("");*/
			row.get_cell (14).put_string (account_period.total.format ());
			row.get_cell (15).put_string (account_period.payment.format ());
			row.get_cell (16).put_string (account_period.previuos_balance ().format ());
			row.get_cell (17).put_string (account_period.balance.format ());

			row_number++;
		}
	}


	public override void write (File f) throws Error {
		book.save_as (f);
	}
}



}
