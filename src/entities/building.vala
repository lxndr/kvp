namespace Kv {


public class Building : DB.SimpleEntity {
	public string location { get; set; }
	public string street { get; set; }
	public string number { get; set; }
	public Month first_period { get; set; }
	public Month last_period { get; set; }
	public Month lock_period { get; set; }


	public Building (Database _db) {
		Object (db: _db);
	}


	public static unowned string table_name = "building";
	public override unowned string db_table () {
		return table_name;
	}


	public override unowned string[] db_fields () {
		const string[] fields = {
			"location",
			"street",
			"number",
			"first_period",
			"last_period",
			"lock_period"
		};
		return fields;
	}


	public string full_name () {
		return "%s, %s".printf (street, number);
	}
}


}
