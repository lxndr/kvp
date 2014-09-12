namespace Kv {


public class Person : SimpleEntity
{
	public Account account { get; set; }
	public int year { get; set; }
	public int month { get; set; }
	public string name { get; set; }
	public string birthday { get; set; }
	public string relationship { get; set; }


	construct {
		name = "000";
		birthday = "000";
	}


	public override unowned string db_table_name () {
		return "people";
	}


	public override string[] db_fields () {
		return {
			"year",
			"month",
			"account",
			"name",
			"birthday",
			"relationship"
		};
	}


	public Person (Period _period, Account _account, string _name) {
		Object (year: _period.year,
				month: _period.month,
				account: _account,
				name: _name);
	}


	public override string get_display_name () {
		return name;
	}
}


}
