namespace Kv {


public class Service : DB.SimpleEntity, DB.Viewable
{
	public string name { get; set; }


	public static unowned string table_name = "service";
	public override unowned string db_table () {
		return table_name;
	}


	public override unowned string[] db_fields () {
		const string[] fields = {
			"name"
		};
		return fields;
	}


	public string display_name {
		get { return name; }
	}


	public override void remove () {}


	public Price get_price (Building building, int period) {
		return db.fetch_entity<Price> (Price.table_name,
				"building=%d AND period=%d AND service=%d".printf (building.id, period, id));
	}
}


}
