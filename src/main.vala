// This file is part of GNOME Games. License: GPLv3

private extern const string GETTEXT_PACKAGE;
private extern const string GNOMELOCALEDIR;

int main (string[] args) {
	Intl.bindtextdomain (GETTEXT_PACKAGE, GNOMELOCALEDIR);
	Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
	Intl.textdomain (GETTEXT_PACKAGE);

	var app = new Games.Application ();
	return app.run (args);
}
