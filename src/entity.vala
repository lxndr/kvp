namespace Kv {


public abstract class Entity : Object {
	public int64 id;


	public Entity () {
		id = 0;
	}


	public abstract string get_display_name ();
}


}
