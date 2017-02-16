// This file is part of GNOME Games. License: GPLv3

public class Games.RetroCoreSource : Object {
	private string platform;
	private string[] mime_types;

	private Retro.CoreDescriptor core_descriptor;
	private bool searched;

	public RetroCoreSource (string platform, string[] mime_types) {
		this.platform = platform;
		this.mime_types = mime_types;
		searched = false;
	}

	public string get_platform () {
		return platform;
	}

	public string get_module_path () throws Error {
		ensure_module_is_found ();

		var module_file = core_descriptor.get_module_file ();

		return module_file.get_path ();
	}

	private void ensure_module_is_found () throws Error {
		if (!searched) {
			searched = true;
			search_module ();
		}

		if (core_descriptor == null)
			throw new RetroError.MODULE_NOT_FOUND (_("No module found for platform '%s' and MIME types [ '%s' ]."), platform, string.joinv ("', '", mime_types));

		if (core_descriptor.has_firmwares (platform))
			foreach (var firmware in core_descriptor.get_firmwares (platform))
				check_firmware_is_valid (firmware);
	}

	private void search_module () throws Error {
		Retro.ModuleQuery.foreach_core_descriptor (parse_core_descriptor);
	}

	private bool parse_core_descriptor (Retro.CoreDescriptor core_descriptor) {
		try {
			if (!core_descriptor.get_is_emulator ())
				return false;

			if (!core_descriptor.has_platform (platform))
				return false;

			var supported_mime_types = core_descriptor.get_mime_type (platform);
			foreach (var mime_type in mime_types)
				if (!(mime_type in supported_mime_types))
					return false;

			this.core_descriptor = core_descriptor;

			return true;
		}
		catch (Error e) {
			debug (e.message);

			return false;
		}
	}

	private void check_firmware_is_valid (string firmware) throws Error {
		if (!core_descriptor.get_is_firmware_mandatory (firmware))
			return;

		var platforms_dir = Application.get_platforms_dir ();
		var firmware_dir = File.new_for_path (@"$platforms_dir/$platform/system");
		var firmware_path = core_descriptor.get_firmware_path (firmware);
		var firmware_file = firmware_dir.get_child (firmware_path);
		if (!firmware_file.query_exists ())
			throw new RetroError.FIRMWARE_NOT_FOUND (_("This games requires the %s firmware file to run."), firmware_file.get_path ());

		var has_md5 = core_descriptor.has_firmware_md5 (firmware);
		var has_sha512 = core_descriptor.has_firmware_sha512 (firmware);
		if (!has_md5 || !has_sha512)
			return;

		var stream = firmware_file.read ();

		stream.seek (0, SeekType.END);
		var size = (size_t) stream.tell ();
		stream.seek (0, SeekType.SET);
		var bytes = stream.read_bytes (size);

		if (has_md5) {
			var md5 = core_descriptor.get_firmware_md5 (firmware);
			if (Checksum.compute_for_bytes (ChecksumType.MD5, bytes) != md5)
				throw new RetroError.FIRMWARE_NOT_FOUND (_("This games requires the %s firmware file with a MD5 fingerprint of %s to run."), firmware_file.get_path (), md5);
		}

		if (has_sha512) {
			var sha512 = core_descriptor.get_firmware_sha512 (firmware);
			if (Checksum.compute_for_bytes (ChecksumType.SHA512, bytes) != sha512)
				throw new RetroError.FIRMWARE_NOT_FOUND (_("This games requires the %s firmware file with a SHA-512 fingerprint of %s to run."), firmware_file.get_path (), sha512);
		}
	}
}
