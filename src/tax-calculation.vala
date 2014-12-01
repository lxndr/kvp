namespace Kv {


public interface TaxCalculation : Object {
	public abstract unowned string id ();
	public abstract unowned string name ();
	public abstract unowned string description ();


	public virtual double amount (Tax tax) {
		return 1.0;
	}


	public virtual Money price (Tax tax) {
		return tax.price.value1;
	}


	public virtual Money total (Tax tax) {
		var price = price (tax).val;
		return Money (Math.llround (tax.amount * (double) price));
	}


	public double period_coefficient (Tax tax) {
		unowned Month period = tax.period;
		unowned Account account = tax.account;
		unowned Price price = tax.price;

		/* month range */
		var first_day = period.first_day;
		var last_day = period.last_day;

		/* account range */
		Date.clamp_range (ref first_day, ref last_day, account.opened, account.closed);

		/* price range */
		Date.clamp_range (ref first_day, ref last_day, price.first_day, last_day);

		if (first_day == null && last_day == null)
			return 0.0;

		var days = first_day.diff (last_day) + 1;
		var days_in_month = period.month.get_days_in_month (period.year);
		return (double) days / (double) days_in_month;
	}


	public double tenant_coefficient (Tax tax) {
		unowned AccountPeriod periodic = tax.periodic;
		unowned Month period = tax.period;
		unowned Account account = tax.account;

		/* month range */
		var first_day = period.first_day;
		var last_day = period.last_day;

		/* account range */
		Date.clamp_range (ref first_day, ref last_day, account.opened, account.closed);

		uint days = 0;
		var tenant_list = periodic.get_tenant_list ();
		foreach (var tenant in tenant_list) {
			var first = tenant.move_in;
			var last = tenant.move_out;
			Date.clamp_range (ref first, ref last, first_day, last_day);

			/* no range at all */
			if (first == null && last == null)
				continue;

			days += first_day.diff (last_day) + 1;
		}

		var days_in_month = period.month.get_days_in_month (period.year);
		return (double) days / (double) days_in_month;
	}
}


public class TaxFormula01 : Object, TaxCalculation {
	public unowned string id () {
		return "price-only";
	}


	public unowned string name () {
		return _("Pr");
	}


	public unowned string description () {
		return _("total = price");
	}


	public double amount (Tax tax) {
		return 0.0;
	}


	public Money total (Tax tax) {
		return price (tax);
	}
}


public class TaxFormula02 : Object, TaxCalculation {
	public unowned string id () {
		return "area";
	}


	public unowned string name () {
		return _("Ar");
	}


	public unowned string description () {
		return _("total = area * price * period_coef");
	}


	public double amount (Tax tax) {
		return tax.periodic.area;
	}


	public Money total (Tax tax) {
		var price = price (tax).val;
		var coef = period_coefficient (tax);
		return Money (Math.llround (tax.amount * price * coef));
	}
}


public class TaxFormula03 : Object, TaxCalculation {
	public unowned string id () {
		return "tenants";
	}


	public unowned string name () {
		return _("Tn");
	}


	public unowned string description () {
		return _("total = tenant_coef * price");
	}


	public double amount (Tax tax) {
		return tenant_coefficient (tax);
	}
}


public class TaxFormula05 : Object, TaxCalculation {
	public unowned string id () {
		return "norm-el";
	}


	public unowned string name () {
		return _("Ne");
	}


	public unowned string description () {
		return _("total = norm * n_people * tenant_coef");
	}


	public double amount (Tax tax) {
		unowned AccountPeriod ac = tax.periodic;

		/* oven/heater - rooms - people */
		int[,,] norm = {{	/* no oven, no heater */
			{  0,   0,   0,   0,  0,    0},
			{  0,  93,  58,  45,  36,  32},
			{  0, 120,  74,  57,  47,  41},
			{  0, 135,  84,  65,  53,  46},
			{  0, 147,  91,  70,  57,  50}
		}, {				/* oven, no heater */
			{  0,   0,   0,   0,   0,   0},
			{  0, 143,  89,  69,  56,  49},
			{  0, 168, 104,  81,  66,  57},
			{  0, 184, 114,  88,  72,  63},
			{  0, 196, 121,  94,  76,  67}
		}, {				/* no oven, heater */
			{  0,   0,   0,   0,  0,    0},
			{  0, 167, 103,  80,  65,  57},
			{  0, 215, 133, 103,  84,  73},
			{  0, 243, 151, 117,  95,  83},
			{  0, 263, 163, 126, 103,  90}
		}, {				/* oven, heater */
			{  0,   0,   0,   0,   0,   0},
			{  0, 217, 134, 104,  85,  74},
			{  0, 256, 159, 123, 100,  87},
			{  0, 280, 173, 134, 109,  95},
			{  0, 297, 184, 143, 116, 101}
		}};

		var norm_idx = (int) ac.param1 * 2 + (int) tax.periodic.param2;
		int norm_rooms = (int) ac.n_rooms.clamp (0, 4);
		int norm_people = (int) ac.n_people.clamp (0, 5);
		int n = norm[norm_idx, norm_rooms, norm_people];

		double amount_coef = 1.0;
		if (ac.account.building.id == 3) {
			double[] coef = {
				1.4465,
				1.6206,
				1.2084,
				1.3434,
				1.0214,
				1.0156,
				0.9860,
				1.1038,
				1.0912,
				1.0000,
				1.0000,
				1.0000
			};

			int month = ac.period.raw_value % 12;
			amount_coef = coef[month];
		}

		return Math.round ((double) (n * ac.n_people) * amount_coef);
	}


	public Money total (Tax tax) {
		var price = price (tax).val;
		var coef = period_coefficient (tax);
		return Money (Math.llround (tax.amount * (double) price * coef));
	}
}


public class TaxFormula07 : Object, TaxCalculation {
	public unowned string id () {
		return "tenants-shower";
	}


	public unowned string name () {
		return _("Ts");
	}


	public unowned string description () {
		return _("total = tenant_coef * ?(shower, price2, price1)");
	}


	public Money price (Tax tax) {
		unowned AccountPeriod periodic = tax.periodic;
		unowned Price price = tax.price;

		if (periodic.param3)
			return price.value2;
		else
			return price.value1;
	}


	public double amount (Tax tax) {
		return tenant_coefficient (tax);
	}
}


public class TaxFormula08 : Object, TaxCalculation {
	public unowned string id () {
		return "amount";
	}


	public unowned string name () {
		return _("Am");
	}


	public unowned string description () {
		return _("total = amount * price1");
	}


	public double amount (Tax tax) {
		return tax.amount;
	}
}


}
