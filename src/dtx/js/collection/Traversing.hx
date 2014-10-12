package dtx.js.collection;

import dtx.DOMNode;

class Traversing {

	static public inline function find(collection:DOMCollection, selector:String):DOMCollection {
		var newDOMCollection = new DOMCollection();
		if (collection != null && selector != null && selector != "")
		{
			for (node in collection)
			{
				if (dtx.single.ElementManipulation.isElement(node) || dtx.single.ElementManipulation.isDocument(node))
				{
					var element:DOMElement = cast node;
					if (untyped __js__("document.querySelectorAll"))
					{
						var results = element.querySelectorAll(selector);
						newDOMCollection.addNodeList(results);
					}
					else
					{
						var engine:String->DOMNode->Array<DOMNode> = untyped __js__("
							(('undefined' != typeof Sizzle && Sizzle) ||
							(('undefined' != typeof jQuery) && jQuery.find) ||
							(('undefined' != typeof $) && $.find))
						");
						var results = engine(selector, node);
						newDOMCollection.addCollection(results);
					}
				}
			}
		}
		return newDOMCollection;
	}
	
}