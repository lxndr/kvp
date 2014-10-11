namespace Kv {


public class PeopleTable : DB.ViewTable {
	public signal void add_to_tenants (Person person);


	protected override unowned string[] viewable_props () {
		const string props[] = {
			N_("name"),
			N_("birthday"),
			N_("gender")
		};
		return props;
	}


	construct {
		Gtk.MenuItem mi_separator;

		mi_separator = new Gtk.SeparatorMenuItem ();
		mi_separator.visible = true;
		menu.append (mi_separator);

		var mi = new Gtk.MenuItem.with_label (_("Add to tenants"));
		mi.activate.connect (add_to_tenants_clicked);
		mi.visible = true;
		menu.append (mi);
	}


	public PeopleTable (Database _db) {
		Object (db: _db,
				object_type: typeof (Person));
	}


	protected override void create_list_column (Gtk.TreeViewColumn column, out Gtk.CellRenderer cell,
			ParamSpec prop, int model_column) {
		base.create_list_column (column, out cell, prop, model_column);

		column.sort_column_id = model_column;
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		return db.fetch_entity_list<Person> (Person.table_name);
	}


	public void add_to_tenants_clicked () {
		add_to_tenants (get_selected_entity () as Person);
	}
}


}
