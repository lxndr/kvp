namespace Kv {


[Compact]
public struct Money {
	public int64 val;


	public Money (int _val) {
		val = _val;
	}


	private string clean (string str, int max_digits, bool minus) {
		string clean_string = "";
		var length = str.length;

		for (var i = 0; i < length; i++) {
			var ch = str[i];
			if ((minus == true && ch == '-') || (ch >= '0' && ch <= '9')) {
				clean_string += "%c".printf (ch);
				max_digits--;
				if (max_digits == 0)
					break;
			}
		}

		return clean_string;
	}


	public Money.from_string (string s) {
		var p = s.index_of_char ('.');
		if (p == -1)
			p = s.index_of_char (',');
		
		if (p == -1) {
			val = int64.parse (clean (s, 256, true));
		} else {
			var p1 = s[0:p];
			var p2 = s[p+1:s.length];

			var v1 = clean (p1, 256, true);
			var v2 = clean (p2, 2, false);

			val = int64.parse (v1 + v2);
		}
	}


	public string to_string () {
		var p0 = (val / 100);
		var p1 = (val % 100).abs ();

		return ("%" + int64.FORMAT + ",%" + int64.FORMAT).printf (p0, p1);
	}
}


}
