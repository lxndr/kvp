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
		var q = new DB.Query.select ();
		q.from (Building.table_name);
		return db.fetch_entity_list<Building> (q);
	}
}


}
