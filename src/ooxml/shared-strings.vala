namespace OOXML {


namespace SharedStrings {
	public Gee.List<CellValue> load_from_xlsx (Archive.Zip ar) throws GLib.Error {
		string xml;

		var file = ar.extract ("xl/sharedStrings.xml");
		FileUtils.get_contents (file.get_path (), out xml);

		var xml_doc = Xml.Parser.read_memory (xml, xml.length);
		return load_from_xml (xml_doc);
	}


	public Gee.List<CellValue> load_from_xml (Xml.Doc* xml_doc) throws Error {
		var list = new Gee.ArrayList<CellValue> ();

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

}


}
