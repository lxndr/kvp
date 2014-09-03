namespace Kv {


public class Tenant : Entity
{
	public uint8 month { get; set; }
	public uint16 year { get; set; }
	public int64 account { get; set; }
	public int64 person { get; set; }
	public int64 person_name { get; set; }
	public int64 person_birthday { get; set; }
	public string relationship { get; set; }


	public Tenant (Period period, Account account, Person person) {
		this.month = period.month;
		this.year = period.year;
		this.account = account.id;
		this.person = person.id;
		this.relationship = "";
	}


	public override string get_display_name () {
		return name;
	}


	public override string[] db_keys () {
		return {
			"month",
			"year",
			"account",
			"person"
		};
	}


	public override string[] db_fields () {
		return {
			"relationship"
		};
	}
}


}
