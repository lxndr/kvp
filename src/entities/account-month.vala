namespace Kv {


public class AccountMonth : DB.Entity, DB.Viewable
{
	public Account account { get; set; }
	public int year { get; set; }
	public int month { get; set; }
	public Money total { get; set; }
	public Money payment { get; set; }
	public Money balance { get; set; }

	public string number {
		get { return account.number; }
		set { account.number = value; }
	}

	public string apartment {
		get { return account.apartment; }
		set { account.apartment = value; }
	}

	public int nrooms {
		get { return account.nrooms; }
		set { account.nrooms = value; }
	}

	public double area {
		get { return account.area; }
		set { account.area = value; }
	}


	private string _tenant;
	public string tenant {
		get {
			_tenant = account.tenant_name (year, month);
			return _tenant;
		}
	}


	construct {
		total.val = 0;
		payment.val = 0;
		balance.val = 0;
	}


	public AccountMonth (DB.Database _db, Account _account, Period _period) {
		Object (db: _db);

		account = _account;
		year = _period.year;
		month = _period.month;
	}


	public override unowned string db_table () {
		return "account_month";
	}


	public override string[] db_keys () {
		return {
			"account",
			"year",
			"month"
		};
	}


	public override string[] db_fields () {
		return {
			"total",
			"payment",
			"balance"
		};
	}


	public string display_name {
		get { return account.number; }
	}


	public override void remove () {}


	public void calc (Database db) {
		/* calculate total */
		total.val = 0;
		var query = "SELECT SUM(total) FROM taxes WHERE account=%lld AND year=%d AND month=%d"
				.printf (account.id, year, month);
		db.exec_sql (query, (n_columns, values, column_names) => {
			if (values[0] != null)
				total = Money (int64.parse (values[0]));
			return 0;
		});

		/* previous balance */
		int64 previous_balance = 0;
		Period current_period = {year, month};
		var prev_period = current_period.prev ();
		query = "SELECT balance FROM account_month WHERE account=%lld AND year=%d AND month=%d"
				.printf (account.id, prev_period.year, prev_period.month); /* FIXME */
		db.exec_sql (query, (n_columns, values, column_names) => {
			if (values[0] != null)
				previous_balance = int64.parse (values[0]);
			return 0;
		});

// stdout.printf ("PREV %d.%d BALANCE %d\n", prev_period.year, prev_period.month, previous_balance);

		/* calculate balance */
		if (year == 2014)	/* FIXME */
			balance = Money (previous_balance + total.val - payment.val);

		db.persist (this);
	}
}


}
