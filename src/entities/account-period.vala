namespace Kv {


public class AccountPeriod : DB.Entity, DB.Viewable {
	public static string table_name = "account_period";

	public Account account { get; set; }
	public Month period { get; set; }
	public string apartment { get; set; default = ""; }
	public int n_rooms { get; set; default = 1; }
	public double area { get; set; default = 0.0; }
	public Money total { get; set; default = Money (0); }
	public Money payment { get; set; default = Money (0); }
	public Money balance { get; set; default = Money (0); }
	public Money extra { get; set; default = Money (0); }
	public bool param1 { get; set; default = false; }	/* water heater */
	public bool param2 { get; set; default = false; }	/* electric oven */
	public bool param3 { get; set; default = false; }	/* shower */


	public string number {
		get { return account.number; }
		set { account.number = value; }
	}


	public string comment {
		get { return account.comment; }
		set { account.comment = value; }
	}


	private string _tenant;
	public string tenant {
		get { _tenant = main_tenant_name (); return _tenant; }
	}


	public Date? opened {
		get { return account.opened; }
		set { account.opened = value; }
	}


	public Date? closed {
		get { return account.closed; }
		set { account.closed = value; }
	}


	public int n_people {
		get { return (int) number_of_people (); }
	}


	public AccountPeriod (DB.Database _db, Account _account, Month _period) {
		Object (db: _db,
				account: _account,
				period: _period);
	}


	public override unowned string[] db_keys () {
		const string[] keys = {
			"account",
			"period"
		};
		return keys;
	}


	public override unowned string[] db_fields () {
		const string[] fields = {
			"apartment",
			"n_rooms",
			"area",
			"total",
			"payment",
			"balance",
			"extra",
			"param1",
			"param2",
			"param3"
		};
		return fields;
	}


	public string display_name {
		get { return account.number; }
	}


	public override void remove () {}


	public int64 number_of_people () {
		var first_day = period.first_day;
		var last_day = period.last_day;
		Date.clamp_range (ref first_day, ref last_day, account.opened, account.closed);

		if (last_day == null)
			return 0;

		return db.query_count (Tenant.table_name,
				"account = %d AND move_in IS NOT NULL AND move_in <= %d AND (move_out IS NULL OR move_out >= %d)"
				.printf (account.id, last_day.get_days (), last_day.get_days ()));
	}


	public Money previuos_balance () {
		var q = new DB.Query.select ("balance");
		q.from (AccountPeriod.table_name);
		q.where ("account = %d AND period = %d".printf (account.id, period.get_prev ().raw_value));
		return db.fetch_value<Money> (q, new Money ());
	}


	public void calc_total () {
		var q = new DB.Query.select ("SUM(total)");
		q.from (Tax.table_name);
		q.where ("account = %d AND period = %d".printf (account.id, period.raw_value));
		total = db.fetch_value<Money> (q, new Money ());
	}


	public void calc_balance () {
		var prev = previuos_balance ();
		balance = Money (prev.val + total.val + extra.val - payment.val);
	}


	public string? main_tenant_name () {
		var q = new DB.Query.select ("name");
		q.from ("person JOIN tenant ON tenant.person=person.id");
		q.where ("account = %d AND relation = 1".printf (account.id));
		return db.fetch_string (q, null);
	}


	public Gee.List<Tenant> get_tenant_list () {
		return ((Database) db).get_tenant_list (account, period);
	}


	public Gee.List<Tax> get_taxes () {
		var q = new DB.Query.select ();
		q.from (Tax.table_name);
		q.where ("account = %d AND period = %d".printf (account.id, period.raw_value));
		return db.fetch_entity_list<Tax> (q);
	}
}


}
