namespace Kv {


public class Building : DB.SimpleEntity {
	public string location { get; set; }
	public string street { get; set; }
	public string number { get; set; }
	public Period first_period { get; set; }
	public Period last_period { get; set; }
	public Period lock_period { get; set; }


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
			"start_period",
			"end_period",
			"locked_period"
		};
		return fields;
	}
}


}
