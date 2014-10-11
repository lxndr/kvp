namespace Kv {


public class TenantTable : DB.ViewTable {
	private AccountPeriod? current_periodic;


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


	protected override Gee.List<DB.Entity> get_entity_list () {
		if (current_periodic == null)
			return new Gee.ArrayList<Tenant> ();
		return (db as Database).get_tenant_list (current_periodic.account);
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
