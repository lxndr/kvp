namespace Kv {


public class Person : DB.SimpleEntity, DB.Viewable {
	public static unowned string table_name = "person";

	public string name { get; set; default = _("A person"); }
	public Date? birthday { get; set; default = null; }
	public bool gender { get; set; default = false; }
	public string? real_life_id { get; set; default = null; }


	public Person (DB.Database _db) {
		Object (db: _db);
	}


	public override void remove () {
		var q = new DB.Query.delete (Tenant.table_name);
		q.where (@"person = $(id)");

		db.begin_transaction ();
		base.remove ();
		db.exec (q);
		db.commit_transaction ();
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
