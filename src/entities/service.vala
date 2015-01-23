namespace Kv {


public class Service : DB.SimpleEntity, DB.Viewable {
	public static unowned string table_name = "service";

	public string name { get; set; }


	public override unowned string[] db_fields () {
		const string[] fields = {
			"name"
		};
		return (string[]) fields;
	}


	public string display_name {
		get { return name; }
	}


	public override void remove () {}


	public Price get_price (Building building, Month period) {
		var q = new DB.Query.select ();
		q.from (Price.table_name);
		q.where (@"building = $(building.id)");
		q.where (@"service = $(id)");
		q.where (@"first_day IS NULL OR first_day <= $(period.last_day.get_days ())");
		q.where (@"last_day IS NULL OR last_day >= $(period.first_day.get_days ())");
		return db.fetch_entity<Price> (q);
	}
}


}
