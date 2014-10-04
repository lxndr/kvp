namespace OOXML {


public class Reader {
	/*
	 * Shared strings
	 */
	private static void rich_text_properties (Xml.Node* rpr_node, RichTextPiece piece) throws Error {
		for (Xml.Node* node = rpr_node->children; node != null; node = node->next) {
			switch (node->name) {
			case "rFront":
				piece.font = node->get_prop ("val");
				break;
			case "charset":
				var v = node->get_prop ("val");
				if (v != null)
					piece.charset = int.parse (v);
				break;
			case "family":
				piece.family = Utils.parse_int (node->get_prop ("val"));
				break;
			case "b":
				piece.bold = Utils.parse_bool (node->get_prop ("val"));
				break;
			case "i":
				piece.italic = Utils.parse_bool (node->get_prop ("val"));
				break;
			case "strike":
				piece.strike = Utils.parse_bool (node->get_prop ("val"));
				break;
			case "outline":
				piece.outline = Utils.parse_bool (node->get_prop ("val"));
				break;
			case "shadow":
				piece.shadow = Utils.parse_bool (node->get_prop ("val"));
				break;
			case "condense":
				piece.condense = Utils.parse_bool (node->get_prop ("val"));
				break;
			case "extend":
				piece.extend = Utils.parse_bool (node->get_prop ("val"));
				break;
//			case "color":
//				break;
			case "sz":
				piece.size = Utils.parse_double (node->get_prop ("val"));
				break;
//			case "u":
//				break;
//			case "scheme":
//				break;
			default:
				throw new Error.SHARED_STRINGS ("Unknown tag '%s' at sharedStrings.xml/sst/si/r/rPr", node->name);
			}
		}
	}


	private static TextValue rich_text (Xml.Node* r_node) throws Error {
		var ret = new RichTextValue ();

		for (Xml.Node* node = r_node->children; node != null; node = node->next) {
			var piece = new RichTextPiece ();

			switch (node->name) {
			case "rPr":
				rich_text_properties (node, piece);
				break;
			case "t":
				var text_node = node->children;
				if (text_node != null && text_node->type == Xml.ElementType.TEXT_NODE)
					piece.text = text_node->content;
				break;
			default:
				throw new Error.SHARED_STRINGS ("Unknown tag '%s' at sharedStrings.xml/sst/si/r", node->name);
			}

			ret.pieces.add (piece);
		}

		return ret;
	}


	public static void shared_strings (Xml.Node *sst_node, Gee.List<TextValue> list) throws Error {
		if (!(sst_node->ns != null && sst_node->ns->href == "http://schemas.openxmlformats.org/spreadsheetml/2006/main" && sst_node->name == "sst"))
			throw new Error.SHARED_STRINGS ("Unknown sharedStrings.xml format");

		for (Xml.Node* si_node = sst_node->children; si_node != null; si_node = si_node->next) {
			if (si_node->name == "si") {
				TextValue val = new SimpleTextValue.empty ();

				for (Xml.Node* node = si_node->children; node != null; node = node->next) {
					switch (node->name) {
					case "t":
						var v = new SimpleTextValue.empty ();
						var text_node = node->children;
						if (text_node != null && text_node->type == Xml.ElementType.TEXT_NODE)
							v.text = text_node->content;
						val = v;
						break;
					case "r":
						val = rich_text (node);
						break;
					default:
						throw new Error.SHARED_STRINGS ("Unknown tag '%s' at sharedStrings.xml/sst/si", node->name);
					}
				}

				list.add (val);
			} else {
				throw new Error.SHARED_STRINGS ("Unknown tag '%s' at sharedStrings.xml/sst", si_node->name);
			}
		}
	}
}


}
