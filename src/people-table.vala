namespace Kv {


public class PeopleTable : DB.TableView {
	private int period;
	private Account? account;


	public PeopleTable (Database dbase) {
		base (dbase, typeof (Person));
	}


	public void setup_view (int _period, Account? _account) {
		period = _period;
		account = _account;

		update_view ();
	}


	protected override DB.Entity new_entity () {
		return new Person (db as Database, account, period);
	}


	protected override unowned string[] view_properties () {
		const string props[] = {
			N_("name"),
			N_("birthday"),
			N_("relationship")
		};
		return props;
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		if (account == null)
			return new Gee.ArrayList<DB.Entity> ();

		return (db as Database).get_people_list (account, period);
	}
}


}
