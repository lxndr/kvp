namespace Kv {


public class Service : DB.SimpleEntity, DB.Viewable
{
	public string name { get; set; }
	public string? unit { get; set; }
	public int applied_to { get; set; }


	construct {
		name = "";
		unit = null;
		applied_to = 0;
	}


	public override unowned string db_table () {
		return "services";
	}


	public override string[] db_fields () {
		return {
			"name",
			"unit",
			"applied_to"
		};
	}


	public string display_name {
		get { return name; }
	}
}


}
