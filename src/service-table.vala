namespace Kv {


public class ServiceTable : DB.ViewTable {
	protected override unowned string[] viewable_props () {
		const string props[] = {
			N_("id"),
			N_("name")
		};
		return props;
	}


	public ServiceTable (Database _db) {
		Object (db: _db,
				object_type: typeof (Service));
	}


	protected override Gtk.Menu? create_menu (bool add_remove = true) {
		return null;
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		return db.fetch_entity_list<Service> (Service.table_name);
	}
}


}
