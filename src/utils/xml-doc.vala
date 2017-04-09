// This file is part of GNOME Games. License: GPL-3.0+.

private class Games.XmlDoc: Object {
	private delegate void NodeCallback (Xml.Node* node);

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

	public string[] get_contents (string xpath, Xml.Node* current_node = null) {
		string[] contents = {};
		foreach_node (xpath, current_node, (node) => contents += node->get_content () );

		return contents;
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

	private void foreach_node (string xpath, Xml.Node* from_node, NodeCallback callback) {
		var ctx = new Xml.XPath.Context (doc);
		if (from_node != null)
			ctx.node = from_node;

		Xml.XPath.Object* obj = ctx.eval_expression (xpath);
		if (obj->nodesetval == null)
			return;

		for (int i = 0; i < obj->nodesetval->length (); i++)
			callback (obj->nodesetval->item (i));

		delete obj;
	}
}
