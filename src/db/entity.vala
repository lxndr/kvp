namespace DB {


public abstract class Entity : Object {
	public Database db { get; construct set; }

	public abstract unowned string db_table ();
	public abstract string[] db_keys ();
	public abstract string[] db_fields ();

	public bool changed;


	construct {
		changed = false;

		notify.connect (property_changed);
	}


	private void property_changed (ParamSpec pspec) {
		changed = true;
	}


	public void persist () {
		db.persist (this);
	}
}


}
