namespace Kv {


public class Account : DB.SimpleEntity {
	public Building building { get; construct set; }
	public string number { get; set; default = ""; }
	public Date? opened { get; set; default = new Date.now (); }
	public Date? closed { get; set; default = null; }
	public string? comment { get; set; default = null; }


	public static unowned string table_name = "account";
	public override unowned string db_table () {
		return table_name;
	}


	public override unowned string[] db_fields () {
		const string[] fields = {
			"building",
			"number",
			"opened",
			"closed",
			"comment"
		};
		return fields;
	}


	public string display_name {
		get { return number; }
	}


	public Account (DB.Database _db, Building _building) {
		Object (db: _db,
				building: _building);
	}


	public override void remove () {
		db.begin_transaction ();
		base.remove ();
		db.delete_entity (AccountPeriod.table_name, "account=%d".printf (id));
		db.delete_entity (Person.table_name, "account=%d".printf (id));
		db.delete_entity (Tax.table_name, "account=%d".printf (id));
		db.commit_transaction ();
	}


	public Gee.List<Tenant> get_tenant_list () {
		return ((Database) db).get_tenant_list (this, 0);
	}


	public AccountPeriod? fetch_period (Month period) {
		return db.fetch_entity<AccountPeriod> (AccountPeriod.table_name,
				"account=%d AND period=%d".printf (id, period.raw_value));
	}
}


}
