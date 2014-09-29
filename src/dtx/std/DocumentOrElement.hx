package dtx.std;

/**
 * ...
 * @author Skial Bainn
 */
abstract DocumentOrElement(DOMNode) to DOMNode {
	inline function new(n:DOMNode) {
		this = n;
	}

	/** On non-JS platforms, all nodes are Xml objects, and all can be used with the `selecthxml` selector engine, so accept casts from all nodes. **/
	@:from static inline function fromXml( x:DOMNode ) return new DocumentOrElement( x );
}