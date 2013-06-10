{shared{
  open Eliom_lib
  open Eliom_content
}}

module Ocaml-note_app =
  Eliom_registration.App (
    struct
      let application_name = "ocaml-note"
    end)

let main_service =
  Eliom_service.service ~path:[] ~get_params:Eliom_parameter.unit ()

let () =
  Ocaml-note_app.register
    ~service:main_service
    (fun () () ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"ocaml-note"
           ~css:[["css";"ocaml-note.css"]]
           Html5.F.(body [
             h2 [pcdata "Welcome from Eliom's destillery!"];
           ])))
