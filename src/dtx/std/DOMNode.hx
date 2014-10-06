package dtx.std ;

/**
 * ...
 * @author Skial Bainn
 */
@:forward( nodeType, nodeValue, nodeName, removeChild )
abstract DOMNode(Xml) from Xml to Xml {

	public var attributes(get, never):Iterable<{ name:String, value:String }>;
	public var childNodes(get, never):Iterable<DOMNode>;
	
	public var parentNode(get, never):DOMNode;
	public var firstChild(get, never):DOMNode;
	public var lastChild(get, never):DOMNode;
	public var nextSibling(get, never):DOMNode;
	public var previousSibling(get, never):DOMNode;
	public var textContent(get, set):String;
	
	public inline function new(v:Xml) {
		this = v;
	}
	
	/*@:to public inline function toDOMCollection():DOMCollection {
		return new DOMCollection( [this] );
	}*/
	
	/*@:from public static inline function fromDOMCollection(v:DOMCollection):DOMNode {
		return v.collection[0];
	}*/
	
	@:allow(dtx)
	function _getInnerHTML():String {
		var html = "";
		for ( child in this ) {
			html += child.toString();
		}
		return html;
	}
	
	@:allow(dtx)
	function _setInnerHTML( html:String ):String {
		var xmlDocNode:Xml = null;
		try {
			xmlDocNode = Xml.parse( html );
		}
		catch ( e:Dynamic ) {
			xmlDocNode = Xml.createDocument();
		}
			_empty();
		for ( child in Lambda.list(xmlDocNode) ) {
			this.addChild( child );
		}
		return html;
	}
	
	public inline function hasChildNodes():Bool {
		return this.iterator().hasNext();
	}

	public inline function getAttribute( name:String ):String {
		return this.get( name );
	}

	public inline function setAttribute( name:String, value:String ):Void {
		this.set( name, value );
	}

	public inline function removeAttribute( name:String ):Void {
		this.remove( name );
	}

	@:access(Xml)
	public inline function appendChild( newChild:DOMNode ):DOMNode {
		this.addChild( newChild );
		return newChild;
	}

	@:access(Xml)
	public function insertBefore( newChild:DOMNode, refChild:DOMNode ):DOMNode {
		var targetIndex = 0;
		var iter = this.iterator();
		while ( iter.hasNext() && iter.next()!=refChild ) {
			targetIndex++;
		}
		this.insertChild( newChild, targetIndex );
		return newChild;
	}

	public function removeChild( oldChild:DOMNode ):DOMNode {
		this.removeChild( oldChild );
		return oldChild;
	}

	public function cloneNode( deep:Bool ):DOMNode {
		var clone = switch this.nodeType {
			case Xml.Element: Xml.createElement( this.nodeName );
			case Xml.PCData: Xml.createPCData( this.nodeValue );
			case Xml.CData: Xml.createCData( this.nodeValue );
			case Xml.Comment: Xml.createComment( this.nodeValue );
			case Xml.DocType: Xml.createDocType( this.nodeValue );
			case Xml.ProcessingInstruction: Xml.createProcessingInstruction( this.nodeValue );
			case Xml.Document: Xml.createDocument();
		}
		if ( this.nodeType==Xml.Element ) {
			for ( attName in this.attributes() ) {
				clone.set( attName, this.get(attName) );
			}
		}
		if ( deep && (this.nodeType==Xml.Element || this.nodeType==Xml.Document) ) {
			for ( child in this ) {
				clone.addChild( (child:DOMNode).cloneNode(true) );
			}
		}
		return clone;
	}
	
	function get_attributes():Iterable<{ name:String, value:String }> {
		var list = new List();
		for ( a in this.attributes() ) {
			list.push({ name: a, value: this.get(a) });
		}
		return list;
	}
	
	function get_childNodes():Array<DOMNode> {
		var children = [];
		for ( n in this ) {
			children.push( n );
		}
		return children;
	}
	
	inline function get_parentNode():DOMNode {
		return this.parent;
	}

	inline function get_firstChild():DOMNode {
		return this.firstChild();
	}

	function get_lastChild():DOMNode {
		var lastChild:Xml = null;
		if ( this!=null )
			for ( child in this )
				lastChild = child;
		return lastChild;
	}

	@:access(Xml)
	function get_nextSibling():DOMNode {
		var itsTheNextOne = false;
		var p = this.parent;
		if ( p!=null ) {
			for ( child in p ){
				if ( itsTheNextOne ) {
					return child;
					break;
				}
				if ( child==this ) itsTheNextOne = true;
			}
		}
		return null;
	}

	@:access(Xml)
	function get_previousSibling():DOMNode {
		var sibling:Xml = null;
		var p = this.parent;
		if ( p!=null ) {
			for ( child in p ) {
				if ( child!=this ) {
					sibling = child;
				}
				else {
					// If it's equal, leave "sibling" set to the previous value,
					// and exit the loop...
					break;
				}
			}
		}
		return sibling;
	}

	function get_textContent():String {
		var ret = "";
		if ( this.nodeType==dtx.DOMType.ELEMENT_NODE || this.nodeType==dtx.DOMType.DOCUMENT_NODE ) {
			var allDescendants = dtx.single.Traversing.descendants( this, false );
			var textDescendants = allDescendants.filter(function(x:Xml) {
				return x.nodeType==dtx.DOMType.TEXT_NODE;
			});
			
			
			var s = new StringBuf();
			for ( textNode in textDescendants ) {
				s.add( textNode.nodeValue );
			}
			
			ret = s.toString();
		}
		else {
			ret = this.nodeValue;
		}
		return ret;
	}

	function _empty():Void {
		for ( child in Lambda.list(this) ) {
			removeChild( child );
		}
	}

	function set_textContent( text:String ):String {
		if ( this.nodeType==dtx.DOMType.ELEMENT_NODE || this.nodeType==dtx.DOMType.DOCUMENT_NODE ) {
			_empty();
			var textNode = Xml.createPCData( text );
			this.addChild( textNode );
		}
		else {
			this.nodeValue = text;
		}
		return text;
	}
	
}