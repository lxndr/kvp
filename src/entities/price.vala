namespace Kv {


public class Price : DB.SimpleEntity {
	public static unowned string table_name = "price";

	public Building building { get; set; }
	public Service service { get; set; }
	public Date? first_day { get; set; default = null; }
	public Date? last_day { get; set; default = null; }
	public string? method { get; set; default = null; }
	public Money value1 { get; set; }
	public Money value2 { get; set; }


	public string service_name { get { return service.name; } }


	private TaxCalculation _calculation;
	public TaxCalculation? calculation {
		get {
			if (_calculation == null && method != null)
				_calculation = ((Database) db).get_tax_calculation (method);
			return _calculation;
		}
	}


	public Price (DB.Database _db, Building _building, Service _service) {
		Object (db: _db,
				building: _building,
				service: _service);
	}


	public override unowned string[] db_fields () {
		const string[] fields = {
			"building",
			"service",
			"first_day",
			"last_day",
			"method",
			"value1",
			"value2"
		};
		return (string[]) fields;
	}


	public string display_name {
		get { return service.name; }
	}
}


}
