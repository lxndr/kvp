namespace Kv {


public class AccountTable : DB.TableView {
	private int current_period;


	public AccountTable (Database dbase) {
		base (dbase, typeof (AccountPeriod));

		var menu_item = new Gtk.MenuItem.with_label ("Duplicate");
		menu_item.activate.connect (duplicate_item_clicked);
		menu_item.visible = true;
		popup_menu.add (menu_item);

		menu_item = new Gtk.MenuItem.with_label ("Duplicate for next month");
		menu_item.activate.connect (duplicate_next_month_item_clicked);
		menu_item.visible = true;
		popup_menu.add (menu_item);

		menu_item = new Gtk.MenuItem.with_label ("Recalculate");
		menu_item.activate.connect (recalculate_clicked);
		menu_item.visible = true;
		popup_menu.add (menu_item);

		menu_item = new Gtk.MenuItem.with_label ("Recalculate this period");
		menu_item.activate.connect (recalculate_period_clicked);
		menu_item.visible = true;
		popup_menu.add (menu_item);
	}


	protected override unowned string[] view_properties () {
		const string props[] = {
			N_("number"),
			N_("apartment"),
			N_("n_rooms"),
			N_("area"),
			N_("total"),
			N_("payment"),
			N_("balance"),
			N_("tenant")
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

		if (prop_name == "payment") {
			account_period.calc_balance ();
			refresh_row (entity);
		}
	}


	public void duplicate_item_clicked () {
		var account = get_selected_account ();

		var new_account = new_entity () as AccountPeriod;

		var query = "INSERT INTO tax SELECT NULL,%lld,period,service,0,0 FROM tax WHERE period=%d AND account=%lld"
				.printf (new_account.account.id, current_period, account.id);
		db.exec_sql (query, null);

		update_view ();
	}


	public void duplicate_next_month_item_clicked () {
		var account = get_selected_account ();

		/* copy taxes */
		var query = "INSERT INTO tax SELECT NULL,%lld,%d,service,0,0 from taxes where account=%lld and period=%d"
				.printf (account.id, current_period + 1, account.id, current_period);
		db.exec_sql (query, null);

		/* copy people */
		query = "INSERT INTO people SELECT NULL,%lld,%d,name,birthday,relationship from people where account=%lld and period=%d"
				.printf (account.id, current_period + 1, account.id, current_period);
		db.exec_sql (query, null);
	}


	private void recalculate_period (AccountPeriod account_month) {
		var taxes = db.fetch_entity_list<Tax> (Tax.table_name,
				("account=%" + int64.FORMAT + " AND year=%d AND month=%d")
				.printf (account_month.account.id, account_month.period / 12, account_month.period % 12 + 1));

		foreach (var tax in taxes) {
			tax.calc_amount ();
			tax.calc_total ();
			tax.persist ();
		}

		account_month.calc_total ();
		account_month.calc_balance ();
		account_month.persist ();
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
