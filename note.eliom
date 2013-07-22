{shared{
  open Eliom_lib
  open Eliom_content
  open Eliom_content.Html5.D
}}

module Ocamlnote_app =
  Eliom_registration.App (
    struct
      let application_name = "note"
    end)

let main_service =
  Eliom_service.service ~path:[] ~get_params:Eliom_parameter.unit ()

let add_note_service =
  Eliom_service.post_service
    ~fallback:main_service
    ~post_params:Eliom_parameter.
    (string "user_id" ** (string "name" ** string "note")) ()

let view_note_service =
  Eliom_service.service ~path:["view"] ~get_params:Eliom_parameter.unit ()

let static s = make_uri ~service:(Eliom_service.static_dir ()) s

let css =
  [["css";"demo.css"];
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
   ["css";"colorpalette.css"];
   ["css";"bubble.css"];
   ["css";"dialog.css"];
   ["css";"linkdialog.css"];
   ["css";"editortoolbar.css"]]

let css_links =
  List.map (function css -> (css_link (static css) ())) css

let script_closure =
  js_script (uri_of_string
    (function () ->
      "http://closure-library.googlecode.com/svn/trunk/closure/goog/base.js"))
    ()

let js_oclosure = js_script (static ["ocaml-note_oclosure.js"]) ()
let js = js_script (static ["ocaml-note.js"]) ()

let create_page mytitle mycontent =
  Lwt.return
    (html
       (head (title (pcdata mytitle))
          ([script_closure; js_oclosure]@css_links))
       (body (mycontent)))

let () =
  Ocamlnote_app.register
    ~service:main_service
    (fun () () ->
      let title = "Editor" in
      let toolbar = div
        ~a:[a_id "toolbar"; a_style "width:602px"] [] in
      let editme = div
        ~a:[a_id "editMe"; a_style "width: 600px; height: 300px;
                                    background-color: white;
                                    border: 1px solid grey;";] [] in
      let set_content = string_input
        ~a:[a_id "setFieldContent_b"]
        ~input_type:`Submit ~value:"Set Content" () in
      let add_note_form =
        [post_form ~service:add_note_service
            (fun (user_id, (name, note)) ->
              [fieldset
                  [label ~a:[a_for user_id] [pcdata "user_id"];
                   string_input ~input_type:`Text
                     ~name:user_id ();
                   br ();
                   label ~a:[a_for name] [pcdata "name"];
                   string_input ~input_type:`Text
                     ~name:name ();
                   br ();
                   textarea
                     ~a:[a_id "fieldContents"; a_placeholder "Write a message ...";
                         a_style "height:100px;width:400px;"]
                     ~name:note
                     ();
                   br ();
                   string_input ~input_type:`Submit
                     ~value:"Add" ()
                  ]]) ()] in
      let content = [h1 [pcdata "goog.editor"];
                     p [pcdata "This is a demonstration of a editable field,
                               with installed plugins, hooked up to a toolbar."];
                     br ();
                     toolbar; editme;
                     hr ();
                     p [ b [pcdata "Current field contents"]];
                     div (add_note_form); br (); set_content; js] in
      create_page title content
    )

let () =
  Ocamlnote_app.register
    ~service:add_note_service
    (fun () (user_id, (name, note)) ->
      Db.add_onote (Int32.of_string user_id) name note >>=
        (function () ->
          let title = "Result" in
          let content = [h1 [pcdata "success"]] in
          create_page title content
        )
    )

let () =
  Ocamlnote_app.register
    ~service:view_note_service
    (fun () () ->
      Db.find_all_onote () >>=
        (function
        | [] ->
          let title = "View" in
          let content = [h1 [pcdata "Nothing"]] in
          create_page title content
        | notes ->
          let rec read_note all_note =
            match all_note with
            | head::tail ->
              let note = Sql.get head#note in
              (p [pcdata note])::(read_note tail)
            | _ -> [p [pcdata "end"]] in
          let title = "View" in
          let content = read_note notes in
          create_page title content
        )
    )
