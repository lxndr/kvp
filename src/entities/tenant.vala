namespace Kv {


public class Tenant : DB.SimpleEntity, DB.Viewable {
	public static string table_name = "tenant";

	public Account account { get; set; }
	public Person person { get; set; }
	public Date? move_in { get; set; default = new Date.now (); }
	public Date? move_out { get; set; default = null; }
	public Relationship? relation { get; set; default = null; }


	public string name {
		get { return person.name; }
		set { person.name = value; }
	}


	public Date? birthday {
		get { return person.birthday; }
		set { person.birthday = value; }
	}


	public override unowned string[] db_fields () {
		const string[] fields = {
			"account",
			"person",
			"move_in",
			"move_out",
			"relation"
		};
		return fields;
	}


	public Tenant (DB.Database _db, Account _account, Person _person) {
		Object (db: _db,
				account: _account,
				person: _person);
	}


	public string display_name {
		get { return person.name; }
	}
}


}
