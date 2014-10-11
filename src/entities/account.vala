namespace Kv {


public class Account : DB.SimpleEntity
{
	public Building building { get; construct set; }
	public string number { get; set; default = "000"; }
	public Date opened {get; set; }
	public string comment { get; set; default = ""; }


	construct {
		var now = new DateTime.now_local ();
		opened.set_dmy ((DateDay) now.get_day_of_month (), now.get_month (), (DateYear) now.get_year ());
	}


	public static unowned string table_name = "account";
	public override unowned string db_table () {
		return table_name;
	}


	public override unowned string[] db_fields () {
		const string[] fields = {
			"building",
			"number",
			"opened",
			"comment"
		};
		return fields;
	}


	public string display_name {
		get { return number; }
	}


	public Account (DB.Database _db, Building _building) {
		Object (db: _db,
				building: _building);
	}


	public override void remove () {
		db.begin_transaction ();
		base.remove ();
		db.delete_entity (AccountPeriod.table_name, "account=%d".printf (id));
		db.delete_entity (Person.table_name, "account=%d".printf (id));
		db.delete_entity (Tax.table_name, "account=%d".printf (id));
		db.commit_transaction ();
	}

/*
	public int64 number_of_people (int period) {
		return db.query_count ("people",
				("account=%" + int64.FORMAT + " AND period=%d")
				.printf (id, period));
	}
*/

/*
	public Person? tenant (int year, int month) {
		return db.get_entity (typeof (Person),
				("SELECT * FROM people WHERE account=%" + int64.FORMAT +
				" AND year=%d AND month=%d AND relationship=1")
				.printf (id, year, month));
	}
*/


	public string? tenant_name (int period) {
/*		return db.fetch_string (Person.table_name, "name",
				"account=%d AND period=%d AND relationship=1"
				.printf (id, period));*/
		return "fixme";
	}


	public AccountPeriod? fetch_period (int period) {
		return db.fetch_entity<AccountPeriod> (AccountPeriod.table_name,
				"account=%d AND period=%d".printf (id, period));
	}
}


}
