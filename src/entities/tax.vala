namespace Kv {


public class Tax : SimpleEntity
{
	public Account account { get; set; }
	public int year { get; set; }
	public int month { get; set; }
	public Service service { get; set; }
	public double amount { get; set; }
	public int price { get; set; }
	public int total {get; set; }


	construct {
		year = 2000;
		month = 1;
		total = 0;
	}


	public override unowned string db_table_name () {
		return "taxes";
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


	public Tax (Period _period, Account _account, Service _service) {
		Object (year: _period.year,
				month: _period.month,
				account: _account,
				service: _service);
	}


	public override string get_display_name () {
		return service.name;
	}


	public void calc (Database db) {
			Period period = { year, month };

			switch (service.applied_to) {
			case 1:	/* apartment area */
				amount = account.area;
				break;
			case 2:	/* number of people */
				
				amount = (double) db.get_people_list (period, account).size;
				break;
			default:
				amount = 1.0;
				break;
			}

			price = db.get_price (period, service);
			total = (int) (amount * (double) price);
			db.persist (this);
	}
}


}
