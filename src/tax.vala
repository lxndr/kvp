namespace Kv {


public class Tax : Entity
{
	public uint8 month { get; set; }
	public uint16 year { get; set; }
	public int64 account { get; set; }
	public int64 service { get; set; }
	public string service_name {get; set; }


	construct {
	}


	public override string get_display_name () {
		return "";//name;
	}


	public override string[] get_view_properties () {
		string[] properties = {
			"service_name"
		};

		return properties;
	}
}


}
