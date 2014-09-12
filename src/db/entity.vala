namespace Kv {


public abstract class Entity : Object {
	public class unowned string table_name;
	public class unowned string[] db_keys;
	public class unowned string[] db_fields;

	public abstract string get_display_name ();
}


}
