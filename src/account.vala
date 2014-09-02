namespace Kv {


public class Account : Entity
{
	public string number { get; set; }
	public string apartment { get; set; }


	public Account () {
		base ();
		number = "000";
		apartment = "000";
	}


	public override string get_display_name () {
		return number;
	}
}


}
