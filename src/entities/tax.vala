namespace Kv {


public class Tax : DB.SimpleEntity, DB.Viewable
{
	public Account account { get; set; }
	public int year { get; set; }
	public int month { get; set; }
	public Service service { get; set; }
	public double amount { get; set; }
	public Money price { get; set; }
	public Money total {get; set; }


	construct {
		year = 2000;
		month = 1;
		total.val = 0;
	}


	public override unowned string db_table () {
		return "taxes";
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
		switch (service.applied_to) {
		case 1:	/* apartment area */
			amount = account.area;
			break;
		case 2:	/* number of people */
			amount = (double) account.number_of_people (year, month);
			break;
		case 3: /* amount is specified */
			break;
		default:
			amount = 1.0;
			break;
		}
	}


	public void calc_total () {
		Period period = { year, month };
		price = Money ((db as Database).get_price (period, service));
		total = Money (Math.llround (amount * (double) price.val));
	}
}


}
