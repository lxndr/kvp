namespace Kv {


public class Service : SimpleEntity
{
	public string name { get; set; }
	public string? unit { get; set; }
	public int applied_to { get; set; }


	construct {
		name = "";
		unit = null;
		applied_to = 0;
	}


	public override unowned string db_table_name () {
		return "services";
	}


	public override string[] db_fields () {
		return {
			"name",
			"unit",
			"applied_to"
		};
	}


	public override string get_display_name () {
		return name;
	}
}


}
