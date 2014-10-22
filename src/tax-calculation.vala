namespace Kv {


public abstract class TaxCalculation : Object {
	public Tax tax { get; construct set; }
	public unowned string name { get; protected set; }
	public unowned string desc { get; protected set; }


	public abstract unowned string get_id ();


	public abstract double get_amount ();


	public virtual Money get_price () {
		return tax.price.value;
	}


	public virtual Money get_total () {
		return Money (Math.llround (tax.amount * (double) get_price ().val));
	}
}



public class TaxFormula02 : TaxCalculation {
	public static unowned string id = "area";
	public override unowned string get_id () {
		return id;
	}


	construct {
		name = N_("Ar");
		desc = N_("total = area * price * day_coef");
	}


	public override double get_amount () {
		return tax.periodic.area;
	}


	public override Money get_total () {
		return Money (Math.llround (
				tax.amount * (double) get_price ().val * tax.periodic.period_coefficient ()
		));
	}
}


public class TaxFormula03 : TaxCalculation {
	public static unowned string id = "tenants";
	public override unowned string get_id () {
		return id;
	}


	construct {
		name = N_("Tn");
		desc = N_("total = tenant_coef * price");
	}


	public override double get_amount () {
		var list = tax.periodic.get_tenant_list ();
		return (double) list.size;
	}
}


public class TaxFormula05 : TaxCalculation {
	public static unowned string id = "norm-el";
	public override unowned string get_id () {
		return id;
	}


	construct {
		name = N_("Ne");
		desc = N_("total = norm * n_people * ");
	}


	public override double get_amount () {
		/* oven/heater - rooms - people */
		int[,,] norm = {{
			{  0,   0,   0,   0,  0,    0},
			{  0,  93,  58,  45,  36,  32},
			{  0, 120,  74,  57,  47,  41},
			{  0, 135,  84,  65,  53,  46},
			{  0, 147,  91,  70,  57,  50}
		}, {
			{  0,   0,   0,   0,   0,   0},
			{  0, 143,  89,  69,  56,  49},
			{  0, 168, 104,  81,  66,  57},
			{  0, 184, 114,  88,  72,  63},
			{  0, 196, 121,  94,  76,  67}
		}, {
			{  0,   0,   0,   0,  0,    0},
			{  0, 167, 103,  80,  65,  57},
			{  0, 215, 133, 103,  84,  73},
			{  0, 243, 151, 117,  95,  83},
			{  0, 263, 163, 126, 103,  90}
		}, {
			{  0,   0,   0,   0,   0,   0},
			{  0, 217, 134, 104,  85,  74},
			{  0, 256, 159, 123, 100,  87},
			{  0, 280, 173, 134, 109,  95},
			{  0, 297, 184, 143, 116, 101}
		}};


		var list = tax.periodic.get_tenant_list ();
		return (double) list.size;
	}
}


public class TaxFormula07 : TaxCalculation {
	public static unowned string id = "tenants-shower";
	public override unowned string get_id () {
		return id;
	}


	construct {
		name = N_("Ts");
		desc = N_("total = tenant_coef * ?(shower, price1, price2)");
	}


	public virtual Money get_price () {
		if (tax.periodic.param3)
			return tax.price.value2;
		else
			return tax.price.value;
	}


	public override double get_amount () {
		var list = tax.periodic.get_tenant_list ();
		return (double) list.size;
	}
}


}
