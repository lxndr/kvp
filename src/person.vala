namespace Kv {


public class Person : Entity
{
	public string name { get; set; }
	public string birthday { get; set; }

/*
	public Person () {
		base ();
		name = "000";
		birthday = "000";

		stdout.printf ("%s %s\n", name, birthday);
	}
*/

	construct {
		name = "000";
		birthday = "000";
		
	}


	public override string get_display_name () {
		return name;
	}
}


}
