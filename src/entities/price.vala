namespace Kv {


public class Price : Entity
{
	public Service service { get; set; }
	public int year { get; set; }
	public int month { get; set; }
	public int price { get; set; }


	public override unowned string db_table_name () {
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


	public override string get_display_name () {
		return service.name;
	}
}


}
