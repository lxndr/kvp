namespace OOXML {


public abstract class CellValue : Object {
}


public class IntegerValue : CellValue {
	public int64 val { get; set; default = 0; }

	public IntegerValue.from_string (string s) {
		Object (val: int64.parse (s));
	}
}


public class NumberValue : CellValue {
	public double val { get; set; default = 0; }

	public NumberValue (double n) {
		Object (val: n);
	}


	public NumberValue.from_string (string s) {
		Object (val: double.parse (s));
	}
}


public class StringValue : CellValue {
	public Gee.List<StringValuePiece> pieces;

	public StringValue () {
		pieces = new Gee.ArrayList<StringValuePiece> ();
	}


	public StringValue.simple (string text) {
		pieces = new Gee.ArrayList<StringValuePiece> ();
		pieces.add (new SimpleStringPiece (text));
	}


	public bool is_simple () {
		return (pieces.size > 0) && (pieces[0] is SimpleStringPiece);
	}


	public string to_string () {
		string s = "";
		foreach (var piece in pieces)
			s += piece.text;
		return s;
	}
}


public abstract class StringValuePiece : Object {
	public string text { get; set; }
}


public class SimpleStringPiece : StringValuePiece {
	public SimpleStringPiece (string val) {
		Object (text: val);
	}
}


}
