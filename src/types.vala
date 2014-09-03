namespace Kv {


public struct Money : int64 {
	public string to_string () {
		return "%s.%d".printf (this / 100, this % 100);
	}
}


}
