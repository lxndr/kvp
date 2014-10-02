namespace Kv {


public abstract class Report : Object {
	public Gtk.Window toplevel_window { get; construct set; }
	public Database db { get; construct set; }
	public Building? building { get; construct set; }
	public AccountPeriod selected_account { get; construct set; }


	public virtual bool prepare () {
		return true;
	}


	public abstract void make () throws Error;
	public abstract void write (File f) throws Error;
}


}
