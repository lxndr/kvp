namespace Kv {


public class Service : Entity
{
	public int64 id { get; set; }
	public string name { get; set; }
	public string unit { get; set; }


	construct {
		id = 0;
		name = "___";
		unit = "---";
	}


	public override string get_display_name () {
		return name;
	}


	public override string[] db_keys () {
		return {
			"id"
		};
	}


	public override string[] db_fields () {
		return {
			"name",
			"unit"
		};
	}
}


}
