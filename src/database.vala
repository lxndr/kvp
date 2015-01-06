namespace Kv {


public class Database {
	public DB.Database db { get; private set; }
	private Gee.Map<string, TaxCalculation> tax_calc_methods;


	construct {
		/* database */
		_db = new DB.SQLiteDatabase (
				File.new_for_path ("./kvartplata.db", new DatabaseValueAdapter ()));
		_db.register_entity_type (typeof (Account), Account.table_name);
		_db.register_entity_type (typeof (AccountPeriod), AccountPeriod.table_name);
		_db.register_entity_type (typeof (Building), Building.table_name);
		_db.register_entity_type (typeof (Person), Person.table_name);
		_db.register_entity_type (typeof (Price), Price.table_name);
		_db.register_entity_type (typeof (Relationship), Relationship.table_name);
		_db.register_entity_type (typeof (Service), Service.table_name);
		_db.register_entity_type (typeof (Tax), Tax.table_name);
		_db.register_entity_type (typeof (Tenant), Tenant.table_name);
	
		/* tax colculation methods */
		tax_calc_methods = new Gee.HashMap<string, TaxCalculation> ();
		register_tax_calculation (typeof (TaxFormula01));
		register_tax_calculation (typeof (TaxFormula02));
		register_tax_calculation (typeof (TaxFormula03));
		register_tax_calculation (typeof (TaxFormula05));
		register_tax_calculation (typeof (TaxFormula07));
		register_tax_calculation (typeof (TaxFormula08));

		/* prepare the database */
		try {
//			var bytes = resources_lookup_data ("/org/lxndr/kvp/data/init.sql", ResourceLookupFlags.NONE);
//			unowned uint8[] data = bytes.get_data ();
//			exec_sql ((string) data);
		} catch (Error e) {
			error ("Error preparing database '%s': %s", file.get_path (), e.message);
		}
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
		var q = new DB.Query.select ("value");
		q.from ("settings");
		q.where ("key = '%s'".printf (key));
		return db.fetch_string (q, null);
	}


	public void set_setting (string key, string val) {
		var query = "REPLACE INTO settings VALUES ('%s', '%s')".printf (key, val);
		db.exec_sql (query);
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
		var q = new DB.Query.select ("COUNT(*)");
		q.from (AccountPeriod.table_name);
		q.join ("account")
			.on (@"account.id = $(AccountPeriod.table_name).account")
			.on (@"account.building = $(building.id)");
		q.where (@"period = $(period.raw_value)");
		return db.fetch_value<int> (q, 0) == 0;
	}


	public void prepare_period (Building? building, Month period) {
		var prev_period = period.get_prev ();
		string from;

		db.begin_transaction ();

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

		db.commit_transaction ();
	}


	public Gee.List<Building> get_building_list (Month? active_period = null) {
		var q = new DB.Query.select ();
		q.from (Building.table_name);
		if (active_period != null) {
			q.where (@"first_period IS NULL OR first_period <= $(active_period.raw_value)");
			q.where (@"last_period IS NULL OR last_period >= $(active_period.raw_value)");
		}
		return db.fetch_entity_list<Building> (q);
	}


	public Gee.List<Service> get_service_list () {
		var q = new DB.Query.select ();
		q.from (Service.table_name);
		return db.fetch_entity_list<Service> (q);
	}


	public Gee.List<Account> get_account_list (Building? building) {
		var q = new DB.Query.select ();
		q.from (Account.table_name);
		if (building != null)
			q.where (@"building = $(building.id)");
		return db.fetch_entity_list<Account> (q);
	}


	public Gee.List<AccountPeriod> get_account_period_list (Building? building, Month period, bool include_closed) {
		/*
		 * SELECT account_period.*, account.id AS account, ? AS period
		 * FROM account LEFT JOIN account_period
		 * ON account.id=account_period.account AND period=?
		 * WHERE account.building=? AND opened<=?;
		 */

		var q = new DB.Query.select (@"account_period.*, account.id AS account, $(period.raw_value) AS period");
		q.from ("account LEFT JOIN account_period");
		q.on (@"account.id = account_period.account AND period = $(period.raw_value)");

		var last_day = period.last_day.get_days ();
		q.where (@"opened IS NULL OR opened <= $(last_day)");
		if (building != null)
			q.where (@"account.building = $(building.id)");

/*		if (include_closed == false) {
			var period_first_day = period.first_day;
			where += " AND (closed=NULL OR closed>=%d)".printf (period_first_day.get_days ());
		}*/

		return db.fetch_entity_list<AccountPeriod> (q);
	}


	public Gee.List<Person> get_people_list (Account account, Month period) {
		var q = new DB.Query.select ();
		q.from (Person.table_name);
		q.where (@"account = $(account.id) AND period = $(period.raw_value)");
		return db.fetch_entity_list<Person> (q);
	}


	/**
	 * Fetches a list of tenants from the database.
	 * @period: if null then only tenants that are actual for the @period are returned.
	 */
	public Gee.List<Tenant> get_tenant_list (Account account, Month? period) {
		var q = new DB.Query.select ();
		q.from (Tenant.table_name);
		q.where (@"account = $(account.id)");

		if (period != null) {
			var first_day = period.first_day;
			var last_day = period.last_day;
			Date.clamp_range (ref first_day, ref last_day, account.opened, account.closed);

			if (last_day == null)	/* account is closed */
				return new Gee.ArrayList<Tenant> ();

			q.where (@"move_in IS NULL OR move_in <= $(last_day.get_days ())");
			q.where (@"move_out IS NULL OR move_out >= $(last_day.get_days ())");
		}

		return db.fetch_entity_list<Tenant> (q);
	}


	/*
	 * Determine active services for a particular period.
	 */
	public Gee.List<int> get_period_services (Building building, Month period) {
		var q = new DB.Query.select ("DISTINCT service");
		q.from (Price.table_name);
		q.where (@"building = $(building.id)");
		q.where ("first_day IS NULL OR first_day <= %d".printf (period.last_day.get_days ()));
		q.where ("last_day IS NULL OR last_day >= %d".printf (period.first_day.get_days ()));
		return db.fetch_value_list<int> (q);
	}


	public Gee.List<Price> get_price_list (Building? building, Month? period, Service? service) {
		var q = new DB.Query.select ();
		q.from (Price.table_name);

		if (building != null)
			q.where (@"building = $(building.id)");

		if (service != null)
			q.where (@"service = $(service.id)");

		if (period != null) {
			var last_day = period.last_day.get_days ();
			q.where (@"first_day IS NULL OR first_day <= $(last_day)");
			q.where (@"last_day IS NULL OR last_day >= $(last_day)");
		}

		return db.fetch_entity_list<Price> (q);
	}


	public Gee.List<Tax> get_tax_list (AccountPeriod periodic) {
		unowned Account account = periodic.account;
		unowned Building building = account.building;
		unowned Month period = periodic.period;

		var prices = get_price_list (building, period, null);
		var list = new Gee.ArrayList<Tax> ();
		foreach (var price in prices) {
			var q = new DB.Query.select ();
			q.from (Tax.table_name);
			q.where (@"account = $(account.id) AND period = $(period.raw_value) AND service = $(price.service.id)");
			var tax = db.fetch_entity<Tax> (q);
			if (tax == null)
				tax = new Tax (this, account, period, price.service);
			list.add (tax);
		}
		return list;
	}


	public Gee.List<AccountPeriod> get_account_periods (Account account, int start_period, int end_period) {
		var q = new DB.Query.select ();
		q.from (AccountPeriod.table_name);
		q.where (@"account = $(account.id) AND period >= $(start_period) AND period <= $(end_period)");
		return db.fetch_entity_list<AccountPeriod> (q);
	}
}


}
