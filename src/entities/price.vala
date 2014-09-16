namespace Kv {


public class Price : DB.Entity
{
	public Service service { get; set; }
	public int year { get; set; }
	public int month { get; set; }
	public Money price { get; set; }


	public override unowned string db_table () {
		return "prices";
	}


	public override string[] db_keys () {
		return {
			"service",
			"year",
			"month"
		};
	}


	public override string[] db_fields () {
		return {
			"val"
		};
	}


	public string display_name {
		get { return service.name; }
	}


	public override void remove () {}
}


}
