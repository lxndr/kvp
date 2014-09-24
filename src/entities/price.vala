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


	public override unowned string[] db_keys () {
		const string[] keys = {
			"period",
			"service"
		};
		return keys;
	}


	public override unowned string[] db_fields () {
		const string[] fields = {
			"value",
			"method"
		};
		return fields;
	}


	public string display_name {
		get { return service.name; }
	}


	public override void remove () {}
}


}
