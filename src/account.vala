namespace Kv {


public class Account : Entity
{
	public int64 id { get; set; }
	public string number { get; set; }
	public string apartment { get; set; }


	construct {
		id = 0;
		number = "000";
		apartment = "000";
	}


	public override string get_display_name () {
		return number;
	}


	public override string[] get_view_properties () {
		string[] properties = {
			"number",
			"apartment"
		};

		return properties;
	}
}


}
