package dtx.js;

import js.html.Node;

/**
 * ...
 * @author Skial Bainn
 */
@:forward(
	nodeType, nodeValue, nodeName,
	parentNode, firstChild, lastChild, nextSibling, previousSibling,
	removeChild, hasChildNodes, appendChild, insertBefore,
	hasAttributes, getAttribute, setAttribute, removeAttribute, // Should these only be on elements?
	textContent, cloneNode,
	addEventListener, toDOMCollection
	// Notably absent: childNodes, attributes.
	// I considered the implementations too JS specific to replicate on other platforms.
)
abstract DOMNode(Node) from Node to Node {

	public var attributes(get,never):Iterable<{ name:String, value:String }>;
	public var childNodes(get,never):Iterable<DOMNode>;
	
	public inline function new(v:Node) {
		this = v;
	}
	
	@:allow(dtx)
	function _getInnerHTML():String {
		if ( this.nodeType==DOMType.ELEMENT_NODE ) {
			var elm:js.html.Element = cast this;
			return elm.innerHTML;
		}
		else return null;
	}
	
	@:allow(dtx)
	function _setInnerHTML( html:String ):String {
		if ( this.nodeType==DOMType.ELEMENT_NODE ) {
			var elm:js.html.Element = cast this;
			elm.innerHTML = html;
		}
		return html;
	}

	function get_attributes():Iterable<{ name:String, value:String }> {
		var list = new List();
		for ( i in 0...this.attributes.length ) {
			var attNode = this.attributes[i];
			list.push({ name: attNode.nodeName, value: attNode.nodeValue });
		}
		return list;
	}

	function get_childNodes():Array<DOMNode> {
		var children = [];
		for ( i in 0...this.childNodes.length ) {
			children.push( this.childNodes.item(i) );
		}
		return children;
	}
	
}