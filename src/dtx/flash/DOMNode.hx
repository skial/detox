package dtx.flash;

import flash.xml.XML;
import flash.xml.XMLList;

/**
 * ...
 * @author Skial Bainn
 */
@:forward( 
	nodeType, nodeValue, nodeName,
	attributes, childNodes, parentNode, firstChild, lastChild,
	nextSibling, previousSibling, textContent, _getInnerHTML,
	_setInnerHTML, 	hasChildNodes, getAttribute, setAttribute,
	removeAttribute, removeChild, cloneNode, _empty
)
abstract DOMNode(dtx.std.DOMNode)
from Xml to Xml
from dtx.std.DOMNode to dtx.std.DOMNode {

	public inline function new(v:dtx.std.DOMNode) {
		this = v;
	}
	
	@:access(Xml)
	public function appendChild( newChild:DOMNode ):DOMNode {
		var xml:XML = (this:Xml)._node;
		if( this.nodeType!=Xml.Element && this.nodeType!=Xml.Document )
			throw "Bad NodeType";
		xml.appendChild( (newChild:Xml)._node );
		return newChild;
	}
	
	@:access(Xml)
	public function insertBefore( newChild:DOMNode, refChild:DOMNode ):DOMNode {
		if ( newChild.parentNode!=null ) newChild.parentNode.removeChild( newChild );
		if( this.nodeType!=Xml.Element && this.nodeType!=Xml.Document )
			throw "bad nodeType";
		(this:Xml)._node.insertChildBefore( (refChild:Xml)._node, (newChild:Xml)._node );
		return newChild;
	}
	
	@:access(Xml)
	function get_nextSibling():DOMNode {
		// get the flash node
		var xml:XML = (this:Xml)._node;
		// get the index
		var i = xml.childIndex();
		var sibling:Xml = null;
		// get the siblings
		var parent = xml.parent();
		if ( parent!=null ) {
			var children:XMLList = parent.children();
			// get the previous item
			var index = i + 1;
			if ( index>=0 && index<children.length() ) {
				sibling = Xml.wrap( children[index] );
			}
		}
		return sibling;
	}
	
	@:access(Xml)
	function get_previousSibling():DOMNode {
		// get the flash node
		var xml:XML = (this:Xml)._node;
		// get the index
		var i = xml.childIndex();
		// get the siblings
		var children:XMLList = xml.parent().children();
		// get the previous item
		var sibling:Xml = null;
		var index = i - 1;
		if ( index>=0 && index<children.length() ){
			sibling = Xml.wrap( children[index] );
		}
		return sibling;
	}
	
}