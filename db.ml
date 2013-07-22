(*
  db.ml version 2

  Version History

  Version 2
  ---------
  1. improve convention for naming table, variable
     such as (add|find|change|delete)_by_(search format)

  Version 1
  ---------
  1. originate from bookmark-app
  2. have basic user table and text storing facilities
*)

module Lwt_thread = struct
  include Lwt
  include Lwt_chan
end
module Lwt_PGOCaml = PGOCaml_generic.Make(Lwt_thread)
module Lwt_Query = Query.Make_with_Db(Lwt_thread)(Lwt_PGOCaml)
open Lwt

let get_db : unit -> unit Lwt_PGOCaml.t Lwt.t =
  let db_handler = ref None in
  fun () ->
    match !db_handler with
    | Some h -> Lwt.return h
    | None -> Lwt_PGOCaml.connect ~database:"onote" ()

(*
  create a seq as similar to postgresql
  see http://www.postgresql.org/docs/8.1/static/datatype.html#DATATYPE-SERIAL
  beside serial, bigserial also available
  serial is mapped to Sql.int32_t
  while bigserial is mapped to Sql.int64_t
*)
let users_id_seq = <:sequence< serial "users_id_seq">>

let users = <:table< users (
  id integer NOT NULL DEFAULT(nextval $users_id_seq$),
  username text NOT NULL,
  password text NOT NULL
) >>

let onote_id_seq = <:sequence< serial "onote_id_seq">>

let onote = <:table< bookmarks (
  id integer NOT NULL DEFAULT(nextval $onote_id_seq$),
  user_id integer NOT NULL,
  name text NOT NULL,
  note text NOT NULL
)>>

let find_user_by_name name =
  (get_db () >>= fun dbh ->
   Lwt_Query.view dbh
   <:view< {id = user_.id;
            username = user_.username;
            password = user_.password} |
            user_ in $users$;
            user_.username = $string:name$; >>)

let find_user_by_id id =
  (get_db () >>= fun dbh ->
   Lwt_Query.view dbh
   <:view< {id = user_.id;
            username = user_.username;
            password = user_.password} |
            user_ in $users$;
            user_.id = $int32:id$; >>)

let get_username user_id =
  find_user_by_id (Int32.of_int (int_of_string user_id)) >>=
    (fun result ->
      match result with
        [] -> raise (Failure "No such user.")
      | u::_ ->
        Lwt.return (Sql.get u#username)
    )

let check_pwd name pwd =
  (get_db () >>= fun dbh ->
   Lwt_Query.view dbh
   <:view< {id = user_.id} |
            user_ in $users$;
            user_.username = $string:name$;
            user_.password = $string:pwd$ >>)
  >|= (function [] -> false | _ -> true)

let add_user name pwd =
  (get_db () >>= fun dbh ->
  Lwt_Query.query dbh
  <:insert< $users$ :=
    { id = nextval $users_id_seq$;
      username = $string:name$;
      password = $string:pwd$; } >>)

let change_user_pwd id name pwd =
  (get_db () >>= fun dbh ->
  Lwt_Query.query dbh
  <:update<
    u in $users$
    := { password = $string:pwd$ }
    | u.id = $int32:id$;
      u.username = $string:name$; >>
  )

let find_onote_from_users user_id =
  (get_db () >>= fun dbh ->
   Lwt_Query.view dbh
   <:view< {id = onote_.id;
            user_id = onote_.user_id;
            name = onote_.name;
            note = onote_.note} |
            onote_ in $onote$;
            onote_.user_id = $int32:user_id$; >>)

let add_onote user_id name note =
  (get_db () >>= fun dbh ->
  Lwt_Query.query dbh
  <:insert< $onote$ :=
    { id = nextval $onote_id_seq$;
      user_id = $int32:user_id$;
      name = $string:name$;
      note = $string:note$; } >>)

let delete_onote user_id onote_id =
  (get_db () >>= fun dbh ->
   Lwt_Query.query dbh
   <:delete< onote_ in $onote$ |
             onote_.user_id = $int32:user_id$;
             onote_.id = $int32:onote_id$; >>
  )
