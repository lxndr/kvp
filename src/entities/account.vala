namespace Kv {


public class Account : Entity
{
	public static string table_name = "accounts";

	public int64 id { get; set; }
	public string number { get; set; }
	public string apartment { get; set; }
	public double area { get; set; }


	construct {
		table_name = "accounts";
		id = 0;
		number = "000";
		apartment = "000";
	}


	public override string get_display_name () {
		return number;
	}


	public override string[] db_keys () {
		return {
			"id"
		};
	}


	public override string[] db_fields () {
		return {
			"number",
			"apartment",
			"area"
		};
	}
}


}
