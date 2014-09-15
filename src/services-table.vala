namespace Kv {


public class ServiceTable : DB.TableView {
	public ServiceTable (Database dbase) {
		base (dbase, typeof (Person));
	}


	protected override DB.Entity new_entity () {
		return new Service (db);
	}


	protected override string[] view_properties () {
		return {
			"name",
			"unit",
			"applied_to",
			"extra1"
		};
	}


	protected override Gee.List<DB.Entity> get_entity_list () {
		return (db as Database).get_people_list (period, account);
	}
}


}
