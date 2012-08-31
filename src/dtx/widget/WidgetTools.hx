/****
* Copyright (c) 2012 Jason O'Neil
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
* 
****/

package dtx.widget;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Format;
import tink.macro.tools.MacroTools;
using tink.macro.tools.MacroTools;
using StringTools;
using Lambda;
using Detox;

class WidgetTools 
{
    /**
    * This macro is called on ANY subclass of detox.widget.Widget
    * 
    * It's purpose is to get the template for each Widget Class
    * It looks for: 
    *  - Metadata in the form: @template("<div></div>") class MyWidget ...
    *  - Metadata in the form: @loadTemplate("MyWidgetTemplate.html") class MyWidget ...
    *  - Take a guess at a filename... use current filename, but replace ".hx" with ".html"
    * Once it finds it, it overrides the get_template() method, and makes it return
    * the correct template as a String constant.  So each widget gets its own template
    */
    @:macro public static function buildWidget():Array<Field>
    {
        var widgetPos = Context.currentPos();                   // Position where the original Widget class is declared
        var localClass = haxe.macro.Context.getLocalClass();    // Class that is being declared
        var fields = haxe.macro.Context.getBuildFields();

        
        // If get_template() already exists, don't recreate it
        if (fields.exists(function (f) { return f.name == "get_template"; }) == false)
        {
            // Load the template
            var template = loadTemplate(localClass);

            if (template != null)
            {
                // Process the template looking for partials, variables etc
                // This function processes the template, and returns any binding statements
                // that may be needed for bindings / variables etc.
                var fnBody = new Array<Expr>();
                var result = processTemplateBindings(template);
                for (expr in result.bindings)
                {
                    fnBody.push(expr);
                }
                fields.push(createField_refresh(fnBody, false));

                // Create and add the get_template() field.  
                template = result.template;
                fields.push(createField_get_template(template, widgetPos));
            }
            return fields;
        }
        else
        {
            // Leave the fields as is
            return null;
        }
    }

    /**
    * This build macro runs on every subclass of DataWidget.
    * It trsfd
    */
    @:macro public static function buildDataWidget():Array<Field>
    {
        var p = Context.currentPos();                           // Position where the original Widget class is declared
        var localClass = haxe.macro.Context.getLocalClass();    // Class that is being declared
        var fields = haxe.macro.Context.getBuildFields();

        var dataType = localClass.get().superClass.params[0];

        // If get_template() already exists, don't recreate it
        if (fields.exists(function (f) { return f.name == "get_template"; }) == false)
        {
            // Load the template
            var template = loadTemplate(localClass);
            var fnBody = new Array<Expr>();

            // Collect all the statements we use
            switch (dataType)
            {
                case TInst(t,params):
                    var dataClass = t.get();
                    for (expr in setupBindingVariables(dataClass))
                    {
                        fnBody.push(expr);
                    }
                default:
                    haxe.macro.Context.error("DataWidget can only have a class instance as a type parameter", p);

            }
            var result = processTemplateBindings(template);
            for (expr in result.bindings)
            {
                fnBody.push(expr);
            }
            
            // Create the get_template() field and the refresh() field
            fields.push(createField_refresh(fnBody, true));
            fields.push(createField_get_template(result.template, p));
        }


        return fields;
    }

    /**
      * Helper functions
      */
    #if macro

    static function loadTemplate(localClass:Null<Ref<ClassType>>):String
    {
        var p = localClass.get().pos;                           // Position where the original Widget class is declared
        var className = localClass.toString();                  // Name of the class eg "my.pack.MyType"
        var meta = localClass.get().meta;                       // Metadata of the this class
        
        var templateFile:String;                                // If we are loading template from a file, this is the filename
        var template:String = "";                               // If the template is directly in metadata, use that.

        //
        // IF TEMPLATE IS DECLARED IN METADATA
        //
        if (meta.has("template"))
        {
            for (metadataItem in meta.get())
            {
                if (metadataItem.name == "template")
                {
                    if (metadataItem.params.length == 0) Context.error("Metadata template() exists, but was empty.", p);
                    for (templateMetadata in metadataItem.params)
                    {
                        switch( templateMetadata.expr ) 
                        {
                            case EConst(c):
                                switch(c) 
                                {
                                    case CString(str): 
                                        template = str;
                                    default: 
                                        Context.error("Metadata for template() existed, but was not a constant String.", p);
                                }
                            default: 
                                Context.error("Metadata for template() existed, but was not a constant value.", p);
                        } 
                    }
                }
            }
        }
        else 
        {
            // 
            // IF TEMPLATE FILE IS DECLARED IN METADATA
            //
            if (meta.has("loadTemplate")) 
            {
                for (metadataItem in meta.get())
                {
                    if (metadataItem.name == "loadTemplate")
                    {
                        if (metadataItem.params.length == 0) Context.error("Metadata loadTemplate() exists, but was empty.", p);

                        for (templateMetadata in metadataItem.params)
                        {
                            switch( templateMetadata.expr ) 
                            {
                                case EConst(c):
                                    switch(c) 
                                    {
                                        case CString(str): 
                                            templateFile = str;
                                        default: 
                                            Context.error("Metadata for loadTemplate() existed, but was not a constant String.", p);
                                    }
                                default: 
                                    Context.error("Metadata for loadTemplate() existed, but was not a constant value.", p);
                            } 
                        }
                    }
                }
            }
            //
            // IF NO TEMPLATE OR FILE IS DECLARED IN METADATA
            //
            else 
            {
                // If there is no metadata for the template, look for a file in the same 
                // spot but with ".tpl" instead of ".hx" at the end.
                templateFile = className.replace(".", "/") + ".html";
            }

            //
            // Attempt to load the file
            //
            try 
            {
                // Try to read the specified file
                template = neko.io.File.getContent(Context.resolvePath(templateFile));
            } 
            catch( e : Dynamic ) 
            {
                try 
                {
                    // That was searching by fully qualified classpath, but try just the same folder....
                    var file = Std.string(localClass);  // eg. my.pack.Widget
                    var arr = file.split(".");          // eg. [my,pack,Widget]
                    arr.pop();                          // eg. [my.pack]
                    var path = arr.join("/");           // eg. my/pack

                    path = (path.length > 0) ? path + "/" : "./"; // add a trailing slash, unless we're on the current directory
                    template = neko.io.File.getContent(Context.resolvePath(path + templateFile));
                }
                catch (e : Dynamic)
                {
                    // If it fails, give an error message at compile time
                    var errorMessage = "Could not load the widget template: " + templateFile;
                    Context.warning(errorMessage, p);
                    template = null;
                }
            }
        }

        return template;
    }
    
    static function createField_get_template(template:String, widgetPos:Position):Field
    {
        return { 
            name : "get_template", 
            doc : null, 
            meta : [], 
            access : [AOverride], 
            kind : FFun({ 
                args: [], 
                expr: { 
                    expr: EBlock(
                        [
                        { 
                            expr: EReturn(
                                { 
                                    expr: EConst(
                                        CString(template)
                                    ), 
                                    pos: widgetPos
                                }
                            ), 
                            pos: widgetPos
                        }
                        ]
                    ), 
                    pos: widgetPos
                }, 
                params: [], 
                ret: null 
            }), 
            pos: widgetPos
        }
    }

    static function setupBindingVariables(c:ClassType):Array<Expr>
    {
        var p = Context.currentPos();
        var bindings = new Array();

        for (f in c.fields.get())
        {
            var varValue = ("o." + f.name).resolve();
            var expr = f.name.define(varValue);
            bindings.push(expr);
        }

        return bindings;
    }

    static function processTemplateBindings(template:String):{ template:String, bindings:Array<Expr>}
    {
        // Get every node (including descendants)
        var p = haxe.macro.Context.currentPos();
        var xml = template.parse();
        var allNodes = new dtx.DOMCollection();
        allNodes.addCollection(xml);
        allNodes.addCollection(xml.descendants(false));

        /*
        - for each partial
          - remove it from the XML
          - take the element name, and append it to the current class, use it as a class name
          - take the innerXML, use it as the template for a new class
        */
        for (node in allNodes)
        {
            if (node.isElement() && node.tagName().startsWith('_'))
            {
                //
                // Remove the partial from the template
                // 

                // Due to the way template.parse() works, if the partial's parent is on the top level
                // (ie. a sibling to your <html>) then node.removeFromDOM() won't remove it from xml,
                // because xml is a collection that includes all top level elements.  Weird, I know!
                // Anyway, the workaround is to remove it from the collection as well.
                if (node.parent == xml.getNode(0).parent)
                {
                    // this is a top level element, make sure we remove it from the xml:DOMCollection too
                    xml.removeFromCollection(node);
                }
                node.removeFromDOM();

                //
                // Create a class for this partial
                //
                var localClass = haxe.macro.Context.getLocalClass();

                var name = node.nodeName;
                var partialTpl = node.innerHTML();
                var pack = localClass.get().pack;

                var className = localClass.get().name + name;
                var classKind = TypeDefKind.TDClass({
                    sub: null,
                    params: [],
                    pack: ['dtx','widget'],
                    name: "Widget"
                });
                var classMeta = [{
                    pos: p,
                    params: [Context.makeExpr(partialTpl, p)],
                    name: "template"
                }];
                var fields:Array<Field> = [];

                var partialDefinition = {
                    pos: p,
                    params: [],
                    pack: pack,
                    name: className,
                    meta: classMeta,
                    kind: classKind,
                    isExtern: false,
                    fields: fields
                };

                haxe.macro.Context.defineType(partialDefinition);
            }
        }

        /*
        - for each loop
          - if not set, set attr(data-loop-id, t); t++;
          - take HTML, and create a new subwidget (as a class? or use a factory? eg PersonWidget.newLoop(1))
          - get the type parameter (T) of the Iterable.  eg String in Array<String>
          - create a class for the subwidget, take html
          - recurse on this macro for the subwidget.
        */

        /*
        - for each attribute, text node
          - search for "$" (but not "$$")
          - if found
              - if not set, set attr(data-bind, i); i++;
              - do string interpolation using modified Std.format(), get ("mailto:" + email)
              - add binding to bind(), using find([data-bind=i]) and setAttr() or setText()
        */

        var bindingExpressions = new Array<Expr>();

        var t = 0;
        for (node in allNodes)
        {
            t++;
            switch (node.nodeType)
            {
                case Xml.Element:
                    // Set up bindings for each attribute value
                    for (att in node.attributes())
                    {
                        var str = node.attr(att);
                        if (str.indexOf('$') > -1)
                        {
                            node.setAttr('data-binding',Std.string(t));
                            var stringAsExpr = Context.makeExpr(str, Context.currentPos());
                            var nameAsExpr = Context.makeExpr(att, Context.currentPos());
                            var identifierAsExpr = Context.makeExpr(Std.string(t), Context.currentPos());
                            var interpolationExpr = Format.format(stringAsExpr);
                            var bindingExpr = macro this.find('[data-binding="' + $identifierAsExpr + '"]').setAttr($nameAsExpr, $interpolationExpr);
                            bindingExpressions.push(bindingExpr);
                        }
                    }
                default:
                    // Set up bindings for the text content...
                    var str = node.text();
                    if (str.indexOf('$') > -1)
                    {
                        // Will need to get nearest element + index, so we can do:
                        // "nearestElm".find().children(false).get(index).setText();
                        var parent = node.parent;
                        if (parent.exists('data-binding') == false)
                        {
                            parent.setAttr('data-binding', Std.string(t));
                        }
                        var indexOfTextNode = Lambda.indexOf(parent.children(false), node);

                        var stringAsExpr = Context.makeExpr(str, Context.currentPos());
                        var identifierAsExpr = Context.makeExpr(parent.attr('data-binding'), Context.currentPos());
                        var indexAsExpr = Context.makeExpr(indexOfTextNode, Context.currentPos());
                        var interpolationExpr = Format.format(stringAsExpr);
                        var bindingExpr = macro this.find('[data-binding="' + $identifierAsExpr + '"]').getNode($indexAsExpr).setText($interpolationExpr);
                        bindingExpressions.push(bindingExpr);
                    }
            }
        }

        return { template: xml.html(), bindings: bindingExpressions };
    }
    
    static function createField_refresh(fnBody:Array<Expr>, isOverride:Bool):Field
    {
        var pos = Context.currentPos();
        return { 
            name : "refresh", 
            doc : null, 
            meta : [], 
            access : (isOverride) ? [AOverride, APublic] : [APublic], 
            kind : FFun({ 
                args: [], 
                expr: fnBody.toBlock(), 
                params: [], 
                ret: null 
            }), 
            pos: pos
        }
    }

    #end 
}