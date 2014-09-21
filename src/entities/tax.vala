namespace Kv {


public class Tax : DB.Entity, DB.Viewable
{
	public Account account { get; set; }
	public int period { get; set; }
	public Service service { get; set; }
	public bool apply { get; set; }
	public double amount { get; set; }
	public Money total {get; set; default = Money (0); }


	public string service_name {
		get { return service.name; }
	}


	public Money price {
		get {
			return service.get_price (period);
		}
	}


	public static unowned string table_name = "tax";
	public override unowned string db_table () {
		return table_name;
	}


	public override string[] db_keys () {
		return {
			"account",
			"period",
			"service"
		};
	}


	public override string[] db_fields () {
		return {
			"apply",
			"amount",
			"total"
		};
	}


	public Tax (Database _db, Account _account, int _period, Service _service) {
		Object (db: _db,
				account: _account,
				period: _period,
				service: _service);
	}


	public override void remove () {}


	public string display_name {
		get { return service.name; }
	}


	public void calc_amount () {
		var account_period = account.fetch_period (period);

		if (apply == false) {
			amount = 0.0;
			return;
		}

		switch (service.applied_to) {
		case 1:	/* always x1 */
			amount = 1.0;
			break;
		case 2:	/* area */
			amount = account_period.area;
			break;
		case 3: /* number of people */
			amount = (double) account_period.number_of_people ();
			break;
		default: /* amount is specified */
			break;
		}
	}


	public void calc_total () {
		total = Money (Math.llround (amount * (double) price.val));
	}
}


}
