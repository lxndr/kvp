namespace Kv.Reports {


public class TenantList : Spreadsheet {
	construct {
		template_name = "tenant-list.xlsx";
	}


	public override void make () throws Error {
		var sheet = book.sheet (0);
		OOXML.Row row;

		var cstyles = copy_styles_horz (sheet.get_cell ("A4"), 5);
		var estyles = copy_styles_horz (sheet.get_cell ("A5"), 5);

		var q = new DB.Query.select (@"$(AccountPeriod.table_name).*");
		q.from (AccountPeriod.table_name);
		q.join (Account.table_name);
		q.on (@"$(Account.table_name).id = $(AccountPeriod.table_name).account");
		if (building != null)
			q.on (@"$(Account.table_name).building = $(building.id)");
		q.where (@"period = $(selected_account.period.raw_value)");
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
			row.get_cell (4).put_number ((double) tenants.size);
			row.get_cell (5).put_number (account.area);

			paste_styles_horz (cstyles, row.get_cell (1));

			row_number++;
		}

		paste_styles_horz (estyles, sheet.get_row (row_number).get_cell (1));
	}
}



}
