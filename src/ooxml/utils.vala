namespace OOXML {

namespace Utils {


public int pow_integer (int n, int p) {
	int v = 1;
	for (int i = 0; i < p; i++)
		v *= n;
	return v;
}


public void parse_cell_name (string name, out int x, out int y) {
	try {
		var re = new Regex ("([A-Z]+)([0-9]+)");
		var tokens = re.split (name);

		/* x coord */
		unowned string s = tokens[1];
		var s_len = s.length;
		x = 0;
		for (var i = 0; i < s_len; i++) {
			var d = s[i] - 0x40; /* one 'digit' */
			var p = s_len - i - 1;
			x += pow_integer (26, p) * d;
		}

		/* y coord */
		y = (int) int64.parse (tokens[2]);
	} catch (RegexError e) {
		error ("Regex error in 'parse_cell_name': %s", e.message);
	}
}


public string format_cell_name (int row_number, int cell_number) {
	
	return "A" + row_number.to_string ();
}


}

}
