namespace Kv {


public class PriceTable : DB.ViewTable {
	private Building building;


	protected override unowned string[] viewable_props () {
		const string props[] = {
			N_("service"),
			N_("first_day"),
			N_("last_day"),
			N_("method"),
			N_("value1"),
			N_("value2")
		};
		return props;
	}


	public PriceTable (Database _db) {
		Object (db: _db,
				object_type: typeof (Price));
	}


	protected override DB.Entity? new_entity () {
		assert (building != null);
		var service = db.fetch_entity_by_id<Service> (1);
		return new Price (db, building, service);
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		return ((Database) db).get_price_list (building, null, null);
	}


	public void setup (Building _building) {
		building = _building;
		refresh_view ();
	}
}


}
