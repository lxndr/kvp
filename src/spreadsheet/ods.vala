namespace Spreadsheet {


public class ODS : Object, Spreadsheet {
	private Gee.List<Sheet> sheets;


	public ODS () {
		sheets = new Gee.ArrayList<Sheet> ();
	}


	public override void open (File f) {
		
	}


	public override Sheet sheet (int index) {
		return sheets[index];
	}
}


}
