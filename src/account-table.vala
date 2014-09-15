namespace Kv {


public class AccountTable : DB.TableView {
	private Period current_period;


	public AccountTable (Database dbase) {
		base (dbase, typeof (AccountMonth));

		row_edited.connect (account_edited);

		var menu_item = new Gtk.MenuItem.with_label ("Duplicate");
		menu_item.activate.connect (duplicate_item_clicked);
		menu_item.visible = true;
		popup_menu.add (menu_item);

		menu_item = new Gtk.MenuItem.with_label ("Duplicate for next month");
		menu_item.activate.connect (duplicate_next_month_item_clicked);
		menu_item.visible = true;
		popup_menu.add (menu_item);
	}


	protected override string[] view_properties () {
		return {
			"number",
			"apartment",
			"nrooms",
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

		var account_month = new AccountMonth (db, account, current_period);
		db.persist (account_month);

		return account_month;
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		var list = (db as Database).get_account_month_list (current_period) as Gee.List<AccountMonth>;
		foreach (var a in list)
			a.calc ((db as Database));
		return list;
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


	private void account_edited (DB.Entity ent) {
		db.persist ((ent as AccountMonth).account);
	}


	public void duplicate_item_clicked () {
		var account = get_selected_account ();

		var new_account = new_entity () as AccountMonth;

		var query = "INSERT INTO taxes SELECT NULL,month,year,%lld,service,0 FROM taxes WHERE year=%d AND month=%d AND account=%lld"
				.printf (new_account.account.id, current_period.year, current_period.month, account.id);
		db.exec_sql (query, null);

		update_view ();
	}


	public void duplicate_next_month_item_clicked () {
		var account = get_selected_account ();

		/* copy taxes */
		var query = "INSERT INTO taxes SELECT NULL,%d,%d,%lld,service,0 from taxes where account=%lld and year=%d and month=%d"
				.printf (current_period.month + 1, current_period.year, account.id, account.id, current_period.year, current_period.month);
		db.exec_sql (query, null);

		/* copy people */
		query = "INSERT INTO people SELECT NULL,%d,%d,%lld,name,birthday,relationship from people where account=%lld and year=%d and month=%d"
				.printf (current_period.year, current_period.month + 1, account.id, account.id, current_period.year, current_period.month);
		db.exec_sql (query, null);
	}
}


}
