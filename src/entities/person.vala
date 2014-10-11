namespace Kv {


public class Person : DB.SimpleEntity, DB.Viewable
{
	public string name { get; set; default = _("A person"); }
	public Date birthday { get; set; }
	public bool gender { get; set; default = false; }
	public string? real_life_id { get; set; default = null; }


	construct {
		Date date;
		date.set_julian (1);
		birthday = date;
	}


	public static unowned string table_name = "person";
	public override unowned string db_table () {
		return table_name;
	}


	public override unowned string[] db_fields () {
		const string[] fields = {
			"name",
			"birthday",
			"gender",
			"real_life_id"
		};
		return fields;
	}


	public string display_name {
		get { return name; }
	}
}


}
