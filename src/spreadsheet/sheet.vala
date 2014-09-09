namespace Spreadsheet {


public class Cell : Object {
	public int style;
	public string? type;
	public string val;
}


public class Row : Object {
	public float height;
	public bool custom_height;
	public Gee.List<Cell> cells;


	public Row () {
		cells = new Gee.ArrayList<Cell> ();
	}
}



public class Sheet : Object {
	private Spreadsheet spreadsheet;
	Xml.Node* sheet_data;

	public Gee.List<Row> rows;


	public Sheet (Spreadsheet _spreadsheet) {
		spreadsheet = _spreadsheet;
		rows = new Gee.ArrayList<Row> ();
	}


	public void put_text (int x, int y, string text) {
		
	}


	public string get_xml () {
		return "";
	}


	private void read_sheet_row (Xml.Node *xml_node) {
		for (Xml.Node* iter = xml_node->children; iter != null; iter = iter->next) {
			if (iter->type == Xml.ElementType.ELEMENT_NODE) {
				switch (iter->name) {
				case "c":
					
					break;
				default:
					stdout.printf ("Unsupported element %s\n", iter->name);
					break;
				}
			}
		}
	}


	private void read_sheed_data (Xml.Node *xml_node) {
		for (Xml.Node* iter = xml_node->children; iter != null; iter = iter->next) {
			if (iter->type == Xml.ElementType.ELEMENT_NODE) {
				switch (iter->name) {
				case "row":
					read_sheet_row (iter);
					break;
				default:
					stdout.printf ("Unsupported element %s\n", iter->name);
					break;
				}
			}
		}
	}


	public void read_sheet_xml (Xml.Doc *xml_doc) {
		Xml.Node* xml_root = xml_doc->get_root_element ();

		for (Xml.Node* iter = xml_root->children; iter != null; iter = iter->next) {
			if (iter->type == Xml.ElementType.ELEMENT_NODE) {
				switch (iter->name) {
				case "sheetData":
					read_sheed_data (iter);
					break;
				default:
					stdout.printf ("Unsupported element %s\n", iter->name);
					break;
				}
			}
		}
	}
}


}
