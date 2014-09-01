namespace Kv {


public class Application : Gtk.Application
{
	public Application() {
		Object (application_id: "org.lxndr.kvartplata",
				flags: ApplicationFlags.FLAGS_NONE);
	}


	public override void startup () {
		base.startup ();
	}


	public override void activate () {
		var win = new MainWindow (this);
		win.show ();
	}


	public static int main (string[] args) {
		Application app = new Application ();
		return app.run (args);
	}
}


}
