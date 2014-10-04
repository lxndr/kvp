namespace OOXML {


public class Writer {
	/*
	 * Shared strings
	 */
	private static void rich_text (Xml.Node* si_node, RichTextValue val) {
		Xml.Node* node;

		foreach (var piece in val.pieces) {
			var r_node = si_node->new_child (si_node->ns, "r");
			var rpr_node = r_node->new_child (si_node->ns, "rPr");
			r_node->new_text_child (si_node->ns, "t", piece.text);

			if (piece.font != null) {
				node = rpr_node->new_child (si_node->ns, "rFont");
				node->new_prop ("val", piece.font);
			}

			node = rpr_node->new_child (si_node->ns, "charset");
			node->new_prop ("val", piece.charset.to_string ());

			node = rpr_node->new_child (si_node->ns, "family");
			node->new_prop ("val", piece.family.to_string ());

			node = rpr_node->new_child (si_node->ns, "b");
			node->new_prop ("val", Utils.format_bool (piece.bold));

			node = rpr_node->new_child (si_node->ns, "i");
			node->new_prop ("val", Utils.format_bool (piece.italic));

			node = rpr_node->new_child (si_node->ns, "strike");
			node->new_prop ("val", Utils.format_bool (piece.strike));

			node = rpr_node->new_child (si_node->ns, "outline");
			node->new_prop ("val", Utils.format_bool (piece.outline));

			node = rpr_node->new_child (si_node->ns, "shadow");
			node->new_prop ("val", Utils.format_bool (piece.shadow));

			node = rpr_node->new_child (si_node->ns, "condense");
			node->new_prop ("val", Utils.format_bool (piece.condense));

			node = rpr_node->new_child (si_node->ns, "extend");
			node->new_prop ("val", Utils.format_bool (piece.extend));

			node = rpr_node->new_child (si_node->ns, "shadow");
			node->new_prop ("val", Utils.format_bool (piece.shadow));

			node = rpr_node->new_child (si_node->ns, "sz");
			node->new_prop ("val", Utils.format_double (piece.size));
		}	
	}


	public static Xml.Node* shared_strings (Gee.List<TextValue> list) throws Error {
		Xml.Node* sst_node = new Xml.Node (null, "sst");
		Xml.Ns* ns = new Xml.Ns (sst_node, "http://schemas.openxmlformats.org/spreadsheetml/2006/main", null);
		sst_node->set_prop ("count", list.size.to_string ());
		sst_node->set_prop ("uniqueCount", list.size.to_string ());

		foreach (var val in list) {
			Xml.Node* si_node = sst_node->new_child (ns, "si");

			if (val is SimpleTextValue) {
				si_node->new_text_child (ns, "t", ((SimpleTextValue) val).text);
			} else if (val is RichTextValue) {
				rich_text (si_node, (RichTextValue) val);
			} else {
				assert (val is SimpleTextValue || val is RichTextValue);
			}
		}

		return sst_node;
	}
}


}
