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

		/* load shared string */
		var shared_strings = SharedStrings.load_from_xlsx (archive);

		/* loading a sheet */
		/* FIXME ain't a proper way, son */
		var tmp = archive.extract ("xl/worksheets/sheet1.xml");
		string xml;
		FileUtils.get_contents (tmp.get_path (), out xml);
		var xml_doc = Xml.Parser.read_memory (xml, xml.length);

		var sheet = new Sheet ();
		sheet.load_from_xml (xml_doc, shared_strings);
		sheets.add (sheet);
		/* end of sheet loading */
	}


	public void save_as (File file) throws GLib.Error {
		var sheet = sheets[0];

		Gee.List<StringValue> shared_strings = new Gee.ArrayList<StringValue> ();
		string xml = sheet.to_xml (ref shared_strings);

		foreach (var i in shared_strings)
			stdout.printf ("SI %s\n", i.to_string ());

		SharedStrings.store_to_xlsx (shared_strings, archive);
		var io = archive.add_from_stream ("xl/worksheets/sheet1.xml");
		io.output_stream.write (xml.data);

		archive.write (file);
	}


	public Sheet sheet (int index) {
		return sheets[index];
	}
}


}
