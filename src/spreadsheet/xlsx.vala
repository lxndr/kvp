namespace Spreadsheet {


public class XLSX : Object, Spreadsheet {
	private Archive.Zip archive;
	private Gee.List<Sheet> sheets;


	public XLSX () {
		Xml.Parser.init ();
		sheets = new Gee.ArrayList<Sheet> ();
	}


	private Gee.List<string> load_shared_strings () throws Error {
		var list = new Gee.ArrayList <string> ();

		var file = archive.extract ("xl/sharedStrings.xml");
		string text;
		FileUtils.get_contents (file.get_path (), out text);
		var xml_doc = Xml.Parser.read_memory (text, text.length);
		var sst_node = xml_doc->get_root_element ();

		if (sst_node->name != "sst")
			error ("Unknown sharedStrings.xml format");

		for (Xml.Node* si_node = sst_node->children; si_node != null; si_node = si_node->next) {
			if (si_node->name != "si")
				error ("Unknown sharedStrings.xml format");

			for (Xml.Node* t_node = si_node->children; t_node != null; t_node = t_node->next) {
				if (t_node->name != "t")
					error ("Unknown sharedStrings.xml format");
				list.add (t_node->children->content);
			}
		}

		return list;
	}


	private void update_shared_strings (Gee.List<string> list) {
		Xml.Doc* xml_doc = new Xml.Doc ("1.0");

		var sst_node = xml_doc->new_node (null, "sst");

		foreach (var text in list) {
			var si_node = sst_node->new_child (null, "si");
			var t_node = si_node->new_child (null, "t");
			t_node->content = text;
		}

		var stm = archive.add_from_stream ("xl/sharedStrings.xml");
		string xml;
		xml_doc->dump_memory (out xml);
		stm.write (xml.data);
	}


	public void open (File f) throws Error {
		archive = new Archive.Zip ();
		archive.open (f);

		/* get shared strings */
		var list = load_shared_strings ();

		int sheet_number = 1;
		while (true) {
			var sheet_path = "xl/worksheets/sheet%d.xml".printf (sheet_number);
			var sheet_file = archive.extract (sheet_path);
			if (sheet_file == null)
				break;

			string text;
			FileUtils.get_contents (sheet_file.get_path (), out text);
			
			Xml.Parser.init ();
			var xml_doc = Xml.Parser.read_memory (text, text.length);

			var sheet = new Sheet (this);
			sheet.read_sheet_xml (xml_doc);
			sheets.add (sheet);

			Xml.Parser.cleanup ();

			sheet_number++;
		}

	}


	public Sheet sheet (int index) {
		return sheets[index];
	}


	public void save_as (File f) {
		archive.write (f);
	}
}


}
