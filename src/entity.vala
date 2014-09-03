namespace Kv {


public abstract class Entity : Object {
	public string table_name;

	public abstract string get_display_name ();
	public abstract string[] db_keys ();
	public abstract string[] db_fields ();
}


}
