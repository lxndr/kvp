namespace Kv {


public class Database : DB.SQLiteDatabase {
	private Gee.Map<string, Type> tax_calc_methods;


	construct {
		/* tax colculation methods */
		tax_calc_methods = new Gee.HashMap<string, Type> ();
		tax_calc_methods[TaxFormula01.id] = typeof (TaxFormula01);
		tax_calc_methods[TaxFormula02.id] = typeof (TaxFormula02);
		tax_calc_methods[TaxFormula03.id] = typeof (TaxFormula03);
		tax_calc_methods[TaxFormula05.id] = typeof (TaxFormula05);
		tax_calc_methods[TaxFormula07.id] = typeof (TaxFormula07);

		try {
			/* prepare the database */
			var bytes = resources_lookup_data ("/org/lxndr/kvp/data/init.sql", ResourceLookupFlags.NONE);
			unowned uint8[] data = bytes.get_data ();
//			exec_sql ((string) data);
		} catch (Error e) {
			error ("Error preparing database '%s': %s", file.get_path (), e.message);
		}
	}


	public Database (File _file) {
		Object (file: _file,
				value_adapter: new DatabaseValueAdapter ());
	}


	public TaxCalculation? create_tax_calculation (string? id, Tax tax) {
		if (id == null)
			return null;
		return Object.new (tax_calc_methods[id], "tax", tax) as TaxCalculation;
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


	private string form_table_name_for_building (Building? building, string table_name) {
		if (building == null)
			return AccountPeriod.table_name;
		return "%s JOIN account ON account.id=%s.account AND account.building=%d"
				.printf (table_name, table_name, building.id);
	}


	public bool is_period_empty (Building? building, Month period) {
		string from = form_table_name_for_building (building, AccountPeriod.table_name);
		if (query_count (from, "period=%u".printf (period.raw_value)) > 0)
			return false;
		return true;
	}


	public void prepare_period (Building? building, Month period) {
		var prev_period = period.get_prev ();
		string from;

		begin_transaction ();

		/* periodic */
		from = form_table_name_for_building (building, AccountPeriod.table_name);
		exec_sql ("INSERT INTO %s SELECT account,%u,apartment,n_rooms,area,total,0,0,0,param1,param2,param3 FROM %s WHERE period=%u"
				.printf (AccountPeriod.table_name, period.raw_value, from, prev_period.raw_value), null);

		/* a little bit more tricky */
		var price_list = get_price_list (building, (int) period.raw_value);
		foreach (var price in price_list) {
			from = form_table_name_for_building (building, Tax.table_name);
			exec_sql ("INSERT INTO %s SELECT account,%u,service,apply,amount,total FROM %s WHERE period=%u AND service=%d"
					.printf (Tax.table_name, period.raw_value, from, prev_period.raw_value, price.service.id), null);
		}

		commit_transaction ();
	}


	public Gee.List<Building> get_building_list () {
		return fetch_entity_list<Building> (Building.table_name);
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
		var month_last_day = Utils.get_month_last_day (period);

		/*
		 * SELECT account_period.*, account.id AS account, ? AS period
		 * FROM account LEFT JOIN account_period
		 * ON account.id=account_period.account AND period=?
		 * WHERE account.building=? AND opened<=?;
		 */

		var query = new DB.QueryBuilder ();
		query.select ("account_period.*, account.id AS account, %d AS period".printf (period))
			.from ("account LEFT JOIN account_period")
			.on ("account.id=account_period.account AND period=%d".printf (period));

		string where = "account.opened<=%u".printf (month_last_day);
		if (building != null)
			where += " AND account.building=%d".printf (building.id);
		query.where (where);

		return fetch_entity_list_ex (typeof (AccountPeriod), query) as Gee.List<AccountPeriod>;
	}


	public Gee.List<Person> get_people_list (Account account, int period) {
		return fetch_entity_list<Person> (Person.table_name,
				"account=%d AND period=%d".printf (account.id, period));
	}


	/**
	 * Fetches a list of tenants fron the database.
	 * @period: if greatee than 0 then only tenants that are actual to the @period are returned.
	 */
	public Gee.List<Tenant> get_tenant_list (Account account, int period) {
		var sb = new StringBuilder.sized (64);
		sb.append_printf ("account=%d", account.id);
		if (period > 0) {
			uint month_first_day = Utils.get_month_first_day (period);
			uint month_last_day = Utils.get_month_last_day (period);
			sb.append_printf (" AND (relation == 1 OR (move_in!=1 AND move_in<=%u AND (move_out=1 OR move_out>=%u)))",
					month_last_day, month_last_day);
		}

		return fetch_entity_list<Tenant> (Tenant.table_name, sb.str);
	}


	public Gee.List<Price> get_price_list (Building? building, int period) {
		string where = "period=%d".printf (period);
		if (building != null)
			where += " AND building=%d".printf (building.id);

		return fetch_entity_list<Price> (Price.table_name, where);
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
