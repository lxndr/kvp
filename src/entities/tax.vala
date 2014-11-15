namespace Kv {


public class Tax : DB.Entity, DB.Viewable {
	public Account account { get; set; }
	public Month period { get; set; }
	public Service service { get; set; }
	public bool apply { get; set; }
	public double amount { get; set; }
	public Money total {get; set; default = Money (0); }


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
		get {
			if (calculation == null)
				return Money (0);
			return calculation.get_price ();
		}
	}


	private TaxCalculation? _calculation;
	public TaxCalculation? calculation {
		get {
			if (_calculation == null)
				_calculation = ((Database) db).create_tax_calculation (price.method, this);
			return _calculation;
		}
	}


	public static unowned string table_name = "tax";
	public override unowned string db_table () {
		return table_name;
	}


	public override unowned string[] db_keys () {
		const string[] keys = {
			"account",
			"period",
			"service"
		};
		return keys;
	}


	public override unowned string[] db_fields () {
		const string[] fields = {
			"apply",
			"amount",
			"total"
		};
		return fields;
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

		if (calculation != null)
			amount = calculation.get_amount ();
	}


	public void calc_total () {
		if (calculation != null)
			total = calculation.get_total ();
	}
}


}
