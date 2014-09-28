namespace Kv {


public class AccountTable : DB.ViewTable {
	private Building? building;
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
			N_("tenant"),
			N_("apartment"),
			N_("n_rooms"),
			N_("n_people"),
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


	protected override DB.Entity new_entity () {
		var account = new Account (db, building);
		db.persist (account);

		var account_period = new AccountPeriod (db, account, current_period);
		db.persist (account_period);

		return account_period;
	}


	protected override void remove_entity (DB.Entity entity) {
		(entity as AccountPeriod).account.remove ();
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		if (building == null)
			return new Gee.ArrayList<AccountPeriod> ();
		return (db as Database).get_account_period_list (building, current_period);
	}


	public Account? get_selected_account () {
		var account_month = get_selected_entity ();
		if (account_month == null)
			return null;

		return (account_month as AccountPeriod).account;
	}


	public void set_period (int period) {
		current_period = period;
		var locked_period = int.parse ((db as Database).get_setting ("locked_period"));

		var locked = period <= locked_period;
		read_only = locked;
		recalc_menu_item.sensitive = !locked;
		recalc_period_menu_item.sensitive = !locked;
	}


	public void set_building (Building _building) {
		building = _building;
	}


	protected override void row_refreshed (Gtk.TreeIter tree_iter, DB.Entity entity) {
		unowned AccountPeriod account_period = entity as AccountPeriod;

		unowned string? color = null;
		var balance = account_period.balance;
		if (balance.val < 0)
			color = "green";
		else if (balance.val == 0)
			color = "blue";
		else if (account_period.total.val == 0 && balance.val > 0)
			color = "red";

		list_store.set (tree_iter,
				balance_foreground_model_column, color);
	}


	public override void row_edited (DB.Entity entity, string prop_name) {
		var account_period = entity as AccountPeriod;

		if (prop_name == "payment" || prop_name == "extra") {
			account_period.calc_balance ();
			find_and_refresh_row (entity);
			entity.persist ();
		}

		if (prop_name == "number" || prop_name == "comment") {
			account_period.account.persist ();
		}
	}


	private void recalculate_period (AccountPeriod account_period) {
		var taxes = (db as Database).get_tax_list (account_period.account, account_period.period);

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

		var periods = db.fetch_entity_list<AccountPeriod> (AccountPeriod.table_name,
				("period=%d").printf (current_period));
		foreach (var account_period in periods)
			recalculate_period (account_period);
		refresh_all ();

		db.commit_transaction ();
	}
}


}
