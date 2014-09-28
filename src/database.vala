namespace Kv {


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


	public bool is_empty_period (int period) {
		/* check if we've got any */
		if (query_count (AccountPeriod.table_name,
				"period=%d".printf (period)) > 0)
			return false;

		/* check if we've got any people */
		if (query_count (Person.table_name,
				"period=%d".printf (period)) > 0)
			return false;

		/* check if we've got any taxes */
		if (query_count (Tax.table_name,
				"period=%d".printf (period)) > 0)
			return false;

		return true;
	}


	public void prepare_for_period (int period) {
		int prev_period = period - 1;

		begin_transaction ();
		exec_sql ("INSERT INTO account_period SELECT account,%d,apartment,n_rooms,area,total,0,balance,0 FROM account_period WHERE period=%d"
				.printf (period, prev_period), null);
		exec_sql ("INSERT INTO person SELECT null,account,%d,name,birthday,relationship FROM person WHERE period=%d"
				.printf (period, prev_period), null);

		/* a little bit more tricky */
		var price_list = get_price_list (period);
		foreach (var price in price_list)
			exec_sql (("INSERT INTO tax SELECT account,%d,service,apply,amount,total FROM tax WHERE period=%d AND service=%d")
					.printf (period, prev_period, price.service.id), null);
		commit_transaction ();
	}


	public Gee.List<Service> get_service_list () {
		return fetch_entity_list<Service> (Service.table_name);
	}


	public Gee.List<Account> get_account_list (Building? building) {
		string? where = null;
		if (building != null)
			where = "building=%d".printf (building.id);

		return fetch_entity_list<Account> (Account.table_name, where);
	}


	public Gee.List<AccountPeriod> get_account_period_list (Building? building, int period) {
/*		var accounts = get_account_list (building);
		var account_periods = fetch_int_entity_map<AccountPeriod> (
				"account_period JOIN account ON account.building=%d".printf (building.id),
				"account", "account_period.*", "period=%d".printf (period));

		var result = new Gee.ArrayList<AccountPeriod> ();

		foreach (var account in accounts) {
			var account_period = account_periods[account.id];
			if (account_period == null)
				account_period = new AccountPeriod (this, account, period);
			result.add (account_period);
		}

		return result;*/

		/*
		 * SELECT account_period.*, account.id AS account, ? AS period
		 * FROM account LEFT JOIN account_period
		 * ON account.id=account_period.account AND period=?
		 * WHERE account.building=? AND opened>=?;
		 */

		var query = new DB.QueryBuilder ();
		query.select ("account_period.*, account.id AS account, %d AS period".printf (period))
			.from ("account LEFT JOIN account_period")
			.on ("account.id=account_period.account AND period=%d".printf (period));
		if (building != null)
			query.where ("account.building=%d".printf (building.id));
		return fetch_entity_list_ex (typeof (AccountPeriod), query) as Gee.List<AccountPeriod>;
	}


	public Gee.List<Person> get_people_list (Account account, int period) {
		return fetch_entity_list<Person> (Person.table_name,
				("account=%d AND period=%d")
				.printf (account.id, period));
	}


	public Gee.List<Price> get_price_list (int period) {
		return fetch_entity_list<Price> (Price.table_name,
			("period=%d").printf (period));
	}


	public Gee.List<Tax> get_tax_list (AccountPeriod periodic) {
		unowned Account account = periodic.account;
		unowned Building building = account.building;
		int period = periodic.period;

		var prices = fetch_entity_list<Price> (Price.table_name,
				("building=%d AND period=%d").printf (building.id, period));
		var list = new Gee.ArrayList<Tax> ();
		foreach (var price in prices) {
			var tax = fetch_entity<Tax> (Tax.table_name,
					("account=%d AND period=%d AND service=%d")
					.printf (account.id, period, price.service.id));
			if (tax == null)
				tax = new Tax (this, account, period, price.service);
			list.add (tax);
		}
		return list;
	}


	public Gee.List<AccountPeriod> get_account_periods (Account account, int start_period, int end_period) {
		return fetch_entity_list<AccountPeriod> (AccountPeriod.table_name,
				("account=%d AND period>=%d AND period<=%d")
				.printf (account.id, start_period, end_period));
	}
}


}
