namespace Kv {


public class Person : Entity
{
	public int64 id { get; set; }
	public string name { get; set; }
	public string birthday { get; set; }


	construct {
		id = 0;
		name = "000";
		birthday = "000";
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
			"birthday"
		};
	}
}


}
