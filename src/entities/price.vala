namespace Kv {


public class Price : DB.SimpleEntity {
	public Building building { get; set; }
	public Service service { get; set; }
	public Date? first_day { get; set; default = null; }
	public Date? last_day { get; set; default = null; }
	public string? method { get; set; default = null; }
	public Money value1 { get; set; }
	public Money value2 { get; set; }


	public string service_name { get { return service.name; } }


	public static unowned string table_name = "price";
	public override unowned string db_table () {
		return table_name;
	}


	public override unowned string[] db_fields () {
		const string[] fields = {
			"building",
			"service",
			"first_day",
			"last_day",
			"method",
			"value1",
			"value2"
		};
		return fields;
	}


	public string display_name {
		get { return service.name; }
	}
}


}
