namespace Kv {


public class Service : DB.SimpleEntity, DB.Viewable
{
	public static unowned string table_name = "service";

	public string name { get; set; }


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


	public Price get_price (Building building, Month period) {
		return db.fetch_entity<Price> (Price.table_name,
				"building = %d AND service = %d AND (first_day IS NULL OR first_day <= %d) AND (last_day IS NULL OR last_day >= %d)"
				.printf (building.id, id, period.last_day.get_days (), period.first_day.get_days ()));
	}
}


}
