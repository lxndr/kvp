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

		var q = new DB.Query.select (@"$(AccountPeriod.table_name).*");
		q.from (AccountPeriod.table_name);
		q.join (Account.table_name);
		q.on (@"$(Account.table_name).id = $(AccountPeriod.table_name).account");
		if (building != null)
			q.on (@"$(Account.table_name).building = $(building.id)");
//		q.where (@"period = $(selected_account.period.last_day.get_days ())");
		var accounts = db.fetch_entity_list<AccountPeriod> (q);

		var row_number = 3;
		foreach (var account in accounts) {
			string people_string = "";
			string birthday_string = "";
			double row_height = 0.0;

			var tenants = account.get_tenant_list ();
			foreach (var tenant in tenants) {
				if (people_string.length > 0)
					people_string += "\n";
				people_string += tenant.person.name;

				if (birthday_string.length > 0)
					birthday_string += "\n";
				if (tenant.person.birthday != null)
					birthday_string += tenant.person.birthday.format ();
				else
					birthday_string += "";

				row_height += 15.0;
			}

			row = sheet.get_row (row_number);
			row.custom_height = true;
			row.height = row_height;

			row.get_cell (1).put_string (account.apartment);
			row.get_cell (2).put_string (people_string);
			row.get_cell (3).put_string (birthday_string);
			row.get_cell (4).put_string (tenants.size.to_string ());
			row.get_cell (5).put_string (account.area.to_string ());

			row_number++;
		}

/*
		row = sheet.get_row (row_number + 1);
		row.get_cell (1).style = 20;
		row.get_cell (2).style = 19;
		row.get_cell (3).style = 18;
		row.get_cell (4).style = 16;
		row.get_cell (5).style = 17;
*/
	}


	public override void write (File f) throws Error {
		book.save_as (f);
	}
}



}
