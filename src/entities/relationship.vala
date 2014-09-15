namespace Kv {


public class Relationship : DB.SimpleEntity, DB.Viewable
{
	public string name { get; set; default = ""; }


	public override unowned string db_table () {
		return "relationships";
	}


	public override string[] db_fields () {
		return {
			"name"
		};
	}


	public string display_name {
		get { return name; }
	}


	public Relationship (DB.Database _db) {
		Object (db: _db);
	}
}


}
