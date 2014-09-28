namespace Kv {


public class PeopleTable : DB.ViewTable {
	private AccountPeriod? current_periodic;


	public PeopleTable (Database _db) {
		Object (db: _db,
				object_type: typeof (Person));
	}


	public void setup (AccountPeriod? periodic) {
		current_periodic = periodic;
		refresh_view ();
	}


	protected override DB.Entity? new_entity () {
		return new Person (db as Database, current_periodic.account, current_periodic.period);
	}


	protected override unowned string[] viewable_props () {
		const string props[] = {
			N_("name"),
			N_("birthday"),
			N_("relationship")
		};
		return props;
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		if (current_periodic == null)
			return new Gee.ArrayList<DB.Entity> ();
		return (db as Database).get_people_list (current_periodic.account, current_periodic.period);
	}
}


}
