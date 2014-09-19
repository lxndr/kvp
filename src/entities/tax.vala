namespace Kv {


public class Tax : DB.SimpleEntity, DB.Viewable
{
	public Account account { get; set; }
	public int period { get; set; }
	public Service service { get; set; }
	public double amount { get; set; }
	public Money total {get; set; default = Money (0); }


	public Money price {
		get {
			return service.get_price (period);
		}
	}


	public static unowned string table_name = "tax";
	public override unowned string db_table () {
		return table_name;
	}


	public override string[] db_fields () {
		return {
			"account",
			"period",
			"service",
			"amount",
			"total"
		};
	}


	public Tax (Account _account, int _period, Service _service) {
		Object (account: _account,
				period: _period,
				service: _service);
	}


	public string display_name {
		get { return service.name; }
	}


	public void calc_amount () {
		var account_period = account.fetch_period (period);

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
