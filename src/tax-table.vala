namespace Kv {


public class TaxTable : DB.TableView {
	private Period period;
	private Account? account;


	public TaxTable (Database dbase) {
		base (dbase, typeof (Tax));
	}


	public void setup_view (Period _period, Account? _account) {
		period = _period;
		account = _account;

		update_view ();
	}


	protected override DB.Entity new_entity () {
		var service = db.get_entity (typeof (Service), 1) as Service;
		return new Tax (period, account, service);
	}


	protected override string[] view_properties () {
		return {
			"service",
			"amount",
			"price",
			"total"
		};
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		if (account == null)
			return new Gee.ArrayList<DB.Entity> ();

		Gee.List<Tax> taxes = (db as Database).get_tax_list (period, account);
		foreach (var tax in taxes) {
//			tax.calc_amount ();
//			tax.calc_total ();
//			tax.persist ();
		}
		return taxes;
	}
}


}
