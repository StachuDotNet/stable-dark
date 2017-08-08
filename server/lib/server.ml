open Core
open Lwt

module Clu = Cohttp_lwt_unix
module C = Cohttp
module S = Clu.Server
module Request = Clu.Request
module Header = C.Header
module G = Graph


let server =
  let stop,stopper = Lwt.wait () in

  let callback _ req req_body =
    let uri = req |> Request.uri in
    (* let meth = req |> Request.meth |> Code.string_of_method in *)
    (* let headers = req |> Request.headers |> Header.to_string in *)
    let auth = req |> Request.headers |> Header.get_authorization in

    let admin_rpc_handler body : string =
      let time = Unix.gettimeofday () in
      let body = Util.inspect "request body" body ~formatter:ident in
      let g = G.load "blog" in
      try
        Api.apply_ops g body;
        G.save !g;
        let result = !g
                     |> Graph.to_frontend_string in
        let total = string_of_float (1000.0 *. (Unix.gettimeofday () -. time)) in
        Util.inspect ("response (" ^ total ^ "ms):")
        ~stop:1000
        ~formatter:ident
        result


      with
      | e -> print_endline (G.show_graph !g);
        raise e
    in

    let admin_ui_handler () =
      let template = Util.readfile "templates/ui.html" in
      Util.string_replace "ALLFUNCTIONS" (Api.functions) template
    in

    let static_handler uri =
      let fname = S.resolve_file ~docroot:"." ~uri in
      S.respond_file ~fname ()
    in

    let auth_handler handler
      = match auth with
      | (Some `Basic ("dark", "2DqMHguUfsAGCPerWgyHRxPi"))
        -> handler
      | _
        -> Cohttp_lwt_unix.Server.respond_need_auth ~auth:(`Basic "dark") ()
    in

    let route_handler _ =
      req_body |> Cohttp_lwt_body.to_string >>=
      (fun req_body ->
         try
           match (Uri.path uri) with
           | "/admin/api/rpc" ->
             S.respond_string ~status:`OK ~body:(admin_rpc_handler req_body) ()
           | "/sitemap.xml" ->
             S.respond_string ~status:`OK ~body:"" ()
           | "/favicon.ico" ->
             S.respond_string ~status:`OK ~body:"" ()
           | "/shutdown" ->
             let () = Lwt.wakeup stopper () in
             S.respond_string ~status:`OK ~body:"Disembowelment" ()
           | "/admin/ui" ->
             S.respond_string ~status:`OK ~body:(admin_ui_handler ()) ()
           | "/admin/test" ->
             static_handler (Uri.of_string "/templates/test.html")
           | p when (String.length p) < 8 ->
             S.respond_string ~status:`Not_implemented ~body:"app routing" ()
           | p when (String.equal (String.sub p ~pos:0 ~len:8) "/static/") ->
             static_handler uri
           | _ ->
             S.respond_string ~status:`Not_implemented ~body:"app routing" ()
         with
         | e ->
           let backtrace = Exn.backtrace () in
           let body = match e with
             | (Exception.UserException msg) -> "UserException: " ^ msg
             | (Yojson.Json_error msg) -> "Not a value: " ^ msg
             | _ -> Exn.to_string e
           in
           print_endline ("Error: " ^ body);
           print_endline backtrace;
           S.respond_string ~status:`Internal_server_error ~body ())
    in
    ()
    |> route_handler
    |> auth_handler
  in
  S.create ~stop ~mode:(`TCP (`Port 8000)) (S.make ~callback ())

let run () = ignore (Lwt_main.run server)
