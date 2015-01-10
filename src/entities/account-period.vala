namespace Kv {


public class AccountPeriod : DB.Entity, DB.Viewable {
	public static unowned string table_name = "account_period";

	public Account account { get; set; }
	public Month period { get; set; }
	public string apartment { get; set; default = ""; }
	public int n_rooms { get; set; default = 1; }
	public double area { get; set; default = 0.0; }
	public Money total { get; set; }
	public Money payment { get; set; }
	public Money balance { get; set; }
	public Money extra { get; set; }
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
		get { _tenant = main_tenants_names (); return _tenant; }
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


	construct {
		_total = new Money ();
		_payment = new Money ();
		_balance = new Money ();
		_extra = new Money ();
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


	public int number_of_people () {
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
		balance.assign (previuos_balance ())
			.add (total).add (extra).sub (payment);
	}

#if 0
	public string? main_tenant_name () {
		var q = new DB.Query.select ("name");
		q.from ("person JOIN tenant ON tenant.person=person.id");
		q.where ("account = %d AND relation = 1".printf (account.id));
		return db.fetch_string (q, null);
	}
#endif

	public string? main_tenants_names () {
		var q = new DB.Query.select ("name");
		q.from (Tenant.table_name);
		q.join (Person.table_name)
			.on (@"$(Person.table_name).id = $(Tenant.table_name).person");
		q.where (@"relation = 1");
		q.where (@"account = $(account.id)");
		var names = db.fetch_value_list<string> (q);

		var sb = new StringBuilder.sized (64);
		foreach (var name in names) {
			if (sb.len > 0)
				sb.append (", ");
			sb.append (Utils.shorten_person_name (name, false));
		}

		return sb.str;
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
