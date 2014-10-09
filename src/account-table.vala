namespace Kv {


public class AccountTable : DB.ViewTable {
	private Building? current_building;
	private int current_period;

	private int balance_foreground_model_column;
	private Gtk.MenuItem recalc_menu_item;
	private Gtk.MenuItem recalc_period_menu_item;


	public AccountTable (Database _db) {
		Object (db: _db,
				object_type: typeof (AccountPeriod));
	}


	protected override unowned string[] viewable_props () {
		const string props[] = {
			N_("number"),
//			N_("opened"),
			N_("tenant"),
			N_("apartment"),
			N_("n-rooms"),
			N_("n-people"),
			N_("area"),
			N_("param1"),
			N_("total"),
			N_("extra"),
			N_("payment"),
			N_("balance"),
			N_("comment")
		};
		return props;
	}


	protected override Gtk.Menu? create_menu (bool add_remove = true) {
		var menu = base.create_menu (add_remove);

		Gtk.MenuItem mi = new Gtk.SeparatorMenuItem ();
		menu.append (mi);

		recalc_menu_item = new Gtk.MenuItem.with_label (_("Recalculate"));
		recalc_menu_item.activate.connect (recalculate_clicked);
		recalc_menu_item.visible = true;
		menu.append (recalc_menu_item);

		recalc_period_menu_item = new Gtk.MenuItem.with_label (_("Recalculate this period"));
		recalc_period_menu_item.activate.connect (recalculate_period_clicked);
		recalc_period_menu_item.visible = true;
		menu.append (recalc_period_menu_item);

		return menu;
	}


	protected override void create_list_store (Gee.List<Type> types, Gee.List<unowned ParamSpec> props) {
		base.create_list_store (types, props);

		var last_model_column = types.size;
		balance_foreground_model_column = last_model_column++;
		types.add (typeof (string));
	}


	protected override void create_list_column (Gtk.TreeViewColumn column, out Gtk.CellRenderer cell,
			ParamSpec prop, int model_column) {
		base.create_list_column (column, out cell, prop, model_column);

		if (prop.value_type == typeof (Money))
			cell.set ("xalign", 1.0f);
		if (prop.name == "balance")
			column.add_attribute (cell, "foreground", balance_foreground_model_column);
	}


	protected override DB.Entity? new_entity () {
		if (current_building == null) {
			var msg = new Gtk.MessageDialog (get_toplevel () as Gtk.Window, Gtk.DialogFlags.MODAL,
					Gtk.MessageType.WARNING, Gtk.ButtonsType.OK,
					_("Every account has to be related to a building. Only one building has to be currently selected " +
						"to add a new account. You have selected either all of them or none. Create a building if needed."));
			msg.response.connect ((response_id) => {
				msg.destroy ();
			});
			msg.show ();
			return null;
		}

		var account = new Account (db, current_building);
		account.persist ();
		return new AccountPeriod (db, account, current_period);
	}


	protected override void remove_entity (DB.Entity entity) {
		(entity as AccountPeriod).account.remove ();
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		unowned Database dbase = db as Database;
		return dbase.get_account_period_list (current_building, current_period);
	}


	public unowned AccountPeriod? get_selected () {
		return (AccountPeriod?) get_selected_entity ();
	}


/*
	public Account? get_selected_account () {
		var periodic = get_selected_entity ();
		if (periodic == null)
			return null;

		return ((AccountPeriod) periodic).account;
	}
*/


	public void setup (Building? building, int period) {
		unowned Database dbase = (Database) db;
		current_building = building;
		current_period = period;

		/* refresh lock state */
//		var locked_period = int.parse (dbase.get_setting ("locked_period"));
//		var locked = period <= locked_period;
//		read_only = locked;
//		recalc_menu_item.sensitive = !locked;
//		recalc_period_menu_item.sensitive = !locked;

		refresh_view ();
	}


	protected override void row_refreshed (Gtk.TreeIter tree_iter, DB.Entity entity) {
		unowned AccountPeriod periodic = (AccountPeriod) entity;
		var total = periodic.total.val;
		var balance = periodic.balance.val;

		unowned string? color = null;
		if (balance < 0)
			color = "green";
		else if (balance == 0)
			color = "blue";
		else if (total == 0 && balance > 0)
			color = "red";

		list_store.set (tree_iter,
				balance_foreground_model_column, color);
	}


	public override void row_edited (Gtk.TreeIter tree_iter, DB.Entity entity, string prop_name) {
		unowned AccountPeriod periodic = (AccountPeriod) entity;

		if (prop_name == "payment" || prop_name == "extra") {
			periodic.calc_balance ();
			find_and_refresh_row (entity);
			entity.persist ();
		}

		if (prop_name == "number" || prop_name == "comment") {
			periodic.account.persist ();
		} else {
			base.row_edited (tree_iter, entity, prop_name);
		}
	}


	private void recalculate_period (AccountPeriod account_period) {
		var taxes = (db as Database).get_tax_list (account_period);

		foreach (var tax in taxes) {
			tax.calc_amount ();
			tax.calc_total ();
			tax.persist ();
		}

		account_period.calc_total ();
		account_period.calc_balance ();
		account_period.persist ();
	}


	public void recalculate_clicked () {
		var account_period = get_selected_entity () as AccountPeriod;
		recalculate_period (account_period);
		find_and_refresh_row (account_period);
	}


	public void recalculate_period_clicked () {
		db.begin_transaction ();

		var where = "period=%d".printf (current_period);
		if (current_building != null)
			where += " AND building=%d".printf (current_building.id);

		var periods = db.fetch_entity_list<AccountPeriod> (AccountPeriod.table_name, where);
		foreach (var account_period in periods)
			recalculate_period (account_period);
		refresh_all ();

		db.commit_transaction ();
	}
}


}
