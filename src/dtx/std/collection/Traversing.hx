package dtx.std.collection;

import dtx.DOMNode;

class Traversing
{

	static public inline function find(collection:DOMCollection, selector:String):DOMCollection
	{
		var newDOMCollection = new DOMCollection();
		if (collection != null && selector != null && selector != "")
		{
			for (node in collection)
			{
				if (dtx.single.ElementManipulation.isElement(node) || dtx.single.ElementManipulation.isDocument(node))
				{
					// This next line is a workaround to a bug in selecthxml
					// See http://code.google.com/p/selecthxml/issues/detail?id=2
					// And http://code.google.com/p/selecthxml/issues/detail?id=3
					var results = selecthxml.SelectDom.runtimeSelect(node, selector);
					
					// SelectHxml also includes our original node in the search.
					// We should match the querySelectorAll() functionality from JS, which
					// only searches descendant nodes.  Therefore, remove the current node
					// if it was returned as a match.
					results.remove(node);
					
					newDOMCollection.addCollection(results);
				}
			}
		}
		return newDOMCollection;
	}
	
}