// This file is part of GNOME Games. License: GPLv3

namespace Games.Fingerprint {
	private string get_for_file_uri (string uri) throws Error {
		var file = File.new_for_uri (uri);
		var istream = file.read ();

		return get_for_file_input_stream (istream);
	}

	private string get_for_file_input_stream (FileInputStream file_stream) throws Error {
		file_stream.seek (0, SeekType.END);
		var size = (size_t) file_stream.tell ();

		file_stream.seek (0, SeekType.SET);
		var bytes = file_stream.read_bytes (size);

		return Checksum.compute_for_bytes (ChecksumType.MD5, bytes);
	}
}

public class Games.FingerprintUid: Object, Uid {
	private string uri;
	private string prefix;
	private string uid;

	public FingerprintUid (string uri, string prefix) {
		this.uri = uri;
		this.prefix = prefix;
	}

	public string get_uid () throws Error {
		if (uid != null)
			return uid;

		var fingerprint = Fingerprint.get_for_file_uri (uri);
		uid = @"$prefix-$fingerprint";

		return uid;
	}
}
