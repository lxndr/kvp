namespace Kv {


public class TenantTable : DB.ViewTable {
	private AccountPeriod? current_periodic;

	private int strikethrough_model_column;
	private int foreground_model_column;


	construct {
/*		const Gtk.TargetEntry[] targets = {
			{ "test", Gtk.TargetFlags.SAME_APP | Gtk.TargetFlags.OTHER_WIDGET, 0 }
		};

		enable_model_drag_dest (targets, Gdk.DragAction.LINK);*/
	}


	public TenantTable (Database _db) {
		Object (db: _db,
				object_type: typeof (Tenant));
	}


	public void setup (AccountPeriod? periodic) {
		current_periodic = periodic;
		refresh_view ();
	}


/*
	protected override DB.Entity? new_entity () {
		return new Tenant (db as Database, current_periodic.account, current_periodic.period);
	}
*/


	protected override unowned string[] viewable_props () {
		const string props[] = {
			N_("name"),
			N_("birthday"),
			N_("relation"),
			N_("move-in"),
			N_("move-out")
		};
		return props;
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
		return (db as Database).get_tenant_list (current_periodic.account);
	}


	protected override void row_refreshed (Gtk.TreeIter tree_iter, DB.Entity entity) {
		unowned Tenant tenant = (Tenant) entity;

		uint month_first_day = Utils.get_month_first_day (current_periodic.period);
		uint month_last_day = Utils.get_month_last_day (current_periodic.period);

		bool moved_out = false;
		var move_out_day = tenant.move_out.get_julian ();
		if (move_out_day > 1 && move_out_day < month_first_day)
			moved_out = true;

		unowned string? color = null;
		var move_in_day = tenant.move_in.get_julian ();
		if (moved_out == true || move_in_day == 1 || move_in_day > month_last_day)
			color = "grey";

		list_store.set (tree_iter,
				foreground_model_column, color,
				strikethrough_model_column, moved_out);
	}


	public void add_tenant (Person person) {
		var n = db.query_count (Tenant.table_name, "account=%d AND person=%d"
				.printf (current_periodic.account.id, person.id));
		if (n > 0)
			return;

		var tenant = new Tenant (db, current_periodic.account, person);
		tenant.persist ();
		refresh_view ();
	}
}


}
