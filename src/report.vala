namespace Kv {


public abstract class Report : Object {
	public Database db { get; construct set; }
	public Building? building { get; construct set; }
	public Account? account { get; construct set; }
	public int period { get; construct set; }

	public abstract void make () throws Error;
	public abstract void write (File f) throws Error;
}


}
