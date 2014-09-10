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
		
	}


	public void save_as (File file) throws GLib.Error {
		archive.write (file);
	}


	public Sheet sheet (int index) {
		return sheets[index];
	}
}


}
