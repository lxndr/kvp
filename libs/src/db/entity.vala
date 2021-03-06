namespace DB {


public abstract class Entity : Object {
	public Database db { get; construct set; }


	public unowned string db_table () {
		return db.find_entity_spec (get_type ()).table_name;
	}


	public abstract unowned string[] db_keys ();
	public abstract unowned string[] db_fields ();

	public void persist () {
		db.persist (this);
	}


	public abstract void remove ();
}


public class EntitySpec {
	public Type type;
	public string table_name;


	public EntitySpec (Type _type, string _table_name) {
		type = _type;
		table_name = _table_name;
	}
}


}
