namespace Kv {


public class Relationship : DB.SimpleEntity, DB.Viewable {
	public static unowned string table_name = "relationships";

	public string name { get; set; default = ""; }


	public override unowned string[] db_fields () {
		const string[] fields = {
			"name"
		};
		return (string[]) fields;
	}


	public string display_name {
		get { return name; }
	}


	public Relationship (DB.Database _db) {
		Object (db: _db);
	}


	public override void remove () {}
}


}
