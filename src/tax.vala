namespace Kv {


public class Tax : Entity
{
	public uint8 month { get; set; }
	public uint16 year { get; set; }
	public int64 account { get; set; }
	public int64 service { get; set; }
	public string service_name {get; set; }


	public Tax (Period period, Account account) {
		this.month = period.month;
		this.year = period.year;
		this.account = account.id;
	}


	public override string get_display_name () {
		return "service_name";
	}


	public override string[] db_keys () {
		return {
			"month",
			"year",
			"account",
			"service"
		};
	}


	public override string[] db_fields () {
		return {
			
		};
	}
}


}
