namespace Kv {


public class Tax : DB.Entity, DB.Viewable {
	public static unowned string table_name = "tax";

	public Account account { get; set; }
	public Month period { get; set; }
	public Service service { get; set; }
	public bool apply { get; set; }
	public double amount { get; set; }
	public Money total {get; set; }


	public string service_name {
		get { return service.name; }
	}


	private Price _price;
	public Price price {
		get {
			if (_price == null && account != null && period.raw_value > 0 && service != null)
				_price = service.get_price (account.building, period);
			return _price;
		}
	}


	private AccountPeriod _periodic;
	public AccountPeriod periodic {
		get {
			if (_periodic == null)
				_periodic = account.fetch_period (period);
			return _periodic;
		}
	}


	public Money price_value {
		owned get {
			if (price.calculation == null)
				return new Money ();
			return price.calculation.price (this);
		}
	}


	public override unowned string[] db_keys () {
		const string[] keys = {
			"account",
			"period",
			"service"
		};
		return (string[]) keys;
	}


	public override unowned string[] db_fields () {
		const string[] fields = {
			"apply",
			"amount",
			"total"
		};
		return (string[]) fields;
	}


	construct {
		_total = new Money ();
	}


	public Tax (Database _db, Account _account, Month _period, Service _service) {
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
		if (apply == false) {
			amount = 0.0;
			return;
		}

		if (price.calculation != null)
			amount = price.calculation.amount (this);
	}


	public void calc_total () {
		if (price.calculation != null)
			total = price.calculation.total (this);
	}
}


}
