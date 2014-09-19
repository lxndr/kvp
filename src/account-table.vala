namespace Kv {


public class AccountTable : DB.TableView {
	private Period current_period;


	public AccountTable (Database dbase) {
		base (dbase, typeof (AccountMonth));

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


	protected override string[] view_properties () {
		return {
			"number",
			"apartment",
			"n_rooms",
			"area",
			"total",
			"payment",
			"balance",
			"tenant"
		};
	}


	protected override DB.Entity new_entity () {
		var account = new Account (db);
		db.persist (account);

		var account_month = new AccountMonth (db, account, current_period.year * 12 + current_period.month - 1);
		db.persist (account_month);

		return account_month;
	}


	protected override void remove_entity (DB.Entity entity) {
		(entity as AccountMonth).account.remove ();
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		return (db as Database).get_account_month_list (current_period) as Gee.List<AccountMonth>;
	}


	public Account? get_selected_account () {
		var account_month = get_selected_entity ();
		if (account_month == null)
			return null;

		return (account_month as AccountMonth).account;
	}


	public void set_period (Period period) {
		current_period = period;
	}


	public override void row_edited (DB.Entity entity, string prop_name) {
		var account_period = entity as AccountMonth;

		if (prop_name == "payment") {
			account_period.calc_balance ();
			refresh_row (entity);
		}
	}


	public void duplicate_item_clicked () {
		var account = get_selected_account ();

		var new_account = new_entity () as AccountMonth;

		var query = "INSERT INTO taxes SELECT NULL,%lld,year,month,service,0,0 FROM taxes WHERE year=%d AND month=%d AND account=%lld"
				.printf (new_account.account.id, current_period.year, current_period.month, account.id);
		db.exec_sql (query, null);

		update_view ();
	}


	public void duplicate_next_month_item_clicked () {
		var account = get_selected_account ();

		/* copy taxes */
		var query = "INSERT INTO taxes SELECT NULL,%lld,%d,%d,service,0,0 from taxes where account=%lld and year=%d and month=%d"
				.printf (account.id, current_period.year, current_period.month + 1, account.id, current_period.year, current_period.month);
		db.exec_sql (query, null);

		/* copy people */
		query = "INSERT INTO people SELECT NULL,%lld,%d,%d,name,birthday,relationship from people where account=%lld and year=%d and month=%d"
				.printf (account.id, current_period.year, current_period.month + 1, account.id, current_period.year, current_period.month);
		db.exec_sql (query, null);
	}


	private void recalculate_period (AccountMonth account_month) {
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
		var account_month = get_selected_entity () as AccountMonth;
		recalculate_period (account_month);
		refresh_row (account_month);
	}


	public void recalculate_period_clicked () {
		var periods = db.fetch_entity_list<AccountMonth> (AccountMonth.table_name,
				("period=%d").printf (current_period.year * 12 + current_period.month - 1));
		foreach (var period_month in periods)
			recalculate_period (period_month);
		update_view ();
	}
}


}
