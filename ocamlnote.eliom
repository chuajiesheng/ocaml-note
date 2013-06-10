{shared{
  open Eliom_lib
  open Eliom_content
}}

module Ocamlnote_app =
  Eliom_registration.App (
    struct
      let application_name = "ocaml-note"
    end)

{client{
  let get_el s = Js.Opt.get (Dom_html.document##getElementById(Js.string s))
    (fun _ -> Dom_html.window##alert (Js.string s); assert false)

       let get_textarea s = Js.Opt.get (Dom_html.CoerceTo.textarea (get_el s))
         (fun _ -> assert false)

       (* Create an editable field. *)
       let myField = jsnew Goog.Geditor.field(Js.string "editMe", Js.null)

       let updateFieldContents _ =
         (get_textarea "fieldContents")##value <- myField##getCleanContents()

       (* Create and register all of the editing plugins you want to use *)
       let _ =
         Goog.Geditor.Field.registerPlugin myField
           (jsnew Goog.Geditor.Plugins.basicTextFormatter());
         Goog.Geditor.Field.registerPlugin myField
           (jsnew Goog.Geditor.Plugins.removeFormatting());
         Goog.Geditor.Field.registerPlugin myField
           (jsnew Goog.Geditor.Plugins.undoRedo(Js.null));
         Goog.Geditor.Field.registerPlugin myField
           (jsnew Goog.Geditor.Plugins.listTabHandler());
         Goog.Geditor.Field.registerPlugin myField
           (jsnew Goog.Geditor.Plugins.spacesTabHandler());
         Goog.Geditor.Field.registerPlugin myField
           (jsnew Goog.Geditor.Plugins.enterHandler());
         Goog.Geditor.Field.registerPlugin myField
           (jsnew Goog.Geditor.Plugins.headerFormatter());
         Goog.Geditor.Field.registerPlugin myField
           (jsnew Goog.Geditor.Plugins.loremIpsum(Js.string "Click here to edit"));
         Goog.Geditor.Field.registerPlugin myField
           (jsnew Goog.Geditor.Plugins.linkDialogPlugin());
         Goog.Geditor.Field.registerPlugin myField
           (jsnew Goog.Geditor.Plugins.linkBubble(Js.array [||]))

       (* Specify the buttons to add to the toolbar, using built in default buttons. *)
       let buttons = Js.array (Array.map Goog.Tools.Union.i1 [|
         Goog.Geditor.Command._BOLD;
         Goog.Geditor.Command._ITALIC;
         Goog.Geditor.Command._UNDERLINE;
         Goog.Geditor.Command._FONT_COLOR;
         Goog.Geditor.Command._BACKGROUND_COLOR;
         Goog.Geditor.Command._FONT_FACE;
         Goog.Geditor.Command._FONT_SIZE;
         Goog.Geditor.Command._LINK;
         Goog.Geditor.Command._UNDO;
         Goog.Geditor.Command._REDO;
         Goog.Geditor.Command._UNORDERED_LIST;
         Goog.Geditor.Command._ORDERED_LIST;
         Goog.Geditor.Command._INDENT;
         Goog.Geditor.Command._OUTDENT;
         Goog.Geditor.Command._JUSTIFY_LEFT;
         Goog.Geditor.Command._JUSTIFY_CENTER;
         Goog.Geditor.Command._JUSTIFY_RIGHT;
         Goog.Geditor.Command._SUBSCRIPT;
         Goog.Geditor.Command._SUPERSCRIPT;
         Goog.Geditor.Command._STRIKE_THROUGH;
         Goog.Geditor.Command._REMOVE_FORMAT
                                                             |])

       let myToolbar = Goog.Ui.Editor.DefaultToolbar.makeToolbar
         buttons
         (get_el "toolbar")
         Js.null

       (* Hook the toolbar into the field *)
       let myToolbarController =
         jsnew Goog.Ui.Editor.toolbarController(myField, myToolbar)

       let get_input s = Js.Opt.get (Dom_html.CoerceTo.input(get_el s))
         (fun _ -> assert false)

       (* Watch for field changes, to display below.*)
       let _ = ignore(
         Goog.Events.listen
           (Goog.Tools.Union.i1 myField)
           (Goog.Geditor.Field.EventType._DELAYEDCHANGE)
           (Js.wrap_callback updateFieldContents)
           Js.null);
         myField##makeEditable(Js.null);
         (get_input "setFieldContent_b")##onclick <-
           Dom_html.handler (
             fun _ ->
               myField##setHtml(Js._false,
                                Js.some ((get_textarea "fieldContents")##value),
                                Js.null, Js.null); Js._false);
         updateFieldContents();
}}

let _ =
  Eliom_registration.Html_text.register_service
    ~path:[]
    ~get_params:Eliom_parameter.unit
    (fun () () ->
      Lwt.return
        ("<html>
<!--
Copyright 2009 The Closure Library Authors. All Rights Reserved.

Use of this source code is governed by an Apache 2.0 License.
See the COPYING file for details.
-->
<!--
Author: jparent@google.com (Julie Parent)
-->
<head>
<meta http-equiv='X-UA-Compatible' content='IE=edge'>
  <title>goog.editor Demo</title>
  <script src='http://closure-library.googlecode.com/svn/trunk/closure/goog/base.js'></script>
  <script src='ocaml-note_oclosure.js'></script>
  <link rel='stylesheet' href='css/demo.css'>

  <link rel='stylesheet' href='css/button.css' />
  <link rel='stylesheet' href='css/dialog.css' />
  <link rel='stylesheet' href='css/linkbutton.css' />
  <link rel='stylesheet' href='css/menu.css'>
  <link rel='stylesheet' href='css/menuitem.css'>
  <link rel='stylesheet' href='css/menuseparator.css'>
  <link rel='stylesheet' href='css/tab.css' />
  <link rel='stylesheet' href='css/tabbar.css' />
  <link rel='stylesheet' href='css/toolbar.css' />
  <link rel='stylesheet' href='css/colormenubutton.css' />
  <link rel='stylesheet' href='css/palette.css' />
  <link rel='stylesheet' href='css/colorpalette.css' />

  <link rel='stylesheet' href='css/bubble.css' />
  <link rel='stylesheet' href='css/dialog.css' />
  <link rel='stylesheet' href='css/linkdialog.css' />
  <link rel='stylesheet' href='css/editortoolbar.css' />

  <style>
    #editMe {
      width: 600px;
      height: 300px;
      background-color: white;
      border: 1px solid grey;
    }
  </style>
</head>

<body>
  <h1>goog.editor Demo</h1>
  <p>This is a demonstration of a editable field, with installed plugins,
hooked up to a toolbar.</p>
  <br>
  <div id='toolbar' style='width:602px'></div>
  <div id='editMe'></div>
  <hr>
  <p><b>Current field contents</b>
  (updates as contents of the editable field above change):<br>
  <textarea id='fieldContents' style='height:100px;width:400px;'></textarea><br>
  <input type='button' value='Set Field Contents' id='setFieldContent_b' />
  (Use to set contents of the editable field to the contents of this textarea)
  </p>

  <script src='ocaml-note.js'></script>
</body>
</html>"
        ))
