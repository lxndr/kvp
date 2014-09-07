namespace Archive {


public class Zip {
	public Zip () {
	}


	private string read_string (InputStream stm, size_t length) {
		var buf = string.nfill (length, '.');
		stm.read (buf.data);
		return buf;
	}


	public void read_cdir (DataInputStream stm) {
		var sig = stm.read_uint32 ();
		if (sig != 0x02014b50)
			error ("Wrong signature of Central Directory");

		stm.skip (12);
		var crc32 = stm.read_uint32 ();
		var compressed_size = stm.read_uint32 ();
		var uncompressed_size = stm.read_uint32 ();

		var fname_length = stm.read_uint16 ();
		var efield_length = stm.read_uint16 ();
		var comment_length = stm.read_uint16 ();
		var dnum_start = stm.read_uint16 ();
		var internal_attrs = stm.read_uint16 ();
		var external_attrs = stm.read_uint32 ();
		var header_offset = stm.read_uint32 ();

		var fname = read_string (stm, fname_length);
		stm.skip (efield_length);
		stm.skip (comment_length);

		stdout.printf ("FILE: %s\n", fname);
	}


	public void open (GLib.File f) {
		var stm = new DataInputStream (f.read ());
		stm.byte_order = DataStreamByteOrder.LITTLE_ENDIAN;


		/* reading End of Central Directory */
		/* FIXME: it has to do some searching */
		stm.seek (-0x16, SeekType.END);
		var sig = stm.read_uint32 ();
		if (sig != 0x06054b50)
			error ("Could not find End of Central Directory");

		stm.skip (2); /*  */
		stm.skip (2); /*  */

		var cdir_count = stm.read_uint16 ();
		stdout.printf ("cdir_count: %u\n", cdir_count);

		stm.skip (2); /*  */

		var cdir_size = stm.read_uint32 ();
		stdout.printf ("cdir_size: %x\n", cdir_size);
		var cdir_offset = stm.read_uint32 ();
		stdout.printf ("cdir_offset: %x\n", cdir_offset);

		stm.seek (cdir_offset, SeekType.SET);
		for (var i = 0; i < cdir_count; i++)
			read_cdir (stm);


#if 0
		var end_offset = stm.tell ();
		stm.seek (0, SeekType.SET);

		while (stm.tell () < end_offset) {
			var sig = stm.read_uint32 ();
			if (sig != 0x04034b50)
				error ("Unknown Zip signature 0x%X", sig);

			var version = stm.read_uint16 ();

			var general_flags = stm.read_uint16 ();
			if ((general_flags & 0x00000008) > 0)
				stdout.printf ("bit3\n");

			var compression_method = stm.read_uint16 ();

			var mod_file_time = stm.read_uint16 ();

			var mod_file_date = stm.read_uint16 ();

			var crc32 = stm.read_uint32 ();

			var compressed_size = stm.read_uint32 ();

			var uncompressed_size = stm.read_uint32 ();

			var name_length = stm.read_uint16 ();
			var extra_length = stm.read_uint16 ();
			if (extra_length > 0)
				stdout.printf ("Got extra field\n");

			var file_name = read_string (stm, name_length);
			stdout.printf ("File: %s\n", file_name);

			stm.skip (extra_length);

			stm.skip (compressed_size);
		}
#endif

	}
}


}
