namespace Kv {


public class AccountTable : TableView {
	public AccountTable (Database dbase) {
		base (dbase, typeof (Account));
	}


	protected override Gee.List<Entity> get_entity_list () {
		return db.get_account_list ();
	}
}


}
