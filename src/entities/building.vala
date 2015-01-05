namespace Kv {


public class Building : DB.SimpleEntity {
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
		return fields;
	}


	public string full_name () {
		return "%s, %s".printf (street, number);
	}
}


}
