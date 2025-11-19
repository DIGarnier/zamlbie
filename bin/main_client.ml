open Zamlbie

let () =
  let run =
    let open Lwt.Infix in
    let args = Client_arg.parse_args () in
    let server_url = Config.get_server_url ~url:args.server_url () in
    match args.command with
    | Client_arg.Join id ->
      Client.join_game ~server_url (Notty_lwt.Term.create ()) id
    | Client_arg.Test config ->
      Client.offline_game (Notty_lwt.Term.create ()) config
    | Client_arg.List ->
      Client.list_lobbies ~server_url ()
    | Client_arg.Create config ->
      Client.create_game ~server_url config
      >>= (function
       | Ok game -> Client.join_game ~server_url (Notty_lwt.Term.create ()) game.game_id
       | Error err -> failwith (Http.Raw_client.show_error err))
  in
  Lwt_main.run run
;;
