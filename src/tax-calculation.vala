namespace Kv {


public interface TaxCalculation : Object {
	public string tag;


	public virtual double calc_amount () {
		return tax.amount;
	}


	public virtual Money calc_total () {
		return Money (tax.amount * tax.price);
	}
}


public class Method_6 : Object, TaxCalculation {
	construct {
		tag = N_("F6");
	}


	public override Money calc_amount () {
		var total_amount = db.get_it ();
		var meter_amount = db.get_it ();
		var diff = total_amount / meter_amount;

		var norm = db.get_it ();

		return Math.round (norm * diff, 0);
	}
}


}
