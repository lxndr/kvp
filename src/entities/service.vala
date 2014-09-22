namespace Kv {


public class Service : DB.SimpleEntity, DB.Viewable
{
	public string name { get; set; }


	public static unowned string table_name = "service";
	public override unowned string db_table () {
		return table_name;
	}


	public override string[] db_fields () {
		return {
			"name"
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

	public int get_method (int period) {
		return (int) db.fetch_int64 (Price.table_name, "method",
				("period=%d AND service=%" + int64.FORMAT)
				.printf (period, id));
	}
}


}
