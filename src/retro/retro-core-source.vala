// This file is part of GNOME Games. License: GPLv3

public class Games.RetroCoreSource : Object {
	private string platform;
	private string[] mime_types;

	private string module_path;
	private bool searched;

	public RetroCoreSource (string platform, string[] mime_types) {
		this.platform = platform;
		this.mime_types = mime_types;
		module_path = null;
		searched = false;
	}

	public string get_platform () {
		return platform;
	}

	public string get_module_path () throws Error {
		ensure_module_is_found ();

		return module_path;
	}

	private void ensure_module_is_found () throws Error {
		if (!searched) {
			searched = true;
			search_module ();
		}

		if (module_path == null)
			throw new RetroError.MODULE_NOT_FOUND (_("No module found for platform '%s' and MIME types [ '%s' ]."), platform, string.joinv ("', '", mime_types));
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

			var module_file = core_descriptor.get_module_file ();
			module_path = module_file.get_path ();

			return true;
		}
		catch (Error e) {
			debug (e.message);

			return false;
		}
	}
}
