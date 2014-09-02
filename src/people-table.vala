namespace Kv {


public class PeopleTable : TableView {
	public PeopleTable () {
		base (typeof (Person));
	}


	public override void update_view () {
	}


	protected override void create_list_store () {
		list_store = new Gtk.ListStore (3, typeof (Object), typeof (string), typeof (string));
	}
}


}
