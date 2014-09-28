namespace Kv {


public class PriceTable : DB.ViewTable {
	protected override unowned string[] viewable_props () {
		const string props[] = {
			N_("service_name"),
			N_("value"),
			N_("method")
		};
		return props;
	}


	public PriceTable (Database _db) {
		Object (db: _db,
				object_type: typeof (Price));
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		return db.fetch_entity_list<Price> (Price.table_name);
	}
}


}
