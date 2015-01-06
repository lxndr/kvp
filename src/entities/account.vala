namespace Kv {


public class Account : DB.SimpleEntity {
	public static string table_name = "account";

	public Building building { get; construct set; }
	public string number { get; set; default = ""; }
	public Date? opened { get; set; default = new Date.now (); }
	public Date? closed { get; set; default = null; }
	public string? comment { get; set; default = null; }


	public override unowned string[] db_fields () {
		const string[] fields = {
			"building",
			"opened",
			"closed",
			"number",
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
		DB.Query q;
		var where = "account = %d".printf (id);

		db.begin_transaction ();
		base.remove ();
		q = new DB.Query.delete (AccountPeriod.table_name);
		q.where (where);
		db.exec (q);
		q = new DB.Query.delete (Tenant.table_name);
		q.where (where);
		db.exec (q);
		q = new DB.Query.delete (Tax.table_name);
		q.where (where);
		db.exec (q);
		db.commit_transaction ();
	}


	public Gee.List<Tenant> get_tenant_list () {
		return ((Database) db).get_tenant_list (this, null);
	}


	public AccountPeriod? fetch_period (Month period) {
		var q = new DB.Query.select ();
		q.from (AccountPeriod.table_name);
		q.where ("account = %d AND period = %d".printf (id, period.raw_value));
		return db.fetch_entity<AccountPeriod> (q);
	}
}


}
