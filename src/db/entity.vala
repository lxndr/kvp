namespace Kv {


public abstract class Entity : Object {
	public abstract unowned string db_table_name ();
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


	public abstract string get_display_name ();
}


}
