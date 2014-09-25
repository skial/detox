package dtx.macro;

/**
 * ...
 * @author Skial Bainn
 */
@:forward( 
	nodeType, nodeValue, nodeName,
	attributes, childNodes, parentNode, firstChild, lastChild,
	nextSibling, previousSibling, textContent, _getInnerHTML,
	hasChildNodes, getAttribute, setAttribute, removeAttribute,
	appendChild, insertBefore, removeChild, cloneNode, _empty
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
			xmlDocNode = haxe.xml.Parser.parse( "<doc>" + html + "</doc>" ).firstChild();
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