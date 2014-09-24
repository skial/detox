package dtx.js;
import js.html.Node;

/**
 * ...
 * @author Skial Bainn
 */
abstract DOMType(Int) from Int to Int {
	public static var DOCUMENT_NODE = Node.DOCUMENT_NODE;
	public static var ELEMENT_NODE = Node.ELEMENT_NODE;
	public static var TEXT_NODE = Node.TEXT_NODE;
	public static var COMMENT_NODE = Node.COMMENT_NODE;
}