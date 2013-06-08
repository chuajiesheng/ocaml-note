{shared{
  open Eliom_lib
  open Eliom_content
  open Eliom_content.Html5.D
}}

module Ocamlnote_app =
  Eliom_registration.App (
    struct
      let application_name = "ocamlnote"
    end)

let main_service =
  Eliom_service.service ~path:[] ~get_params:Eliom_parameter.unit ()

let static s = make_uri ~service:(Eliom_service.static_dir ()) s

let script_closure =
  js_script (uri_of_string
    (function ()
  -> "http://closure-library.googlecode.com/svn/trunk/closure/goog/base.js"))
    ()

let script_main =
  js_script (static ["ocaml-note.js"]) ()

let script_oclosure =
  js_script (static ["ocaml-note_oclosure.js"]) ()

let css =
  [["css";"ocaml-note.css"];
   ["css";"button.css"];
   ["css";"dialog.css"];
   ["css";"linkbutton.css"];
   ["css";"menu.css"];
   ["css";"menuitem.css"];
   ["css";"menuseparator.css"];
   ["css";"tab.css"];
   ["css";"tabbar.css"];
   ["css";"toolbar.css"];
   ["css";"colormenubutton.css"];
   ["css";"palette.css"];
   ["css";"bubble.css"];
   ["css";"dialog.css"];
   ["css";"linkdialog.css"];
   ["css";"editortoolbar.css"]]

let css_links =
  List.map (function css -> (css_link (static css) ())) css

let create_page mytitle mycontent =
  Lwt.return
    (html
       (head (title (pcdata mytitle))
          (css_links@[script_closure]))
       (body (mycontent)))

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
  let register_plugins =
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
  let watch = ignore(
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
    updateFieldContents()

  let init_client () =
    (
      Eliom_lib.alert "hello";
      register_plugins;
      myToolbarController;
      watch
    )
}}

let () =
  Ocamlnote_app.register
    ~service:main_service
    (fun () () ->
      let _ = ignore {unit{ init_client ()}} in
      let title = "Editor" in
      let toolbar = div ~a:[a_id "toolbar"] [] in
      let editme = div ~a:[a_id "editMe"] [] in
      let text = Raw.textarea ~a:[a_id "fieldContents"; a_placeholder "Write a message ..."] (pcdata "") in
      let submit = string_input ~input_type:`Submit ~value:"Set Content" () in
      let content = [h1 [pcdata "goog.editor"];
                     toolbar; editme; text; submit;
                     script_oclosure; script_main] in
      create_page title content
    )
