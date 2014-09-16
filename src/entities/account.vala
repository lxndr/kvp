namespace Kv {


public class Account : DB.SimpleEntity
{
	public string number { get; set; }
	public int open_date {get; set; default = 0; } /* FIXME gotta be now */
	public string apartment { get; set; }
	public int nrooms {get; set; default = 1;}
	public double area { get; set; }


	construct {
		number = "000";
		apartment = "000";
		area = 0.0;
	}


	public override unowned string db_table () {
		return "accounts";
	}


	public override string[] db_fields () {
		return {
			"number",
			"open_date",
			"apartment",
			"nrooms",
			"area"
		};
	}


	public string display_name {
		get { return number; }
	}


	public Account (DB.Database _db) {
		Object (db: _db);
	}


	public override void remove () {
		var query = ("DELETE FROM accounts WHERE id=%" + int64.FORMAT)
				.printf (id);
		db.exec_sql (query, null);

		query = ("DELETE FROM people WHERE account=%" + int64.FORMAT)
				.printf (id);
		db.exec_sql (query, null);

		query = ("DELETE FROM taxes WHERE account=%" + int64.FORMAT)
				.printf (id);
		db.exec_sql (query, null);
	}


	public int64 number_of_people (int year, int month) {
		return db.query_count ("people",
				("account=%" + int64.FORMAT + " AND year=%d AND month=%d")
				.printf (id, year, month));
	}


/*
	public Person? tenant (int year, int month) {
		return db.get_entity (typeof (Person),
				("SELECT * FROM people WHERE account=%" + int64.FORMAT +
				" AND year=%d AND month=%d AND relationship=1")
				.printf (id, year, month));
	}
*/


	public string? tenant_name (int year, int month) {
		return db.query_string ("people", "name", ("account=%" +
				int64.FORMAT + " AND year=%d AND month=%d AND relationship=1")
				.printf (id, year, month));
	}
}


}
