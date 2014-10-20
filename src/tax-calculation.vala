namespace Kv {


public abstract class TaxCalculation : Object {
	public Tax tax { get; construct set; }
	public unowned string id { get; protected set; }
	public unowned string name { get; protected set; }
	public unowned string desc { get; protected set; }


	public abstract double get_amount ();


	public virtual Money get_price () {
		return tax.price.value;
	}


	public virtual Money get_total () {
		return Money (Math.llround (tax.amount * (double) get_price ().val));
	}
}



public class TaxFormula02 : TaxCalculation {
	construct {
		id = "area";
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
	construct {
		id = "tenants";
		name = N_("Tn");
		desc = N_("total = tenant_coef * price");
	}


	public override double get_amount () {
		var list = tax.periodic.get_tenant_list ();
		return (double) list.size;
	}
}


}
