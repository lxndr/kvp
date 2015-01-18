namespace Kv {


public class ServiceTable : DB.ViewTable {
	protected override unowned string[] viewable_props () {
		const string props[] = {
			N_("id"),
			N_("name")
		};
		return (string[]) props;
	}


	public ServiceTable (Database _db) {
		Object (db: _db,
				object_type: typeof (Service));
	}


	protected override Gtk.Menu? create_menu (bool add_remove = true) {
		return null;
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		var q = new DB.Query.select ();
		q.from (Service.table_name);
		return db.fetch_entity_list<Service> (q);
	}
}


}
