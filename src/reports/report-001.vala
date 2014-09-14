namespace Kv {


public class Report001 : Report {
	private OOXML.Spreadsheet book;


	construct {
		book = new OOXML.Spreadsheet ();
	}


	public override void make () throws Error {
		book.load (GLib.File.new_for_path ("./templates/list-of-tenants.xlsx"));
		var sheet = book.sheet (0);
		OOXML.Row row;

		var accounts = db.get_account_list ();
		var count = accounts.size;
		for (var i = 0; i < count; i++) {
			var account = accounts[i];

			string people_string = "";
			string birthday_string = "";
			double row_height = 0.0;

			var people = db.get_people_list (current_period, account);
			foreach (var person in people) {
				people_string += person.name + "\r\n";
				birthday_string += person.birthday + "\r\n";
				row_height += 15.0;
			}

			people_string = people_string[0:-1];
			birthday_string = birthday_string[0:-1];

			row = sheet.get_row (3 + i);
			row.custom_height = true;
			row.height = row_height;
			row.get_cell (1).put_string (account.apartment).style = 13;
			row.get_cell (2).put_string (people_string).style = 14;
			row.get_cell (3).put_string (birthday_string).style = 10;
			row.get_cell (4).put_string (people.size.to_string ()).style = 11;
			row.get_cell (5).put_string (account.area.to_string ()).style = 12;
		}

		row = sheet.get_row (count + 2);
		row.get_cell (1).style = 20;
		row.get_cell (2).style = 19;
		row.get_cell (3).style = 18;
		row.get_cell (4).style = 16;
		row.get_cell (5).style = 17;
	}


	public override void write (File f) throws Error {
		book.save_as (f);
	}
}



}
