namespace Kv {


public class BuildingTable : DB.ViewTable {
	protected override unowned string[] viewable_props () {
		const string props[] = {
			N_("location"),
			N_("street"),
			N_("number"),
			/*N_("first-period"),
			N_("last-period"),
			N_("lock_period")*/
			N_("comment")
		};
		return props;
	}


	public BuildingTable (Database _db) {
		Object (db: _db,
				object_type: typeof (Building));
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		return db.fetch_entity_list<Building> (Building.table_name);
	}
}


}
