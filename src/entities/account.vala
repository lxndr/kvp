namespace Kv {


public class Account : SimpleEntity
{
	public string number { get; set; }
	public string apartment { get; set; }
	public double area { get; set; }

	construct {
		number = "000";
		apartment = "000";
		area = 0.0;
	}


	public override unowned string db_table_name () {
		return "accounts";
	}


	public override string[] db_fields () {
		return {
			"number",
			"apartment",
			"area"
		};
	}


	public override string get_display_name () {
		return number;
	}
}


}
