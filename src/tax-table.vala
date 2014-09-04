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


	protected override Entity new_entity () {
		return new Tax (period, account);
	}


	protected override string[] view_properties () {
		return {
			"service",
			"total"
		};
	}


	protected override Gee.List<Entity> get_entity_list () throws DatabaseError {
		return db.get_tax_list (period, account);
	}
}


}
