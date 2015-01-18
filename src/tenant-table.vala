namespace Kv {


public class TenantTable : DB.ViewTable {
	private AccountPeriod? current_periodic;

	private int strikethrough_model_column;
	private int foreground_model_column;


	public TenantTable (Database _db) {
		Object (db: _db,
				object_type: typeof (Tenant));
	}


	public void setup (AccountPeriod? periodic) {
		current_periodic = periodic;
		refresh_view ();
	}


	protected override DB.Entity? new_entity () {
		var person = new Person (db);
		person.persist ();
		return new Tenant (db, current_periodic.account, person);
	}


	protected override unowned string[] viewable_props () {
		const string props[] = {
			N_("name"),
			N_("birthday"),
			N_("relation"),
			N_("move-in"),
			N_("move-out")
		};
		return (string[]) props;
	}


	protected override void create_list_store (Gee.List<Type> types, Gee.List<unowned ParamSpec> props) {
		base.create_list_store (types, props);

		var last_model_column = types.size;
		foreground_model_column = last_model_column++;
		types.add (typeof (string));
		strikethrough_model_column = last_model_column++;
		types.add (typeof (bool));
	}


	protected override void create_list_column (Gtk.TreeViewColumn column, out Gtk.CellRenderer cell,
			ParamSpec prop, int model_column) {
		base.create_list_column (column, out cell, prop, model_column);

		if (cell is Gtk.CellRendererText)
			column.add_attribute (cell, "foreground", foreground_model_column);
		if (prop.name == "name")
			column.add_attribute (cell, "strikethrough", strikethrough_model_column);
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		if (current_periodic == null)
			return new Gee.ArrayList<Tenant> ();
		return current_periodic.account.get_tenant_list ();
	}


	protected override void row_refreshed (Gtk.TreeIter tree_iter, DB.Entity entity) {
		unowned Tenant tenant = (Tenant) entity;

		var first_day = current_periodic.period.first_day;
		var last_day = current_periodic.period.last_day;

		bool moved_out = false;
		if (tenant.move_out != null && tenant.move_out.compare (first_day) < 0)
			moved_out = true;

		unowned string? color = null;
		if (moved_out == true || tenant.move_in == null || tenant.move_in.compare (last_day) > 0)
			color = "grey";

		list_store.set (tree_iter,
				foreground_model_column, color,
				strikethrough_model_column, moved_out);
	}


	public override void row_edited (Gtk.TreeIter tree_iter, DB.Entity entity, string prop_name) {
		unowned Tenant tenant = (Tenant) entity;

		if (prop_name == "name" || prop_name == "birthday") {
			tenant.person.persist ();
		} else {
			base.row_edited (tree_iter, entity, prop_name);
		}
	}


	public void add_tenant (Person person) {
/*		var n = db.query_count (Tenant.table_name, "account = %d AND person = %d"
				.printf (current_periodic.account.id, person.id));
		if (n > 0)
			return;
*/
		var tenant = new Tenant (db, current_periodic.account, person);
		tenant.persist ();
		refresh_view ();
	}
}


}
