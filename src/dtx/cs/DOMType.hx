package dtx.cs;

/**
 * ...
 * @author Skial Bainn
 */
abstract DOMType(Xml.XmlType) from Xml.XmlType to Xml.XmlType {
	public static var DOCUMENT_NODE = untyped Xml.RealXmlType.Document;
	public static var ELEMENT_NODE = untyped Xml.RealXmlType.Element;
	public static var TEXT_NODE = untyped Xml.RealXmlType.PCData;
	public static var COMMENT_NODE = untyped Xml.RealXmlType.Comment;
}