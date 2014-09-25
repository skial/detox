package dtx.std;

import dtx.DOMNode;

/**
 * ...
 * @author Skial Bainn
 */

class Tools {
	
	/**
		A reference to the `document` element or node to be used as a global.
		
		For example, when writing `"#myelm".find()`, this will become `Tools.document.find("#myelm")`.
		
		This is exposed not as a full `js.html.Document` but rather as a `Node` that happens to have `querySelector` or `querySelectorAll` methods.
		This is done so that you can artificially set an element to your "document", which is useful for running unit tests etc.
		
		If `setDocument` has not been called, on JS the default value will be the HTML Document object (`document` in Javascript).
		On other platforms, the default value will be `Xml.parse("<html></html>")`.
	**/
	public static var document(get_document,null):DocumentOrElement;

	static inline function get_document():DocumentOrElement {
		if (document == null) {
			document = cast Xml.parse("<html></html>");
		}
		return document;
	}
	
	/**
		A helper function to turn a single node into a collection.
		
		Usage: `someNode.toCollection()`
	**/
	public static function toCollection(n:DOMNode):DOMCollection {
		return new DOMCollection([n]);
	}
	
	/**
		Search the current `document` to fetch all elements matching a CSS selector.
		
		Usage: `"#myElm".find().addClass("shiny");`
		
		This uses `dtx.single.Traversing.find(Detox.document, selector)` as it's implementation.
		
		@param selector A CSS selector used to match nodes in the document.
		@return A DOMCollection containing all matching nodes, or an empty collection if no match was found.
	**/
	public static function find(selector:String):DOMCollection {
		return dtx.single.Traversing.find(document, selector);
	}
	
	/**
		Create a new element with the given tag name.
		
		Usage: `"div".create().setText("Hello World!")`
		
		@param tagName The name of the element to be created.  Must begin with [a-zA-z_:] and then have only [a-zA-Z0-9_:.].  If the tagName is null, the function will return null.
		@return The new element as a DOMNode, or `null` if an error occured.
	**/
	public static function create(tagName:String):DOMNode {
		var elm:DOMNode = null;
		if (tagName != null) {
			// Haxe doesn't validate the name, so we should.
			// I'm going to use a simplified (but not entirely accurate) validation.  See:
			// http://stackoverflow.com/questions/3158274/what-would-be-a-regex-for-valid-xml-names
			
			// If it is valid, create, if it's not, return null
			var valid = ~/^[a-zA-Z_:]([a-zA-Z0-9_:\.])*$/;
			elm = (valid.match(tagName)) ? cast Xml.createElement(tagName) : null;
		}
		return elm;
	}
	
	static var firstTag:EReg = ~/<([a-z]+)[ \/>]/;
	
	/**
		Parse a given Xml string and return a DOMCollection.
		
		Usage: `'<a href="/$page/">$name</a>'.parse().addClass("btn")`
		
		If there was an error parsing the xml, the resulting DOMCollection will be empty and no error will be given.
		
		This is implemented by creating a parent element and calling `parent.setInnerHTML(xml)`.
		This means that the collection does not contain a document node, but rather all the nodes in your fragment.
		For example `var collection = "<p>Para</p> Text Node <div>Div</div>".parse()` would result in `collection.length==3`.
		On Javascript, care is taken to make sure the parent tag is correct for whatever HTML you are parsing, as there are rules about which child tags can belong to certain parent tags.
		
		On Javascript, the browsers built in HTML/Xml parser is used via `setInnerHTML`.
		On other targets, either `Xml.parse` or `haxe.xml.Parser.parse` is used, depending on the platform and if the string has an ampersand.
		(Note: `haxe.xml.Parser.parse()` handles HTML entities slightly better than `Xml.parse()`.)
		
		@param xml The XML or HTML string to parse.  On Javascript the browser is fairly tolerant of both Xml and Html, and invalid code also.  On other platforms it must be valid Xml.
		@return A DOMCollection containing the parsed nodes.  It will be empty if the string is null, empty (""), or was unable to be parsed correctly.
	**/
	public static function parse(xml:String):DOMCollection {
		var q:DOMCollection;
		if (xml != null && xml != "") {
			var n:DOMNode = create("div");
			
			//
			// TODO: report this bug to haxe mailing list.
			// this is allowed:
			// n.setInnerHTML("");
			// But this doesn't get swapped out to it's "using" function
			// Presumably because this class is a dependency of the Detox?
			// Either way haxe shouldn't do that...
			dtx.single.ElementManipulation.setInnerHTML(n, xml);
			q = dtx.single.Traversing.children(n, false);
			
			#if (neko || cpp)
			// This is a workaround for a glitch in neko where parse("<!-- Comment -->") generates
			// a collection with 2 nodes - the comment and an empty text node.  Not sure if it comes
			// from a child of these or from neko's XML parser...
			// Note - also happens on CPP.
			for (child in q)
			{
				if (dtx.single.ElementManipulation.isTextNode(child) && child.nodeValue == "")
				{
					q.removeFromCollection(child);
				}
			}
			#end
		}
		else
		{
			q = new DOMCollection();
		}
		return q;
	}
	
	/**
		Set the `document` to be used as our global document, for `find()` etc to be based on.
		
		If `newDocument` is null, or a type other than DOCUMENT_NODE or ELEMENT_NODE, then `document` will remain unchanged.
	**/
	public static function setDocument(newDocument:DOMNode):Void
	{
		// Only change the document if it has the right NodeType
		if (newDocument != null)
		{
			if (newDocument.nodeType == dtx.DOMType.DOCUMENT_NODE
				|| newDocument.nodeType == dtx.DOMType.ELEMENT_NODE)
			{
				// Because of the NodeType we can safely use this node as our document
				document = cast newDocument;
			}
		}
	}
	
}