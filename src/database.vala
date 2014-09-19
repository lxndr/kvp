namespace Kv {


public errordomain DatabaseError {
	OPENING_FAILED,
	EXEC_FAILED
}


public class Database : DB.SQLiteDatabase {
	public Database () throws Error {
		Object (path: "./kvartplata.db");

		/* prepare the database */
		var bytes = resources_lookup_data ("/data/init.sql", ResourceLookupFlags.NONE);
		unowned uint8[] data = bytes.get_data ();
//		exec_sql ((string) data);
	}


	public string? get_setting (string key) {
		var query = "SELECT value FROM settings WHERE key='%s'".printf (key);
		string? val = null;

		exec_sql (query, (n_columns, values, column_names) => {
			val = values[0];
			return 0;
		});

		return val;
	}


	public void set_setting (string key, string val) {
		var query = "REPLACE INTO settings VALUES ('%s', '%s')".printf (key, val);
		exec_sql (query);
	}


	public Gee.Map<int, int64?> fetch_int_int64_map (string table, string key_field,
			string value_field, string? where = null) {
		var sb = new StringBuilder ();
		sb.append_printf ("SELECT %s,%s FROM %s", key_field, value_field, table);

		if (where != null)
			sb.append_printf (" WHERE %s", where);

		var map = new Gee.HashMap<int, int64?> ();
		exec_sql (sb.str, (n_columns, values, column_names) => {
			int @key = (int) int64.parse (values[0]);
			int64 @value = int64.parse (values[1]);
			map.set (@key, @value);
			return 0;
		});
		return map;
	}


	public Gee.Map<int64?, T> fetch_int64_entity_map<T> (string table, string key_field,
			string? where = null) {
		var list = fetch_entity_list<DB.Entity> (table, where);
		var map = new Gee.HashMap<int64?, T> ();
		foreach (var item in list) {
			var key_val = Value (typeof (int64));
			item.get_property (key_field, ref key_val);
			map[key_val.get_int ()] = item;
		}
		return map;
	}


	public bool is_empty_period (Period period) {
		string query;
		bool result = true;

		/* check if we've got any people */
		query = "SELECT COUNT(*) FROM people WHERE year=%d AND month=%d"
				.printf (period.year, period.month);
		exec_sql (query, (n_columns, values, column_names) => {
			if (int64.parse (values[0]) > 0)
				result = false;
			return 0;
		});

		if (result == false)
			return result;

		/* check if we've got any taxes */
		query = "SELECT COUNT(*) FROM taxes WHERE year=%d AND month=%d"
				.printf (period.year, period.month);
		exec_sql (query, (n_columns, values, column_names) => {
			if (int64.parse (values[0]) > 0)
				result = false;
			return 0;
		});

		if (result == false)
			return result;

		return true;
	}


	public Gee.List<Service> get_service_list () {
		return get_entity_list (typeof (Service), "SELECT * FROM services") as Gee.List<Service>;
	}


	public Gee.List<Account> get_account_list () {
		return get_entity_list (typeof (Account), "SELECT * FROM account") as Gee.List<Account>;
	}


	public Gee.List<AccountMonth> get_account_month_list (Period period) {
		var months = new Gee.ArrayList<AccountMonth> ();
		var accounts = get_account_list ();

		foreach (var account in accounts) {
			var query = "SELECT * FROM account_period WHERE account=%lld AND period=%d"
					.printf (account.id, period.year * 12 + period.month - 1);
			var list = get_entity_list (typeof (AccountMonth), query) as Gee.List<AccountMonth>;
			if (list.size == 0)
				months.add (new AccountMonth (this, account, period.year * 12 + period.month - 1));
			else
				months.add (list[0]);
		}

		return months;
	}


	public Gee.List<Person> get_people_list (Period period, Account account) {
		var query = "SELECT * FROM people WHERE year=%d AND month=%d AND account=%lld"
				.printf (period.year, period.month, account.id);
		return get_entity_list (typeof (Person), query) as Gee.List<Person>;
	}


	public Gee.List<Tax> get_tax_list (Period period, Account account) {
		var query = "SELECT * FROM taxes WHERE year=%d AND month=%d AND account=%lld"
				.printf (period.year, period.month, account.id);
		return get_entity_list (typeof (Tax), query) as Gee.List<Tax>;
	}


	public Gee.Map<uint, Tax> find_taxes_by_service_id (Period period, Account account, int64 service_id) {
		var query = "SELECT * FROM taxes WHERE year=%u AND account=%lld AND service=%lld ORDER BY month"
				.printf (period.year, account.id, service_id);
		var list = get_entity_list (typeof (Tax), query) as Gee.List<Tax>;

		var map = new Gee.HashMap<uint, Tax> ();
		foreach (var t in list)
			map[t.month] = t;
		return map;
	}


	public Gee.Map<uint, AccountMonth> find_account_month_by_year (Account account, int year) {
		var list = fetch_entity_list<AccountMonth> (AccountMonth.table_name,
				("account=%" + int64.FORMAT + " AND period>=%d AND period<%d")
				.printf (account.id, year * 12, (year + 1) * 12));

		var map = new Gee.HashMap<uint, AccountMonth> ();
		foreach (var t in list)
			map[t.period % 12] = t;
		return map;
	}


	public Gee.List<AccountMonth> get_account_periods (Account account, int start_period, int end_period) {
		return fetch_entity_list<AccountMonth> (AccountMonth.table_name,
				("account=%" + int64.FORMAT + " AND period>=%d AND period<=%d")
				.printf (account.id, start_period, end_period));
	}
}


}
