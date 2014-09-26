namespace OOXML {


namespace SharedStrings {
	private Gee.List<StringValue> load_from_xlsx (Archive.Zip ar) throws GLib.Error {
		string xml;

		var file = ar.extract ("xl/sharedStrings.xml");
		FileUtils.get_contents (file.get_path (), out xml);

		var xml_doc = Xml.Parser.read_memory (xml, xml.length);
		return load_from_xml (xml_doc);
	}


	private Gee.List<StringValue> load_from_xml (Xml.Doc* xml_doc) throws GLib.Error {
		var list = new Gee.ArrayList<StringValue> ();

		var sst_node = xml_doc->get_root_element ();
		if (sst_node->name != "sst")
			error ("Unknown sharedStrings.xml format");

		for (Xml.Node* si_node = sst_node->children; si_node != null; si_node = si_node->next) {
			if (si_node->name != "si")
				error ("Unknown sharedStrings.xml format");

			var val = new StringValue ();

			for (Xml.Node* t_node = si_node->children; t_node != null; t_node = t_node->next) {
				switch (t_node->name) {
				case "t":
					var text_node = t_node->children;
					if (text_node != null && text_node->type == Xml.ElementType.TEXT_NODE)
						val.pieces.add (new SimpleStringPiece (text_node->content));
					break;
				default:
					throw new Error.SHARED_STRINGS ("Unknown string piece '%s'", t_node->name);
				}
			}

			list.add (val);
		}

		return list;
	}


	private void store_to_xlsx (Gee.List<StringValue> list, Archive.Zip ar) throws GLib.Error {
		Xml.Doc* xml_doc = store_to_xml (list);

		string xml;
		xml_doc->dump_memory_enc (out xml);
//stdout.printf (xml);
		var io = ar.add_from_stream ("xl/sharedStrings.xml");
		xml = Utils.convert_line_end (xml);
		io.output_stream.write (xml.data);
	}


	private Xml.Doc* store_to_xml (Gee.List<StringValue> list) throws GLib.Error {
		Xml.Doc* xml_doc = new Xml.Doc ("1.0");
		xml_doc->standalone = 1;

		Xml.Node* root_node = xml_doc->new_node (null, "sst");
		root_node->set_prop ("xmlns", "http://schemas.openxmlformats.org/spreadsheetml/2006/main");
		root_node->set_prop ("count", list.size.to_string ());
		root_node->set_prop ("uniqueCount", list.size.to_string ());
		xml_doc->set_root_element (root_node);

		foreach (var si in list) {
			Xml.Node* si_node = root_node->new_child (null, "si");
			si_node->new_text_child (null, "t", si.to_string ());
		}

		return xml_doc;
	}
}


}
