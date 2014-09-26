namespace Kv {


public class BuildingTable : DB.TableView {
	protected override unowned string[] view_properties () {
		const string props[] = {
			N_("location"),
			N_("street"),
			N_("number")
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