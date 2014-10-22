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


	private Price _price;
	public unowned Price price {
		get {
			if (_price == null && account != null && period > 0 && service != null)
				_price = service.get_price (account.building, period);
			return _price;
		}
	}


	private AccountPeriod _periodic;
	public unowned AccountPeriod periodic {
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
			else
				return calculation.get_price ();
		}
	}


	private TaxCalculation? calculation;
	private string? _calc_method;
	public string? calc_method {
		get { return _calc_method; }
		set {
			_calc_method = value;
			calculation = ((Database) db).create_tax_calculation (_calc_method);
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


	public double method_05 (AccountPeriod ap) {
		int[,] n2 = {
			{  0,   0,   0,   0,   0,   0},
			{  0, 143,  89,  69,  56,  49},
			{  0, 168, 104,  81,  66,  57},
			{  0, 184, 114,  88,  72,  63},
			{  0, 196, 121,  94,  76,  67}
		};

		int[,] n4 = {
			{  0,   0,   0,   0,   0,   0},
			{  0, 217, 134, 104,  85,  74},
			{  0, 256, 159, 123, 100,  87},
			{  0, 280, 173, 134, 109,  95},
			{  0, 297, 184, 143, 116, 101}
		};

		int n_rooms = (int) ap.n_rooms.clamp (0, 4);
		int n_people = (int) ap.n_people.clamp (0, 5);

		if (ap.param1 == true)
			return (double) (n4[n_rooms, n_people] * ap.n_people);
		else
			return (double) (n2[n_rooms, n_people] * ap.n_people);
	}


	public double method_06 (AccountPeriod ap) {
		int[,] n1 = {
			{  0,   0,   0,   0,  0,    0},
			{  0,  93,  58,  45,  36,  32},
			{  0, 120,  74,  57,  47,  41},
			{  0, 135,  84,  65,  53,  46},
			{  0, 147,  91,  70,  57,  50}
		};

		double[] k = {
			1.4465,
			1.6206,
			1.2084,
			1.3434,
			1.0214,
			1.0156,
			0.9860,
			1.1038,
			1.0912,
			1.0000,
			1.0000,
			1.0000
		};

		int month = ap.period % 12;
		int n_rooms = (int) ap.n_rooms.clamp (0, 4);
		int n_people = (int) ap.n_people.clamp (0, 5);
//		double kk = Math.round (k[month] * 100.0) / 100.0;
//		return Math.floor (n1[n_rooms, n_people] * ap.n_people * k[month]);
		return Math.round (n1[n_rooms, n_people] * ap.n_people * k[month]);
	}


	public void calc_amount () {
		if (apply == false) {
			amount = 0.0;
			return;
		}

		if (calculation == null)
			amount = 0.0;
		else
			amount = calculation.get_amount ();

#if 0
		switch (price.method) {
		case 1:	/* always x1 */
			amount = 1.0;
			break;
		case 2:	/* area */
			amount = periodic.area * periodic.period_coefficient ();
			break;
		case 3: /* number of people */
		case 7:
			amount = (double) periodic.number_of_people ();
			break;
		case 5:
			amount = method_05 (periodic);
			break;
		case 6:
			amount = method_06 (periodic);
			break;
		default: /* amount is specified */
			break;
		}
#endif
	}


	public void calc_total () {
#if 0
		if (price.method == 0)
			return;
		if (price.method == 7 && periodic.param3 == true) {
			total = Money (Math.llround (amount * (double) price.value2.val));
			return;
		}
		total = Money (Math.llround (amount * (double) price.value.val));
#endif

		if (calculation == null)
			total = Money (0);
		else
			total = calculation.get_total ();
	}
}


}
