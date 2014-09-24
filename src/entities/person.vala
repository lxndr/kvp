namespace Kv {


public class Person : DB.SimpleEntity, DB.Viewable
{
	public Account account { get; set; }
	public int period { get; set; }
	public string name { get; set; }
	public string birthday { get; set; }
	public Relationship relationship { get; set; }


	construct {
		name = _("A person");
		birthday = "";
	}


	public static unowned string table_name = "person";
	public override unowned string db_table () {
		return table_name;
	}


	public override unowned string[] db_fields () {
		const string[] fields = {
			"account",
			"period",
			"name",
			"birthday",
			"relationship"
		};
		return fields;
	}


	public Person (Database _db, Account _account, int _period) {
		var _relationship = _db.fetch_entity_by_id<Relationship> (2);

		Object (db: _db,
				account: _account,
				period: _period,
				relationship: _relationship);
	}


	public string display_name {
		get { return name; }
	}
}


}
