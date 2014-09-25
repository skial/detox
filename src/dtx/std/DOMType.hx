package dtx.std ;

/**
 * ...
 * @author Skial Bainn
 */
abstract DOMType(Xml.XmlType) from Xml.XmlType to Xml.XmlType {
	public static var DOCUMENT_NODE = untyped 'document';
	public static var ELEMENT_NODE = untyped 'element';
	public static var TEXT_NODE = untyped 'pcdata';
	public static var COMMENT_NODE = untyped 'comment';
}