// This file is part of GNOME Games. License: GPLv3

namespace Games.Fingerprint {
	private string get_for_file_uri (string uri) {
		var file = File.new_for_uri (uri);
		var istream = file.read ();

		return get_for_file_input_stream (istream);
	}

	private string get_for_file_input_stream (FileInputStream file_stream) {
		file_stream.seek (0, SeekType.END);
		var size = (size_t) file_stream.tell ();

		file_stream.seek (0, SeekType.SET);
		var bytes = file_stream.read_bytes (size);

		return Checksum.compute_for_bytes (ChecksumType.MD5, bytes);
	}
}
