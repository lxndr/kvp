namespace Kv {


public class AccountTable : DB.TableView {
	private int current_period;


	construct {
		var menu_item = new Gtk.MenuItem.with_label ("Recalculate");
		menu_item.activate.connect (recalculate_clicked);
		menu_item.visible = true;
		popup_menu.add (menu_item);

		menu_item = new Gtk.MenuItem.with_label ("Recalculate this period");
		menu_item.activate.connect (recalculate_period_clicked);
		menu_item.visible = true;
		popup_menu.add (menu_item);
	}


	public AccountTable (Database _db) {
		Object (db: _db,
				object_type: typeof (AccountPeriod));
	}


	protected override unowned string[] view_properties () {
		const string props[] = {
			N_("number"),
			N_("tenant"),
			N_("apartment"),
			N_("n_rooms"),
			N_("area"),
			N_("total"),
			N_("extra"),
			N_("payment"),
			N_("balance")
		};
		return props;
	}


	protected override DB.Entity new_entity () {
		var account = new Account (db);
		db.persist (account);

		var account_period = new AccountPeriod (db, account, current_period);
		db.persist (account_period);

		return account_period;
	}


	protected override void remove_entity (DB.Entity entity) {
		(entity as AccountPeriod).account.remove ();
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		return (db as Database).get_account_month_list (current_period) as Gee.List<AccountPeriod>;
	}


	public Account? get_selected_account () {
		var account_month = get_selected_entity ();
		if (account_month == null)
			return null;

		return (account_month as AccountPeriod).account;
	}


	public void set_period (int period) {
		current_period = period;
	}


	public override void row_edited (DB.Entity entity, string prop_name) {
		var account_period = entity as AccountPeriod;

		if (prop_name == "payment" || prop_name == "extra") {
			account_period.calc_balance ();
			refresh_row (entity);
			entity.persist ();
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
		refresh_row (account_period);
	}


	public void recalculate_period_clicked () {
		var periods = db.fetch_entity_list<AccountPeriod> (AccountPeriod.table_name,
				("period=%d").printf (current_period));
		foreach (var account_period in periods)
			recalculate_period (account_period);
		update_view ();
	}
}


}
