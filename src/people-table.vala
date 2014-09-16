namespace Kv {


public class PeopleTable : DB.TableView {
	private Period period;
	private Account? account;


	public PeopleTable (Database dbase) {
		base (dbase, typeof (Person));
	}


	public void setup_view (Period _period, Account? _account) {
		period = _period;
		account = _account;

		update_view ();
	}


	protected override DB.Entity new_entity () {
		return new Person (db as Database, account, period);
	}


	protected override string[] view_properties () {
		return {
			"name",
			"birthday",
			"relationship"
		};
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		if (account == null)
			return new Gee.ArrayList<DB.Entity> ();

		return (db as Database).get_people_list (period, account);
	}
}


}
