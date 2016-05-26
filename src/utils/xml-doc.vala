// This file is part of GNOME Games. License: GPLv3

private class Games.XmlDoc: Object {
	private Xml.Doc* doc;

	public XmlDoc.from_data (uint8[] data) throws Error {
		doc = Xml.Parser.parse_memory ((string) data, data.length);
	}

	~XmlDoc () {
		if (doc != null)
			delete doc;
	}

	public string? get_content (string xpath, Xml.Node* current_node = null) {
		Xml.Node* node = get_node (xpath, current_node);
		if (node == null)
			return null;

		return node->get_content ();
	}

	public int count_nodes (string xpath, Xml.Node* from_node = null) {
		var ctx = new Xml.XPath.Context (doc);
		if (from_node != null)
			ctx.node = from_node;

		Xml.XPath.Object* obj = ctx.eval_expression (xpath);
		if (obj->nodesetval == null)
			return 0;

		var count = obj->nodesetval->length ();

		delete obj;

		return count;
	}

	private Xml.Node* get_node (string xpath, Xml.Node* from_node = null) {
		var ctx = new Xml.XPath.Context (doc);
		if (from_node != null)
			ctx.node = from_node;

		Xml.XPath.Object* obj = ctx.eval_expression (xpath);
		if (obj->nodesetval == null)
			return null;

		Xml.Node* first_node = obj->nodesetval->item (0);

		delete obj;

		return first_node;
	}
}
