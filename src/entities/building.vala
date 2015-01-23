namespace Kv {


public class Building : DB.SimpleEntity {
	public static unowned string table_name = "building";

	public string location { get; set; }
	public string street { get; set; }
	public string number { get; set; }
	public Month first_period { get; set; }
	public Month last_period { get; set; }
	public Month lock_period { get; set; }
	public string? comment { get; set; }


	construct {
		first_period = new Month.now ();
		last_period = new Month.now ();
	}


	public Building (Database _db) {
		Object (db: _db);
	}


	public override unowned string[] db_fields () {
		const string[] fields = {
			"location",
			"street",
			"number",
			"first_period",
			"last_period",
			"lock_period",
			"comment"
		};
		return (string[]) fields;
	}


	public string full_name () {
		return "%s, %s".printf (street, number);
	}


	public override void remove () {
		db.begin_transaction ();
		base.remove ();
		/* TODO */
		/* remove prices */
		db.commit_transaction ();
	}
}


}
