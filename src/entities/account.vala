namespace Kv {


public class Account : DB.SimpleEntity
{
	public string number { get; set; }
	public string apartment { get; set; }
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
			"apartment",
			"area"
		};
	}


	public string display_name {
		get { return number; }
	}


	public Account (DB.Database _db) {
		Object (db: _db);
	}
}


}
