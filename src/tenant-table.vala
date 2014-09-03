namespace Kv {


public class TenantTable : TableView {
	private Period period;
	private Account account;


	public TenantTable (Database dbase) {
		base (dbase, typeof (Tax));
	}


	public void setup_view (Period _period, Account _account) {
		period = _period;
		account = _account;

		update_view ();
	}


	protected override Entity new_entity () {
		return new Tenant (period, account);
	}


	protected override string[] view_properties () {
		return {
			"person_name",
			"person_birthday"
		};
	}


	protected override Gee.List<Entity> get_entity_list () {
		return db.get_tenant_list (period, account);
	}
}


}
