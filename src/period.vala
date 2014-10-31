namespace Kv {


public class Period {
	private uint _ym;
	public uint ym {
		get { return _ym; }
		set {
			_ym = value;
		}
	}


	public DateYear year {
		get { return (DateYear) (_ym / 12); }
	}


	public DateMonth month {
		get { return (DateMonth) (_ym % 12 + 1); }
	}


	public uint first_day { get; private set; }
	public uint last_day { get; private set; }


	public Period.from_ym (uint period) {
		ym = period;
	}


	public Period.now () {
		var date = new DateTime.now_local ();
		ym = date.get_year () * 12 + date.get_month () - 1;
	}


	public void prev () {
		ym -= 1;
	}


	public void next () {
		ym += 1;
	}


	public Period get_prev () {
		return new Period.from_ym (_ym - 1);		
	}


	public Period get_next () {
		return new Period.from_ym (_ym + 1);
	}
}


}
