namespace Kv {


public class Database : DB.SQLiteDatabase {
	private Gee.Map<string, TaxCalculation> tax_calc_methods;


	construct {
		/* tax colculation methods */
		tax_calc_methods = new Gee.HashMap<string, TaxCalculation> ();
		register_tax_calculation (typeof (TaxFormula01));
		register_tax_calculation (typeof (TaxFormula02));
		register_tax_calculation (typeof (TaxFormula03));
		register_tax_calculation (typeof (TaxFormula05));
		register_tax_calculation (typeof (TaxFormula07));

		/* prepare the database */
		try {
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


	/*
	 * Tax calculation methods.
	 */
	public void register_tax_calculation (Type type) {
		var method = Object.new (type) as TaxCalculation;
		tax_calc_methods[method.id ()] = method;
	}


	public TaxCalculation? get_tax_calculation (string? id) {
		if (id == null)
			return null;
		return tax_calc_methods[id];
	}


	/*
	 * Settings.
	 */
	public string? get_setting (string key) {
		return fetch_string ("settings", "value", "key = '%s'".printf (key));
	}


	public void set_setting (string key, string val) {
		var query = "REPLACE INTO settings VALUES ('%s', '%s')".printf (key, val);
		exec_sql (query);
	}


	/*
	 * Helper functions.
	 */
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
		var service_list = get_period_services (building, period);
		foreach (var service_id in service_list) {
			from = form_table_name_for_building (building, Tax.table_name);
			exec_sql ("INSERT INTO %s SELECT account,%u,service,apply,amount,total FROM %s WHERE period=%u AND service=%d"
					.printf (Tax.table_name, period.raw_value, from, prev_period.raw_value, service_id), null);
		}

		commit_transaction ();
	}


	public Gee.List<Building> get_building_list (Month? active_period = null) {
		string? where = null;

		if (active_period != null) {
			var val = active_period.raw_value;
			where = "(first_period=NULL OR first_period<=%u) AND (last_period=NULL OR last_period>=%u)"
					.printf (val, val);
		}

		return fetch_entity_list<Building> (Building.table_name, where);
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


	public Gee.List<AccountPeriod> get_account_period_list (Building? building, Month period, bool include_closed) {
		/*
		 * SELECT account_period.*, account.id AS account, ? AS period
		 * FROM account LEFT JOIN account_period
		 * ON account.id=account_period.account AND period=?
		 * WHERE account.building=? AND opened<=?;
		 */

		var query = new DB.QueryBuilder ();
		query.select ("account_period.*, account.id AS account, %d AS period".printf (period.raw_value))
				.from ("account LEFT JOIN account_period")
				.on ("account.id = account_period.account AND period = %d".printf (period.raw_value));

		var period_last_day = period.last_day;
		string where = "(opened IS NULL OR opened <= %d)".printf (period_last_day.get_days ());
		if (building != null)
			where += " AND account.building = %d".printf (building.id);

/*		if (include_closed == false) {
			var period_first_day = period.first_day;
			where += " AND (closed=NULL OR closed>=%d)".printf (period_first_day.get_days ());
		}*/
		query.where (where);

		return fetch_entity_list_ex (typeof (AccountPeriod), query) as Gee.List<AccountPeriod>;
	}


	public Gee.List<Person> get_people_list (Account account, Month period) {
		return fetch_entity_list<Person> (Person.table_name,
				"account = %d AND period = %d".printf (account.id, period.raw_value));
	}


	/**
	 * Fetches a list of tenants fron the database.
	 * @period: if null then only tenants that are actual for the @period are returned.
	 */
	public Gee.List<Tenant> get_tenant_list (Account account, Month? period) {
		var sb = new StringBuilder.sized (64);
		sb.append_printf ("account = %d", account.id);

		if (period != null) {
			var first_day = period.first_day;
			var last_day = period.last_day;
			Date.clamp_range (ref first_day, ref last_day, account.opened, account.closed);

			if (last_day == null)	/* account is closed */
				return new Gee.ArrayList<Tenant> ();

			sb.append_printf (" AND (move_in IS NULL OR move_in <= %d) AND (move_out IS NULL OR move_out >= %d)",
					last_day.get_days (), last_day.get_days ());
		}

		return fetch_entity_list<Tenant> (Tenant.table_name, sb.str);
	}


	/*
	 * Determine active services for a particular period.
	 */
	public Gee.List<int> get_period_services (Building building, Month period) {
		return fetch_int_list (Price.table_name, "DISTINCT service",
				"building = %d AND (first_day IS NULL OR first_day <= %d) AND (last_day IS NULL OR last_day >= %d)"
				.printf (building.id, period.last_day.get_days (), period.first_day.get_days ()));
	}


	public Gee.List<Price> get_price_list (Building? building, Month? period, Service? service) {
		string[] where = {};

		if (building != null)
			where += "building = %d".printf (building.id);
		if (service != null)
			where += "service = %d".printf (service.id);
		if (period != null)
			where += "(first_day IS NULL OR first_day <= %d) AND (last_day IS NULL OR last_day >= %d)"
			.printf (period.last_day.get_days (), period.last_day.get_days ());

		return fetch_entity_list<Price> (Price.table_name, string.joinv (" AND ", where));
	}


	public Gee.List<Tax> get_tax_list (AccountPeriod periodic) {
		unowned Account account = periodic.account;
		unowned Building building = account.building;
		unowned Month period = periodic.period;

		var prices = get_price_list (building, period, null);
		var list = new Gee.ArrayList<Tax> ();
		foreach (var price in prices) {
			var tax = fetch_entity<Tax> (Tax.table_name,
					("account = %d AND period = %d AND service = %d")
					.printf (account.id, period.raw_value, price.service.id));
			if (tax == null)
				tax = new Tax (this, account, period, price.service);
			list.add (tax);
		}
		return list;
	}


	public Gee.List<AccountPeriod> get_account_periods (Account account, int start_period, int end_period) {
		return fetch_entity_list<AccountPeriod> (AccountPeriod.table_name,
				("account = %d AND period >= %d AND period <= %d")
				.printf (account.id, start_period, end_period));
	}
}


}
