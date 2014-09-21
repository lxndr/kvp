namespace Kv {


public class Account : DB.SimpleEntity
{
	public int building { get; set; default = 1;}
	public string number { get; set; }
	public int opened {get; set; default = 0; } /* FIXME gotta be now */


	construct {
		number = "000";
	}


	public static unowned string table_name = "account";
	public override unowned string db_table () {
		return table_name;
	}


	public override string[] db_fields () {
		return {
			"building",
			"number",
			"opened"
		};
	}


	public string display_name {
		get { return number; }
	}


	public Account (DB.Database _db) {
		Object (db: _db);
	}


	public override void remove () {
		base.remove ();

		db.delete_entity (AccountPeriod.table_name,
				("account=%" + int64.FORMAT).printf (id));
		db.delete_entity ("people",
				("account=%" + int64.FORMAT).printf (id));
		db.delete_entity ("taxes",
				("account=%" + int64.FORMAT).printf (id));
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
		return db.fetch_string (Person.table_name, "name", ("account=%" +
				int64.FORMAT + " AND period=%d AND relationship=1")
				.printf (id, period));
	}


	public AccountPeriod? fetch_period (int period) {
		return db.fetch_entity<AccountPeriod> (AccountPeriod.table_name,
				("account=%" + int64.FORMAT + " AND period=%d").
				printf (id, period));
	}
}


}
