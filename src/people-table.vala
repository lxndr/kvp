namespace Kv {


public class PeopleTable : TableView {
	private Period period;
	private Account account;


	public PeopleTable (Database dbase) {
		base (dbase, typeof (Person));
	}


	public void setup_view (Period _period, Account _account) {
		period = _period;
		account = _account;

		update_view ();
	}


	protected override string[] view_properties () {
		return {
			"name",
			"birthday"
		};
	}


	protected override Gee.List<Entity> get_entity_list () {
		return db.get_people_list (period, account);
	}
}


}
