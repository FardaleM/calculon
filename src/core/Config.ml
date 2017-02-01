open Prelude

type t = {
  server : string;
  port : int;
  username : string;
  realname : string;
  nick : string;
  tls: bool;
  channel : string;
  state_file : string;
}

let default = {
  server = "irc.freenode.net";
  port = 7000;
  username = "calculon";
  realname = "calculon";
  nick = "calculon";
  tls = true;
  channel = "#ocaml";
  state_file = "state.json";
}

let parse conf args =
  let custom_nick = ref None in
  let custom_chan = ref None in
  let custom_server = ref None in
  let custom_state = ref None in
  let custom_port = ref 7000 in
  let custom_tls = ref None in
  let options = Arg.align
      [ "--nick", Arg.String (fun s -> custom_nick := Some s),
        " custom nickname (default: " ^ default.nick ^ ")"
      ; "--chan", Arg.String (fun s -> custom_chan := Some s),
        " channel to join (default: " ^ default.channel ^ ")"
      ; "--port", Arg.Set_int custom_port, " port of the server"
      ; "--server", Arg.String (fun s -> custom_server := Some s),
        " server to join (default: " ^ default.server ^ ")"
      ; "--state", Arg.String (fun s -> custom_state := Some s),
        " file containing factoids (default: " ^ default.state_file ^ ")"
      ; "--tls", Arg.Unit (fun () -> custom_tls := Some true), " enable TLS"
      ; "--no-tls", Arg.Unit (fun () -> custom_tls := Some false), " disable TLS"
      ]
  in
  Arg.parse_argv args options ignore "parse options";
  { conf with
    nick = !custom_nick |? conf.nick;
    channel = !custom_chan |? conf.channel;
    server = !custom_server |? conf.server;
    tls = !custom_tls |? conf.tls;
    port = !custom_port;
    state_file = !custom_state |? conf.state_file;
  }

let of_argv () =
  try parse default Sys.argv
  with
    | Arg.Bad msg -> print_endline msg; exit 1
    | Arg.Help msg -> print_endline msg; exit 0
