// This file is part of GNOME Games. License: GPLv3

public class Games.DataInputStream : Object {
	private File file;

	public DataInputStream (File file) {
		this.file = file;
	}

	public bool has_data (size_t offset, uint8[] value) throws Error {
		var stream = file.read ();
		stream.seek (offset, SeekType.SET);

		var buffer = new uint8[value.length];
		stream.read (buffer);

		return Memory.cmp (value, buffer, value.length) == 0;
	}
}
