namespace OOXML {


public abstract class CellValue : Object {
}


public class NumberValue : CellValue {
	public string val { get; set; }
}


public class StringValue : CellValue {
	public Gee.List<StringValuePiece> pieces;

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
