namespace Kv {


public class Report001 : Object, Report {
	private OOXML.Spreadsheet book;


	public Report001 () {
		book = new OOXML.Spreadsheet ();
	}



	public void make (Database db) throws Error {
		book.load (GLib.File.new_for_path ("./reports/report-001.xlsx"));
		var sheet = book.sheet (0);

		var accounts = db.get_account_list ();
		var count = accounts.size;
		for (var i = 0; i < count; i++) {
			var account = accounts[i];

			string people_string = "";
			string birthday_string = "";

			var people = db.get_account_people (account);
			foreach (var person in people) {
				people_string += person.name + "\n";
				birthday_string += person.birthday + "\n";
			}

			people_string = people_string[0:-1];
			birthday_string = birthday_string[0:-1];

			var row_number = 4 + i;
			sheet.insert_row (row_number);
			sheet.put_string ("A" + row_number, account.apartment);
			sheet.put_string ("B" + row_number, people_string);
			sheet.put_string ("C" + row_number, birthday_string);
			sheet.put_string ("D" + row_number, people.size);
			sheet.put_string ("E" + row_number, account.area);
		}
	}


	public void write (File f) throws Error {
		book.save_as (f);
	}
}



}
