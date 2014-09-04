namespace Kv {


public class Tax : Entity
{
	public int64 id { get; set; }
	public int month { get; set; }
	public int year { get; set; }
	public int64 account { get; set; }
	public Service service { get; set; }
	public string service_name {get; set; }
	public int total {get; set; }


	construct {
		table_name = "taxes";
	}


	public Tax (Period _period, Account _account) {
		Object (month: _period.month,
			year: _period.year,
			account: _account.id,
			service: new Service ());
	}


	public override string get_display_name () {
		return service.name;
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
