namespace Kv {


public class Service : DB.SimpleEntity, DB.Viewable
{
	public string name { get; set; }
	public string? unit { get; set; }
	public int applied_to { get; set; }
	public string extra1 { get; set; }


	construct {
		name = "";
		unit = null;
		applied_to = 0;
	}


	public static unowned string table_name = "services";
	public override unowned string db_table () {
		return table_name;
	}


	public override string[] db_fields () {
		return {
			"name",
			"unit",
			"applied_to",
			"extra1"
		};
	}


	public string display_name {
		get { return name; }
	}


	public override void remove () {}


	public Money get_price (int period) {
		return Money (db.fetch_int64 (Price.table_name, "value",
				("period=%d AND service=%" + int64.FORMAT)
				.printf (period, id)));
	}
}


}
