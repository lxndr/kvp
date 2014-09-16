namespace Kv {


public class Person : DB.SimpleEntity, DB.Viewable
{
	public Account account { get; set; }
	public int year { get; set; }
	public int month { get; set; }
	public string name { get; set; }
	public string birthday { get; set; }
	public Relationship relationship { get; set; }


	construct {
		name = "000";
		birthday = "";
	}


	public override unowned string db_table () {
		return "people";
	}


	public override string[] db_fields () {
		return {
			"account",
			"year",
			"month",
			"name",
			"birthday",
			"relationship"
		};
	}


	public Person (Database _db, Account _account, Period _period) {
		var _relationship = _db.get_entity (typeof (Relationship), 2) as Relationship;

		Object (db: _db,
				account: _account,
				year: _period.year,
				month: _period.month,
				relationship: _relationship);
	}


	public string display_name {
		get { return name; }
	}


	public override void remove () {}
}


}
