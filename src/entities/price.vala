namespace Kv {


public class Price : DB.Entity
{
	public Service service { get; set; }
	public int period { get; set; }
	public Money value { get; set; }
	public int method { get; set; }


	public static unowned string table_name = "price";
	public override unowned string db_table () {
		return table_name;
	}


	public override string[] db_keys () {
		return {
			"period",
			"service"
		};
	}


	public override string[] db_fields () {
		return {
			"value",
			"method"
		};
	}


	public string display_name {
		get { return service.name; }
	}


	public override void remove () {}
}


}
