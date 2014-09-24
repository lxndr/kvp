namespace DB {


public abstract class Entity : Object {
	public Database db { get; construct set; }

	public abstract unowned string db_table ();
	public abstract unowned string[] db_keys ();
	public abstract unowned string[] db_fields ();

	public void persist () {
		db.persist (this);
	}


	public abstract void remove ();
}


}
