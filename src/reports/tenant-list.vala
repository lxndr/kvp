namespace Kv.Reports {


public class TenantList : Report {
	private OOXML.Spreadsheet book;


	construct {
		book = new OOXML.Spreadsheet ();
	}


	public override void make () throws Error {
		book.load (application.template_path ().get_child ("tenant-list.xlsx"));
		var sheet = book.sheet (0);
		OOXML.Row row;

		var q = new DB.Query.select ();
		q.from (AccountPeriod.table_name);
		q.join (Account.table_name);
		q.on (@"$(Account.table_name).id = $(AccountPeriod.table_name).account");
//		q.where (@"period = $(selected_account.period.last_day.get_days ())");
		var accounts = db.fetch_entity_list<AccountPeriod> (q);

		var row_number = 3;
		foreach (var account in accounts) {
			string people_string = "";
			string birthday_string = "";
			double row_height = 0.0;

			var tenants = account.get_tenant_list ();
			foreach (var tenant in tenants) {
				people_string += tenant.person.name + "\n";
				birthday_string += (tenant.person.birthday.format () ?? "") + "\n";
				row_height += 15.0;
			}

			people_string = people_string[0:-1];
			birthday_string = birthday_string[0:-1];

			row = sheet.get_row (row_number);
			row.custom_height = true;
			row.height = row_height;
			row.get_cell (1).put_string (account.apartment).style = 13;
			row.get_cell (2).put_string (people_string).style = 14;
			row.get_cell (3).put_string (birthday_string).style = 10;
			row.get_cell (4).put_string (tenants.size.to_string ()).style = 11;
			row.get_cell (5).put_string (account.area.to_string ()).style = 12;
			row_number++;
		}

		row = sheet.get_row (row_number + 1);
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
