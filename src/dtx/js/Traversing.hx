package dtx.js;

import dtx.DOMNode;
import dtx.single.ElementManipulation;

class Traversing {

	static public inline function find(node:DOMNode, selector:String):DOMCollection
	{
		var newDOMCollection = new DOMCollection();
		if (node != null && ElementManipulation.isElement(node) || dtx.single.ElementManipulation.isDocument(node))
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
		return newDOMCollection;
	}
	
}