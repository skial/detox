package dtx.std;

/**
 * ...
 * @author Skial Bainn
 */
abstract DocumentOrElement<T>(T) to T {
	inline function new(n:T) {
		this = n;
	}

	/** On non-JS platforms, all nodes are Xml objects, and all can be used with the `selecthxml` selector engine, so accept casts from all nodes. **/
	@:from static inline function fromXml( x:T ) return new DocumentOrElement<T>( x );
}