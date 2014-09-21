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


	protected override unowned string[] view_properties () {
		const string props[] = {
			N_("apply"),
			N_("service_name"),
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
