namespace Kv {


public class AccountMonth : DB.Entity
{
	public Account account { get; set; }
	public int year { get; set; }
	public int month { get; set; }
	public int total { get; set; }
	public int payment { get; set; }
	public int balance { get; set; }

	public string number {
		get { return account.number; }
		set { account.number = value; }
	}

	public string apartment {
		get { return account.apartment; }
		set { account.apartment = value; }
	}

	public double area {
		get { return account.area; }
		set { account.area = value; }
	}


	construct {
		total = 0;
		payment = 0;
		balance = 0;
	}


	public AccountMonth (Account _account, Period _period) {
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


	public void calc (Database db) {
		/* calculate total */
		total = 0;
		var query = "SELECT SUM(total) FROM taxes WHERE account=%lld AND year=%d AND month=%d"
				.printf (account.id, year, month);
		db.exec_sql (query, (n_columns, values, column_names) => {
			if (values[0] != null)
				total = (int) int64.parse (values[0]);
			return 0;
		});

		/* previous balance */
		int previous_balance = 0;
		query = "SELECT balance FROM account_month WHERE account=%lld AND year=%d AND month=%d"
				.printf (account.id, year-1, 12); /* FIXME */
		db.exec_sql (query, (n_columns, values, column_names) => {
			if (values[0] != null)
				previous_balance = (int) int64.parse (values[0]);
			return 0;
		});

stdout.printf ("PREV BALANCE %d\n", previous_balance);

		/* calculate balance */
		if (year == 2014)	/* FIXME */
			balance = previous_balance + total - payment;

		db.persist (this);
	}
}


}
