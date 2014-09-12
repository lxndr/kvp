namespace Kv {


public class Service : Entity
{
	public int64 id { get; set; }
	public string name { get; set; }
	public string? unit { get; set; }
	public int applied_to { get; set; }


	static construct {
		table_name = "services";
	}


	construct {
		id = 0;
		name = "";
		unit = null;
		applied_to = 0;
	}


	public override string get_display_name () {
//		return name;
		return table_name;
	}


	public override string[] db_keys () {
		return {
			"id"
		};
	}


	public override string[] db_fields () {
		return {
			"name",
			"unit",
			"applied_to"
		};
	}
}


}
