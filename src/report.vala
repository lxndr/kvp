namespace Kv {


public interface Report : Object {
	public abstract void make (Database db, Period period) throws Error;
	public abstract void write (File f) throws Error;
}


}
