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

let css =
  [["css";"button.css"];
   ["css";"dialog.css"];
   ["css";"linkbutton.css"];
   ["css";"menu.css"];
   ["css";"menuitem.css"];
   ["css";"menuseparator.css"];
   ["css";"tab.css"];
   ["css";"tabbar.css"];["toolbar.css"];
   ["css";"colormenubutton,css"];
   ["css";"palette.css"];
   ["css";"editor/bubble.css"];
   ["css";"editor/dialog.css"];
   ["css";"editor/linkdialog.css"];
   ["css";"editortoolbar.css"]]

let css_links =
  List.map (function css -> (css_link (static css) ())) css

let create_page mytitle mycontent =
  Lwt.return
    (html
       (head (title (pcdata mytitle))
          (css_links@[script_closure]))
       (body (mycontent)))

let () =
  Ocamlnote_app.register
    ~service:main_service
    (fun () () ->
      let title = "Editor" in
      let content = [p [pcdata "Hello"]] in
      create_page title content
    )
