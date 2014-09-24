namespace Kv {


public class AccountPeriod : DB.Entity, DB.Viewable
{
	public Account account { get; set; }
	public int period { get; set; }
	public string apartment { get; set; }
	public int n_rooms {get; set; default = 1;}
	public double area { get; set; default = 0.0; }
	public Money total { get; set; default = Money (0); }
	public Money payment { get; set; default = Money (0); }
	public Money balance { get; set; default = Money (0); }
	public Money extra { get; set; default = Money (0); }
	public bool param1 { get; set; default = false; }


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
		get {
			_tenant = account.tenant_name (period);
			return _tenant;
		}
	}


	public int n_people {
		get { return (int) number_of_people (); }
	}


	public AccountPeriod (DB.Database _db, Account _account, int _period) {
		Object (db: _db);

		account = _account;
		period = _period;
	}


	public static unowned string table_name = "account_period";
	public override unowned string db_table () {
		return table_name;
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
			"param1"
		};
		return fields;
	}


	public string display_name {
		get { return account.number; }
	}


	public override void remove () {}


	public int64 number_of_people () {
		return db.query_count (Person.table_name,
				("account=%" + int64.FORMAT + " AND period=%d")
				.printf (account.id, period));
	}


	public Money previuos_balance () {
		var n = db.fetch_int64 (AccountPeriod.table_name, "balance",
				("account=%" + int64.FORMAT + " AND period=%d")
				.printf (account.id, period - 1));
		return Money (n);
	}


	public void calc_total () {
		total = Money (db.query_sum (Tax.table_name, "total",
				("account=%" + int64.FORMAT + " AND period=%d")
				.printf (account.id, period)));
	}


	public void calc_balance () {
		var prev = previuos_balance ();
		stdout.printf ("PREVIOUS BALANCE %s\n", prev.format ());
		balance = Money (prev.val + total.val + extra.val - payment.val);
	}


	public string? tenant_name () {
		return db.fetch_string (Person.table_name, "name", ("account=%" +
				int64.FORMAT + " AND period=%d AND relationship=1")
				.printf (account.id, period));
	}


	public Gee.List<Person> get_people () {
		return db.fetch_entity_list<Person> (Person.table_name,
				("account=%" + int64.FORMAT + " AND period=%d")
				.printf (account.id, period));
	}


	public Gee.List<Tax> get_taxes () {
		return db.fetch_entity_list<Tax> (Tax.table_name,
				("account=%" + int64.FORMAT + " AND period=%d")
				.printf (account.id, period));
	}
}


}
