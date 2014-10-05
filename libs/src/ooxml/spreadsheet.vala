namespace OOXML {


public class Spreadsheet : Object {
	private Archive.Zip archive;
	private Gee.List<Sheet> sheets;


	public Spreadsheet () {
		archive = new Archive.Zip ();
		sheets = new Gee.ArrayList<Sheet> ();
	}


	public void load (File file) throws GLib.Error {
		archive.open (file);

		var reader = new Reader ();
		reader.shared_strings (load_xml ("xl/sharedStrings.xml"));
		load_workbook (reader);
	}


	private void load_workbook (Reader reader) throws GLib.Error {
		var xml_doc = load_xml ("xl/workbook.xml");

		var workbook_node = xml_doc->get_root_element ();
		if (!(workbook_node->name == "workbook" && workbook_node->ns != null &&
				workbook_node->ns->href == "http://schemas.openxmlformats.org/spreadsheetml/2006/main"))
			throw new Error.WORKBOOK ("xl/workbook.xml is incorrect");

		for (Xml.Node* node = workbook_node->children; node != null; node = node->next) {
			if (node->name == "sheets") {
				for (Xml.Node* sheet_node = node->children; sheet_node != null; sheet_node = sheet_node->next) {
					var sheet_id = (uint) uint64.parse (sheet_node->get_prop ("sheetId"));
					load_worksheet (sheet_id, reader);
				}
			}
		}
	}


	private void load_worksheet (uint sheet_id, Reader reader) throws GLib.Error {
		var path = "xl/worksheets/sheet%u.xml".printf (sheet_id);
		var doc = load_xml (path);

		var sheet = reader.worksheet (doc);
		sheets.add (sheet);
	}


	private Xml.Doc* load_xml (string path) throws GLib.Error {
		string xml;
		var tmp = archive.extract (path);
		FileUtils.get_contents (tmp.get_path (), out xml);
		return Xml.Parser.read_memory (xml, xml.length);
	}


	public void save_as (File file) throws GLib.Error {
		var writer = new Writer ();

		for (var i = 0; i < sheets.size; i++)
			store_worksheet (sheets[i], i + 1, writer);

		string xml;
		writer.shared_strings ()->dump_memory_enc (out xml, null, "UTF-8");
		xml = Utils.fix_line_ending (xml);
		var io = archive.add_from_stream ("xl/sharedStrings.xml");
		io.output_stream.write (xml.data);

		archive.write (file);
	}


	private void store_worksheet (Sheet sheet, uint sheet_id, Writer writer) throws GLib.Error {
		Xml.Doc* doc = writer.worksheet (sheet);

		string xml;
		doc->dump_memory_enc (out xml, null, "UTF-8");
		xml = Utils.fix_line_ending (xml);

		var path = "xl/worksheets/sheet%u.xml".printf (sheet_id);
		var io = archive.add_from_stream (path);
		io.output_stream.write (xml.data);
	}


	public Sheet sheet (int index) {
		return sheets[index];
	}
}


}
