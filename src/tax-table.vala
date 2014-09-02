namespace Kv {


public class TaxTable : TableView {
	private Period period;
	private Account account;


	public TaxTable (Database dbase) {
		base (dbase, typeof (Tax));
	}


	public void setup_view (Period _period, Account _account) {
		period = _period;
		account = _account;

		update_view ();
	}


	protected override Gee.List<Entity> get_entity_list () {
		return db.get_tax_list (period, account);
	}
}


}
