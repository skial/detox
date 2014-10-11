package dtx.std;

import dtx.DOMNode;
import dtx.single.ElementManipulation;

class Traversing {

	static public inline function find(node:DOMNode, selector:String):DOMCollection
	{
		var newDOMCollection = new DOMCollection();
		if (node != null && ElementManipulation.isElement(node) || dtx.single.ElementManipulation.isDocument(node))
		{
			var results = selecthxml.SelectDom.runtimeSelect(node, selector);
			// SelectHxml also includes our original node in the search.
			// We should match the querySelectorAll() functionality from JS, which
			// only searches descendant nodes.  Therefore, remove the current node
			// if it was returned as a match.
			results.remove(node);
			
			newDOMCollection.addCollection(results);
		}
		return newDOMCollection;
	}
	
}