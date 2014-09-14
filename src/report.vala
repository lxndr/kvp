namespace Kv {


public abstract class Report : Object {
	public Database db { get; construct set; }
	public Period current_period { get; construct set; }
	public Account? selected_account { get; construct set; }

	public abstract void make () throws Error;
	public abstract void write (File f) throws Error;
}


}
