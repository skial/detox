package dtx.neko;

/**
 * ...
 * @author Skial Bainn
 */
@:forward( 
	nodeType, nodeValue, nodeName,
	attributes, childNodes, parentNode, firstChild, lastChild,
	nextSibling, previousSibling, textContent, _getInnerHTML,
	hasChildNodes, getAttribute, setAttribute, removeAttribute,
	appendChild, insertBefore, removeChild, cloneNode, _empty,
	toDOMCollection, fromDOMCollection
)
@:access(dtx)
abstract DOMNode(dtx.std.DOMNode) 
from Xml to Xml
from dtx.std.DOMNode to dtx.std.DOMNode {

	public inline function new(v:dtx.std.DOMNode) {
		this = v;
	}
	
	@:allow(dtx)
	function _setInnerHTML( html:String ):String {
		var xmlDocNode:Xml = null;
		try {
			// Neko's native parser has issues with over-encoding HTML entities.
			// The Haxe based parser is a little better, it at least gets <, &, and > correct.
			xmlDocNode = html.indexOf("&")>-1 ? haxe.xml.Parser.parse( html ) : Xml.parse( html );
		}
		catch ( e:Dynamic ) {
			xmlDocNode = Xml.createDocument();
		}
			this._empty();
		for ( child in Lambda.list(xmlDocNode) ) {
			(this:Xml).addChild( child );
		}
		return html;
	}
	
}