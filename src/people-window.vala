namespace Kv {


public class PeopleWindow : Gtk.Window, SingletonWindow {
	private PeopleTable view_table;


	public signal void add_to_tenants (Person person);


	construct {
		title = _("Reference - People");
		default_width = 500;
		default_height = 300;

		view_table = new PeopleTable (get_database ());
		view_table.refresh_view ();
		view_table.add_to_tenants.connect ((person) => {
			add_to_tenants (person);
		});

		var scrolled = new Gtk.ScrolledWindow (null, null);
		scrolled.add (view_table);
		scrolled.show_all ();

		add (scrolled);
	}


	public PeopleWindow (Gtk.Window parent) {
		Object (type: Gtk.WindowType.TOPLEVEL,
				transient_for: parent,
				default_width: 500,
				default_height: 300,
				window_position: Gtk.WindowPosition.CENTER_ON_PARENT);
	}
}


}
