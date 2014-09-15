namespace Kv {


public class AccountTable : DB.TableView {
	private Period current_period;


	public AccountTable (Database dbase) {
		base (dbase, typeof (AccountMonth));

		row_edited.connect (account_edited);
	}


	protected override string[] view_properties () {
		return {
			"number",
			"apartment",
			"area",
			"total",
			"payment",
			"balance"
		};
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
}


}
