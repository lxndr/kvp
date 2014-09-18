namespace Kv {


public class Tax : DB.SimpleEntity, DB.Viewable
{
	public Account account { get; set; }
	public int year { get; set; }
	public int month { get; set; }
	public Service service { get; set; }
	public double amount { get; set; }
	public Money total {get; set; }


	public Money price {
		get {
			return service.get_price (year * 12 + month - 1);
		}
	}


	construct {
		year = 2000;
		month = 1;
		total.val = 0;
	}


	public static unowned string table_name = "taxes";
	public override unowned string db_table () {
		return table_name;
	}


	public override string[] db_fields () {
		return {
			"account",
			"year",
			"month",
			"service",
			"amount",
			"total"
		};
	}


	public Tax (Period _period, Account _account, Service _service) {
		Object (year: _period.year,
				month: _period.month,
				account: _account,
				service: _service);
	}


	public string display_name {
		get { return service.name; }
	}


	public void calc_amount () {
		var account_period = account.fetch_period (year * 12 + month - 1);

		switch (service.applied_to) {
		case 1:	/* apartment area */
			amount = account_period.area;
			break;
		case 2:	/* number of people */
			amount = (double) account_period.number_of_people ();
			break;
		case 3: /* amount is specified */
			break;
		default:
			amount = 1.0;
			break;
		}
	}


	public void calc_total () {
		total = Money (Math.llround (amount * (double) price.val));
	}
}


}
