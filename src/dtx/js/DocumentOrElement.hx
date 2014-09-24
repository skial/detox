package dtx.js;

/**
 * ...
 * @author Skial Bainn
 */
abstract DocumentOrElement(DOMNode) to DOMNode {
	inline function new(n:DOMNode) {
		this = n;
	}

	/** Allow casts from Element **/
	@:from static inline function fromElement( e:js.html.Element ) return new DocumentOrElement( e );
	
	/** Allow casts from Document **/
	@:from static inline function fromDocument( d:js.html.Document ) return new DocumentOrElement( d );
	
	/** Allow access to the `querySelector` function **/
	public inline function querySelector( selectors:String ):js.html.Element return untyped this.querySelector( selectors );
	
	/** Allow access to the `querySelectorAll` function **/
	public inline function querySelectorAll( selectors:String ):js.html.NodeList return untyped this.querySelectorAll( selectors );
}