namespace Kv {


public class Tax : Entity
{
	public static string table_name = "taxes";

	public int64 id { get; set; }
	public int month { get; set; }
	public int year { get; set; }
	public Account account { get; set; }
	public Service service { get; set; }
	public int total {get; set; }


	public double amount {
		get { return _get_amount (); }
	}


	public int price {
		get { return _get_price (); }
	}


	construct {
		table_name = "taxes";
		id = 0;
		year = 2000;
		month = 1;
		total = 0;
	}


	public Tax (Period _period, Account _account, Service _service) {
		Object (month: _period.month,
			year: _period.year,
			account: _account,
			service: _service);
	}


	public override string get_display_name () {
		return service.name;
	}


	public double _get_amount () {
		if (service.applied_to == 1) {
			return account.area;
		} else if (service.applied_to == 2) {
			return 1.0;
			//var list = get_account_people ();
			//return (float
		} else {
			return 1.0;
		}
	}


	public int _get_price () {
		return 100;
	}


	public int calc () {
		return (int) (amount * price);
	}


	public override string[] db_keys () {
		return {
			"id"
		};
	}


	public override string[] db_fields () {
		return {
			"month",
			"year",
			"account",
			"service",
			"total"
		};
	}
}


}
