namespace Kv {


public class TaxTable : DB.TableView {
	private int period;
	private Account? account;


	public TaxTable (Database dbase) {
		base (dbase, typeof (Tax));
	}


	public void setup_view (int _period, Account? _account) {
		period = _period;
		account = _account;

		update_view ();
	}


	protected override DB.Entity new_entity () {
		var service = db.fetch_entity_by_id<Service> (1);
		return new Tax (account, period, service);
	}


	protected override unowned string[] view_properties () {
		const string props[] = {
			N_("service"),
			N_("amount"),
			N_("price"),
			N_("total")
		};
		return props;
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		if (account == null)
			return new Gee.ArrayList<DB.Entity> ();
		return (db as Database).get_tax_list (account, period);
	}
}


}
