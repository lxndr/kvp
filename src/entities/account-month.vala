namespace Kv {


public class AccountMonth : DB.Entity, DB.Viewable
{
	public Account account { get; set; }
	public int period { get; set; }
	public string apartment { get; set; }
	public int n_rooms {get; set; default = 1;}
	public double area { get; set; default = 0.0; }
	public Money total { get; set; default = Money (0); }
	public Money payment { get; set; default = Money (0); }
	public Money balance { get; set; default = Money (0); }

	public string number {
		get { return account.number; }
		set { account.number = value; }
	}


	private string _tenant;
	public string tenant {
		get {
			_tenant = account.tenant_name (period);
			return _tenant;
		}
	}


	public AccountMonth (DB.Database _db, Account _account, int _period) {
		Object (db: _db);

		account = _account;
		period = _period;
	}


	public static unowned string table_name = "account_period";
	public override unowned string db_table () {
		return table_name;
	}


	public override string[] db_keys () {
		return {
			"account",
			"period"
		};
	}


	public override string[] db_fields () {
		return {
			"apartment",
			"n_rooms",
			"area",
			"total",
			"payment",
			"balance"
		};
	}


	public string display_name {
		get { return account.number; }
	}


	public override void remove () {}


	public int64 number_of_people () {
		return db.query_count ("people",
				("account=%" + int64.FORMAT + " AND year=%d AND month=%d")
				.printf (account.id, period / 12, period % 12 + 1));
	}


	public Money previuos_balance () {
		var n = db.fetch_int64 (AccountMonth.table_name, "balance",
				("account=%" + int64.FORMAT + " AND period=%d")
				.printf (account.id, period - 1));
		return Money (n);
	}


	public void calc_total () {
		total = Money (db.query_sum ("taxes", "total",
				("account=%" + int64.FORMAT + " AND year=%d AND month=%d")
				.printf (account.id, period / 12, period % 12 + 1)));
	}


	public void calc_balance () {
		var prev = previuos_balance ();
		stdout.printf ("PREVIOUS BALANCE %s\n", prev.format ());
		balance = Money (prev.val + total.val - payment.val);
	}
}


}
