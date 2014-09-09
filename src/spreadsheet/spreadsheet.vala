namespace Spreadsheet {


public interface Spreadsheet : Object {
	public abstract void open (File f) throws Error;
	public abstract Sheet sheet (int index);
}


}
